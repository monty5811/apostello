import logging

from django.conf import settings
from twilio.base.exceptions import TwilioRestException

from .models import Keyword, Recipient, SmsInbound, SmsOutbound
from .twilio import twilio_client
from site_config.models import SiteConfiguration

logger = logging.getLogger('apostello')


def has_expired(datetime):
    config = SiteConfiguration.get_solo()
    if config.sms_expiration_date is None:
        return False
    else:
        return datetime.date() < config.sms_expiration_date


def cleanup_expired_sms():
    """Remove expired messages."""
    config = SiteConfiguration.get_solo()
    if config.sms_expiration_date is None:
        # no expiration, skip checks
        return
    for sms in SmsInbound.objects.filter(time_received__date__lt=config.sms_expiration_date):
        sms.delete()
    for sms in SmsOutbound.objects.filter(time_sent__date__lt=config.sms_expiration_date):
        sms.delete()


def handle_incoming_sms(msg):
    """Add incoming sms to log."""
    if has_expired(msg.date_created):
        return
    sms, created = SmsInbound.objects.get_or_create(sid=msg.sid)
    if created:
        sender, s_created = Recipient.objects.get_or_create(number=msg.from_)
        if s_created:
            sender.first_name = 'Unknown'
            sender.last_name = 'Person'
            sender.save()

        sms.content = msg.body
        sms.time_received = msg.date_created
        sms.sender_name = str(sender)
        sms.sender_num = msg.from_
        matched_keyword = Keyword.match(msg.body)
        sms.matched_keyword = str(matched_keyword)
        sms.matched_colour = Keyword.lookup_colour(msg.body)
        sms.matched_link = Keyword.get_log_link(matched_keyword)
        sms.save()


def handle_outgoing_sms(msg):
    """Add outgoing sms to log."""
    if has_expired(msg.date_sent):
        return
    try:
        sms, created = SmsOutbound.objects.get_or_create(sid=msg.sid)
        if created:
            recip, r_created = Recipient.objects.get_or_create(number=msg.to)
            if r_created:
                recip.first_name = 'Unknown'
                recip.last_name = 'Person'
                recip.save()

            sms.content = msg.body
            sms.time_sent = msg.date_sent
            sms.sent_by = "[Imported]"
            sms.recipient = recip
            sms.save()
    except Exception:
        logger.error('Could not import sms.', exc_info=True, extra={'msg': msg})


def fetch_generator(direction):
    """Fetch generator from twilio."""
    if direction == 'in':
        return twilio_client.messages.list(to=settings.TWILIO_FROM_NUM)
    if direction == 'out':
        return twilio_client.messages.list(from_=settings.TWILIO_FROM_NUM)
    return []


def check_log(direction):
    """Abstract check log function."""
    if direction == 'in':
        sms_handler = handle_incoming_sms
    elif direction == 'out':
        sms_handler = handle_outgoing_sms

    # we want to iterate over all the incoming messages
    sms_page = fetch_generator(direction)

    for msg in sms_page:
        sms_handler(msg)


def check_incoming_log():
    """Check Twilio's logs for messages that have been sent to our number."""
    check_log('in')


def check_outgoing_log():
    """Check Twilio's logs for messages that we have sent."""
    check_log('out')
