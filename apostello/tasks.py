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
    """Send message to all members of group"""
    from apostello.models import Recipient, RecipientGroup
    group = RecipientGroup.objects.filter(name=group_name, is_archived=False)

    for recipient in Recipient.objects.filter(groups__in=group):
        recipient.send_message(content=body,
                               group=group_name,
                               sent_by=sent_by,
                               eta=eta)


@task()
def recipient_send_message_task(recipient_pk, body, group, sent_by):
    """Send a message asynchronously"""
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
            from_=settings.TWILIO_FROM_NUM)
        # add to sms out table
        sms = SmsOutbound(sid=message.sid,
                          content=body,
                          time_sent=timezone.now(),
                          recipient=recipient,
                          sent_by=sent_by)
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
def check_log_consistent(page_id):
    from apostello.models import Keyword, Recipient, SmsInbound
    check_next_page = False
    for x in twilio_client.messages.list(page=page_id, page_size=50, to=settings.TWILIO_FROM_NUM):
        sms, created = SmsInbound.objects.get_or_create(sid=x.sid)
        if created:
            sender, s_created = Recipient.objects.get_or_create(number=x.from_)
            if s_created:
                sender.first_name = 'Unknown'
                sender.last_name = 'Person'
                sender.save()

            sms.content = x.body
            sms.time_received = timezone.make_aware(x.date_created,
                                                    timezone.get_current_timezone())
            sms.sender_name = str(sender)
            sms.sender_num = x.from_
            sms.matched_keyword = str(Keyword.match(x.body.strip()))
            sms.matched_colour = Keyword.lookup_colour(x.body.strip())
            sms.is_archived = True
            sms.save()
            check_next_page = True

    if check_next_page:
        check_log_consistent.delay(page_id + 1)


@task()
def check_recent_outgoing_log(page_id):
    from apostello.models import Recipient, SmsOutbound
    check_next_page = False
    for x in twilio_client.messages.list(page=page_id, page_size=50, from_=settings.TWILIO_FROM_NUM):
        recip, r_created = Recipient.objects.get_or_create(number=x.to)
        if r_created:
            recip.first_name = 'Unknown'
            recip.last_name = 'Person'
            recip.save()

        sms, created = SmsOutbound.objects.get_or_create(sid=x.sid)
        if created:
            sms.content = x.body
            sms.time_sent = timezone.make_aware(x.date_sent,
                                                timezone.get_current_timezone())
            sms.sent_by = "Unknown - imported"
            sms.recipient = recip
            sms.save()
            check_next_page = True

    if check_next_page:
        check_recent_outgoing_log.delay(page_id + 1)


@task()
def log_msg_in(p, t, from_pk):
    from apostello.models import Keyword, SmsInbound, Recipient
    from_ = Recipient.objects.get(pk=from_pk)
    matched_keyword = Keyword.match(p['Body'].strip())
    SmsInbound.objects.create(sid=p['MessageSid'],
                              content=p['Body'],
                              time_received=t,
                              sender_name=str(from_),
                              sender_num=p['From'],
                              matched_keyword=str(matched_keyword),
                              matched_link=Keyword.get_log_link(matched_keyword),
                              matched_colour=Keyword.lookup_colour(p['Body'].strip()))
    # check log is consistent:
    check_log_consistent.delay(0)


@task()
def update_msgs_name(person_pk):
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
    from apostello.models import SiteConfiguration
    from_ = SiteConfiguration.get_solo().from_email
    send_mail(subject, body, from_, to)


@task()
def notify_office_mail(subject, body):
    from apostello.models import SiteConfiguration
    to_ = SiteConfiguration.get_solo().office_email
    send_async_mail(
        subject,
        body,
        to_
    )


@task()
def warn_on_blacklist(recipient_pk):
    from apostello.models import Recipient
    recipient = Recipient.objects.get(pk=recipient_pk)
    notify_office_mail.delay(
        '[Apostello] Blacklist Update',
        "{0] ({1}) is now blocking us".format(
            str(recipient.number),
            str(recipient),
        ),
    )


@task()
def warn_on_blacklist_receipt(recipient_pk, sms):
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
    from apostello.models import Keyword
    # http://celery.readthedocs.org/en/latest/userguide/periodic-tasks.html
    for keyword in Keyword.objects.filter(is_archived=False):
        checked_time = timezone.now()
        new_responses = keyword.fetch_matches()
        if keyword.last_email_sent_time is not None:
            new_responses = new_responses.filter(time_received__gt=keyword.last_email_sent_time)
        # if any, loop over subscribers and send email
        if new_responses.count() > 0:
            for subscriber in keyword.subscribed_to_digest.all():
                send_async_mail.delay(
                    'Daily update for "{0}" responses'.format(
                        str(keyword)
                    ),
                    "The following text messages have been received today:\n\n{0}".format(
                        "\n".join([str(x) for x in new_responses])
                    ),
                    [subscriber.email]
                )

        keyword.last_email_sent_time = checked_time
        keyword.save()


@task()
def post_to_slack(msg):
    from apostello.models import SiteConfiguration
    config = SiteConfiguration.get_solo()
    url = config.slack_url
    if url:
        data = {'text': msg, 'username': 'apostello', "icon_emoji": ":speech_balloon:"}
        headers = {'Content-type': 'application/json', 'Accept': 'text/plain'}
        requests.post(url, data=json.dumps(data), headers=headers)


# Elvanto import
@task()
def import_elvanto_groups(group_ids, user_email):
    from apostello.elvanto import import_elvanto_groups
    import_elvanto_groups(group_ids, user_email)


# import twilio log
@task()
def import_incoming_sms_task():
    from apostello.logs import import_incoming_sms
    import_incoming_sms()


@task()
def import_outgoing_sms_task():
    from apostello.logs import import_outgoing_sms
    import_outgoing_sms()
