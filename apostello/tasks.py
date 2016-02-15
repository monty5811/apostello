# -*- coding: utf-8 -*-
import json

import requests
from celery import task
from celery.decorators import periodic_task
from celery.task.schedules import crontab
from django.conf import settings
from django.core.mail import send_mail
from django.utils import timezone
from django_twilio.client import twilio_client
from twilio.rest.exceptions import TwilioRestException

# sending messages


@task()
def group_send_message_task(body, group_name, sent_by, eta):
    """Send message to all members of group."""
    from apostello.models import Recipient, RecipientGroup
    group = RecipientGroup.objects.filter(name=group_name, is_archived=False)

    for recipient in Recipient.objects.filter(groups__in=group):
        recipient.send_message(
            content=body,
            group=group_name,
            sent_by=sent_by,
            eta=eta
        )


@task()
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
            warn_on_blacklist.delay(recipient.pk)
        else:
            raise e

# SMS logging and consistency checks


@task()
def check_incoming_log(page_id=0, fetch_all=False):
    """Update incoming log."""
    from apostello.logs import check_incoming_log
    check_incoming_log(page_id=page_id, fetch_all=fetch_all)


@task()
def check_outgoing_log(page_id=0, fetch_all=False):
    """Update outgoing log."""
    from apostello.logs import check_outgoing_log
    check_outgoing_log(page_id=page_id, fetch_all=fetch_all)


@task()
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
    check_incoming_log.delay()


@task()
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


@task()
def send_async_mail(subject, body, to):
    """Send email."""
    from apostello.models import SiteConfiguration
    from_ = SiteConfiguration.get_solo().from_email
    send_mail(subject, body, from_, to)


@task()
def notify_office_mail(subject, body):
    """Send email to office."""
    from apostello.models import SiteConfiguration
    to_ = SiteConfiguration.get_solo().office_email
    send_async_mail(subject, body, [to_])


@task()
def warn_on_blacklist(recipient_pk):
    """Send email to office when we discover we are blacklisted."""
    from apostello.models import Recipient
    recipient = Recipient.objects.get(pk=recipient_pk)
    notify_office_mail.delay(
        '[Apostello] Blacklist Update',
        "{0} ({1}) is now blocking us".format(
            str(recipient.number),
            str(recipient),
        ),
    )


@task()
def warn_on_blacklist_receipt(recipient_pk, sms):
    """Send email to office on reciept of message from a blacklister."""
    from apostello.models import Recipient
    recipient = Recipient.objects.get(pk=recipient_pk)
    if recipient.is_blocking:
        email_body = "{0} has blacklisted us in the past but has just sent this message:".format(
            str(recipient)
        )
        email_body += "\n\n\t{0}\n\nYou may need to email them as we cannot currently reply to them.".format(
            sms
        )
        notify_office_mail.delay(
            '[Apostello] Blacklist Receipt Notice',
            email_body,
        )


@periodic_task(run_every=(crontab(hour="21", minute="30", day_of_week="*")))
def send_keyword_digest():
    """Send daily digest email."""
    from apostello.models import Keyword
    # http://celery.readthedocs.org/en/latest/userguide/periodic-tasks.html
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
                send_async_mail.delay(
                    'Daily update for "{0}" responses'.format(
                        str(keyword)
                    ),
                    "The following text messages have been received today:\n\n{0}".format(
                        "\n".join([str(x) for x in new_responses])
                    ), [subscriber.email]
                )

        keyword.last_email_sent_time = checked_time
        keyword.save()


@task()
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
        r = requests.post(url, data=json.dumps(data), headers=headers)
        print(r)


@task()
def sms_to_slack(sms_body, person, keyword):
    """Post message to slack webhook."""
    fallback = "{0}\nFrom: {1}\n(matched: {2})".format(
        sms_body, str(person), str(keyword)
    )
    attachments = [
        {
            'fallback': fallback,
            'color': '#5b599c',
            'text': sms_body,
            'fields': [
                {
                    'title': 'From',
                    'value': str(person),
                    'short': True
                }, {
                    'title': 'Matched',
                    'value': str(keyword),
                    'short': True
                }
            ],
        },
    ]
    post_to_slack(attachments)


# Elvanto import
@periodic_task(run_every=(crontab(hour="2", minute="30", day_of_week="*")))
def fetch_elvanto_groups(force=False):
    """Fetch all Elvanto groups."""
    from site_config.models import SiteConfiguration
    config = SiteConfiguration.get_solo()
    if force or config.sync_elvanto:
        from elvanto.models import ElvantoGroup
        ElvantoGroup.fetch_all_groups()


@periodic_task(run_every=(crontab(hour="3", minute="0", day_of_week="*")))
def pull_elvanto_groups(force=False):
    """Pull all the Elvanto groups that are set to sync."""
    from site_config.models import SiteConfiguration
    config = SiteConfiguration.get_solo()
    if force or config.sync_elvanto:
        from elvanto.models import ElvantoGroup
        ElvantoGroup.pull_all_groups()
