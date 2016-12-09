import logging

from django.conf import settings
from django.utils import timezone
from django_twilio.client import twilio_client
from twilio.rest.exceptions import TwilioRestException

from apostello.models import Keyword, Recipient, SmsInbound, SmsOutbound

logger = logging.getLogger('apostello')


def handle_incoming_sms(msg):
    """Add incoming sms to log."""
    sms, created = SmsInbound.objects.get_or_create(sid=msg.sid)
    if created:
        check_next_page = True
        sender, s_created = Recipient.objects.get_or_create(number=msg.from_)
        if s_created:
            sender.first_name = 'Unknown'
            sender.last_name = 'Person'
            sender.save()

        sms.content = msg.body
        sms.time_received = timezone.make_aware(
            msg.date_created, timezone.get_current_timezone()
        )
        sms.sender_name = str(sender)
        sms.sender_num = msg.from_
        matched_keyword = Keyword.match(msg.body)
        sms.matched_keyword = str(matched_keyword)
        sms.matched_colour = Keyword.lookup_colour(msg.body)
        sms.matched_link = Keyword.get_log_link(matched_keyword)
        sms.save()
        return check_next_page


def handle_outgoing_sms(msg):
    """Add outgoing sms to log."""
    try:
        sms, created = SmsOutbound.objects.get_or_create(sid=msg.sid)
        if created:
            check_next_page = True
            recip, r_created = Recipient.objects.get_or_create(number=msg.to)
            if r_created:
                recip.first_name = 'Unknown'
                recip.last_name = 'Person'
                recip.save()

            sms.content = msg.body
            sms.time_sent = timezone.make_aware(
                msg.date_sent, timezone.get_current_timezone()
            )
            sms.sent_by = "[Imported]"
            sms.recipient = recip
            sms.save()
            return check_next_page
    except Exception:
        logger.error(
            'Could not import sms.', exc_info=True, extra={'msg': msg}
        )


def fetch_generator(direction):
    """Fetch generator from twilio."""
    if direction == 'in':
        return twilio_client.messages.iter(to_=settings.TWILIO_FROM_NUM)
    if direction == 'out':
        return twilio_client.messages.iter(from_=settings.TWILIO_FROM_NUM)
    return []


def fetch_list(direction, page_id):
    """Fetch list from twilio."""
    if direction == 'in':
        return twilio_client.messages.list(
            page=page_id, page_size=50, to=settings.TWILIO_FROM_NUM
        )
    if direction == 'out':
        return twilio_client.messages.list(
            page=page_id, page_size=50, from_=settings.TWILIO_FROM_NUM
        )
    return []


def check_log(direction, page_id, fetch_all):
    """Abstract check log function."""
    if direction == 'in':
        sms_handler = handle_incoming_sms
    elif direction == 'out':
        sms_handler = handle_outgoing_sms

    check_next_page = False
    if fetch_all:
        # we want to iterate over all the incoming messages
        sms_page = fetch_generator(direction)
    else:
        # we only want to iterate over the most recent messages to begin with
        try:
            sms_page = fetch_list(direction, page_id)
        except TwilioRestException as e:
            if e.msg == "Page number out of range":
                # last page
                return []
            else:
                raise e

    for msg in sms_page:
        check_next_page = sms_handler(msg) or check_next_page

    if fetch_all:
        # have looped over all messages and we are done
        return

    if check_next_page:
        check_log(direction, page_id + 1, fetch_all)


def check_incoming_log(page_id=0, fetch_all=False):
    """
    Check Twilio's logs for messages that have been sent to our number.

    page_id: Twilio log page to start with.
    fetch_all: If set to True, all messages on Twilio will be checked. If False,
    only the first 50 messages will be checked. If a missing message is found in
    these 50, the next 50 will also be checked.
    """
    check_log('in', page_id, fetch_all)


def check_outgoing_log(page_id=0, fetch_all=False):
    """
    Check Twilio's logs for messages that we have sent.

    page_id: Twilio log page to start with.
    fetch_all: If set to True, all messages on Twilio will be checked. If False,
    only the first 50 messages will be checked. If a missing message is found in
    these 50, the next 50 will also be checked.
    """
    check_log('out', page_id, fetch_all)
