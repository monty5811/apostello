# -*- coding: utf-8 -*-
from django.conf import settings
from django.utils import timezone
from django_twilio.client import twilio_client
from twilio.rest.exceptions import TwilioRestException

from apostello.models import Keyword, Recipient, SmsInbound, SmsOutbound


def import_incoming_sms():
    """
    Loops over all incoming messages in Twilio's logs and adds them to our db.
    """
    try:
        sms_page = twilio_client.messages.iter(to_=settings.TWILIO_FROM_NUM)
        for x in sms_page:
            try:
                sms, created = SmsInbound.objects.get_or_create(
                    sid=x.sid,
                    time_received=timezone.now()
                )
                if created:
                    sender, s_created = Recipient.objects.get_or_create(number=x.from_)
                    if s_created:
                        sender.first_name = 'Unknown'
                        sender.last_name = 'Person'
                        sender.save()

                    sms.content = x.body
                    sms.time_received = timezone.make_aware(x.date_sent, timezone.get_current_timezone())
                    sms.sender_name = str(sender)
                    sms.sender_num = x.from_
                    matched_keyword = Keyword.match(x.body)
                    sms.matched_keyword = str(matched_keyword)
                    sms.matched_colour = Keyword.lookup_colour(x.body)
                    sms.matched_link = Keyword.get_log_link(matched_keyword)
                    sms.save()
            except Exception as e:
                print(e)

    except TwilioRestException as e:
        if e.code == 20008:
            return 'test credentials used'


def import_outgoing_sms():
    """
    Loops over all outgoing messages in Twilio's logs and adds them to our db.
    """
    try:
        sms_page = twilio_client.messages.iter(from_=settings.TWILIO_FROM_NUM)
        for x in sms_page:
            try:
                sms, created = SmsOutbound.objects.get_or_create(sid=x.sid)
                if created:
                    recip, r_created = Recipient.objects.get_or_create(number=x.to)
                    if r_created:
                        recip.first_name = 'Unknown'
                        recip.last_name = 'Person'
                        recip.save()

                    sms.content = x.body
                    sms.time_sent = timezone.make_aware(x.date_sent, timezone.get_current_timezone())
                    sms.sent_by = "Unknown - imported"
                    sms.recipient = recip
                    sms.save()
            except Exception as e:
                print(e)

    except TwilioRestException as e:
        if e.code == 20008:
            return 'test credentials used'
