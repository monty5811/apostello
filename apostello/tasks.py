import json
import logging

import requests
from django.conf import settings
from django.core.mail import get_connection, send_mail
from django.utils import timezone
from django_twilio.client import twilio_client
from twilio.rest.exceptions import TwilioRestException

from apostello.utils import fetch_default_reply
from django_q.tasks import async

logger = logging.getLogger('apostello')

# sending messages


def group_send_message_task(body, group_name, sent_by, eta):
    """Send message to all members of group."""
    from apostello.models import Recipient, RecipientGroup
    group = RecipientGroup.objects.filter(name=group_name, is_archived=False)

    for recipient in Recipient.objects.filter(groups__in=group):
        recipient.send_message(
            content=body, group=group_name, sent_by=sent_by, eta=eta
        )


def recipient_send_message_task(recipient_pk, body, group, sent_by):
    """Send a message asynchronously."""
    from apostello.models import Recipient
    recipient = Recipient.objects.get(pk=recipient_pk)
    if recipient.is_archived:
        # if recipient is not active, fail silently
        return

    from apostello.models import SmsOutbound, RecipientGroup
    # if %name% is present, replace:
    body = recipient.personalise(body)
    # send twilio message
    try:
        message = twilio_client.messages.create(
            body=body,
            to=str(recipient.number),
            from_=settings.TWILIO_FROM_NUM
        )
        # add to sms out table
        sms = SmsOutbound(
            sid=message.sid,
            content=body,
            time_sent=timezone.now(),
            recipient=recipient,
            sent_by=sent_by
        )
        if group is not None:
            sms.recipient_group = RecipientGroup.objects.filter(name=group)[0]
        sms.save()
    except TwilioRestException as e:
        if e.code == 21610:
            recipient.is_blocking = True
            recipient.save()
            async('apostello.tasks.blacklist_notify', recipient.pk, '', 'stop')
        else:
            raise e


def send_queued_sms():
    """Check for and send any queued messages."""
    from apostello.models import QueuedSms
    for sms in QueuedSms.objects.filter(
        sent=False, time_to_send__lte=timezone.now()
    ):
        sms.send()


def ask_for_name(person_from_pk, sms_body, ask_for_name):
    """Asks a contact to provide their name."""
    if not ask_for_name:
        return
    from site_config.models import SiteConfiguration
    config = SiteConfiguration.get_solo()
    if not config.disable_all_replies:
        from apostello.models import Recipient
        contact = Recipient.objects.get(pk=person_from_pk)
        contact.send_message(
            content=fetch_default_reply('auto_name_request'),
            sent_by="auto name request"
        )
        async(
            'apostello.tasks.notify_office_mail',
            '[Apostello] Unknown Contact!',
            'SMS: {0}\nFrom: {1}\n\n\nThis person is unknown and has been'
            ' asked for their name.'.format(sms_body, str(contact)),
        )


# SMS logging and consistency checks


def check_incoming_log(page_id=0, fetch_all=False):
    """Update incoming log."""
    from apostello.logs import check_incoming_log
    check_incoming_log(page_id=page_id, fetch_all=fetch_all)


def check_outgoing_log(page_id=0, fetch_all=False):
    """Update outgoing log."""
    from apostello.logs import check_outgoing_log
    check_outgoing_log(page_id=page_id, fetch_all=fetch_all)


def log_msg_in(p, t, from_pk):
    """Log incoming message."""
    from apostello.models import Keyword, SmsInbound, Recipient
    from_ = Recipient.objects.get(pk=from_pk)
    matched_keyword = Keyword.match(p['Body'].strip())
    SmsInbound.objects.create(
        sid=p['MessageSid'],
        content=p['Body'],
        time_received=t,
        sender_name=str(from_),
        sender_num=p['From'],
        matched_keyword=str(matched_keyword),
        matched_link=Keyword.get_log_link(matched_keyword),
        matched_colour=Keyword.lookup_colour(p['Body'].strip())
    )
    # check log is consistent:
    async('apostello.tasks.check_incoming_log')


def update_msgs_name(person_pk):
    """Back date sender_name field on inbound sms."""
    from apostello.models import Recipient, SmsInbound
    person_ = Recipient.objects.get(pk=person_pk)
    name = str(person_)
    number = str(person_.number)
    for sms in SmsInbound.objects.filter(sender_num=number):
        sms.sender_name = name
        sms.save()


# notifications, email, slack etc


def send_async_mail(subject, body, to):
    """Send email."""
    # read email settings from DB, if they are empty, they will be read from
    # settings.py instead
    from site_config.models import SiteConfiguration
    s = SiteConfiguration.get_solo()
    from_ = s.email_from or settings.EMAIL_FROM
    send_mail(subject, body, from_, to)


def notify_office_mail(subject, body):
    """Send email to office."""
    from site_config.models import SiteConfiguration
    to_ = SiteConfiguration.get_solo().office_email
    send_async_mail(subject, body, [to_])


def blacklist_notify(recipient_pk, sms_body, keyword):
    """Send email to office when we discover we are blacklisted."""
    from apostello.models import Recipient
    recipient = Recipient.objects.get(pk=recipient_pk)
    if keyword == 'start':
        return
    if keyword == 'stop':
        async(
            'apostello.tasks.notify_office_mail',
            '[Apostello] Blacklist Update',
            "{0} ({1}) is now blocking us".format(
                str(recipient.number),
                str(recipient),
            ),
        )
        return
    if recipient.is_blocking:
        email_body = "{0} has blacklisted us in the past but has just sent " \
            "this message:\n\n\t{1}\n\n" \
            "You may need to email them as we cannot currently reply to them."
        email_body.format(str(recipient), sms_body)
        async(
            'apostello.tasks.notify_office_mail',
            '[Apostello] Blacklist Receipt Notice',
            email_body,
        )


def send_keyword_digest():
    """Send daily digest email."""
    from apostello.models import Keyword
    for keyword in Keyword.objects.filter(is_archived=False):
        checked_time = timezone.now()
        new_responses = keyword.fetch_matches()
        if keyword.last_email_sent_time is not None:
            new_responses = new_responses.filter(
                time_received__gt=keyword.last_email_sent_time
            )
        # if any, loop over subscribers and send email
        if new_responses.count() > 0:
            for subscriber in keyword.subscribed_to_digest.all():
                async(
                    'apostello.tasks.send_async_mail',
                    'Daily update for "{0}" responses'.format(str(keyword)),
                    "The following text messages have been received today:\n\n{0}".
                    format("\n".join([str(x) for x in new_responses])),
                    [subscriber.email]
                )

        keyword.last_email_sent_time = checked_time
        keyword.save()


def post_to_slack(attachments):
    """Post message to slack webhook."""
    from site_config.models import SiteConfiguration
    config = SiteConfiguration.get_solo()
    url = config.slack_url
    if url:
        data = {
            'username': 'apostello',
            'icon_emoji': ':speech_balloon:',
            'attachments': attachments
        }
        headers = {'Content-type': 'application/json', 'Accept': 'text/plain'}
        requests.post(url, data=json.dumps(data), headers=headers)


def sms_to_slack(sms_body, person_name, keyword_name):
    """Post message to slack webhook."""
    fallback = "{0}\nFrom: {1}\n(matched: {2})".format(
        sms_body, person_name, keyword_name
    )
    attachments = [
        {
            'fallback': fallback,
            'color': '#5b599c',
            'text': sms_body,
            'fields': [
                {
                    'title': 'From',
                    'value': person_name,
                    'short': True
                }, {
                    'title': 'Matched',
                    'value': keyword_name,
                    'short': True
                }
            ],
        },
    ]
    post_to_slack(attachments)


# Elvanto import
def fetch_elvanto_groups(force=False):
    """Fetch all Elvanto groups."""
    from site_config.models import SiteConfiguration
    config = SiteConfiguration.get_solo()
    if force or config.sync_elvanto:
        from elvanto.models import ElvantoGroup
        ElvantoGroup.fetch_all_groups()


def pull_elvanto_groups(force=False):
    """Pull all the Elvanto groups that are set to sync."""
    from site_config.models import SiteConfiguration
    config = SiteConfiguration.get_solo()
    if force or config.sync_elvanto:
        from elvanto.models import ElvantoGroup
        ElvantoGroup.pull_all_groups()


#
def add_new_contact_to_groups(contact_pk):
    """Add contact to any groups that are in "auto populate with new contacts."""
    logger.info('Adding new person to designated groups')
    from apostello.models import Recipient
    from site_config.models import SiteConfiguration
    contact = Recipient.objects.get(pk=contact_pk)
    for grp in SiteConfiguration.get_solo().auto_add_new_groups.all():
        logger.info('Adding %s to %s', contact.full_name, grp.name)
        contact.groups.add(grp)
        contact.save()
        logger.info('Added %s to %s', contact.full_name, grp.name)
