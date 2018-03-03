import logging
from datetime import datetime, timedelta

from django.conf import settings
from twilio.base.exceptions import TwilioRestException

from site_config.models import SiteConfiguration

from .models import Keyword, Recipient, SmsInbound, SmsOutbound
from .twilio import get_twilio_client

logger = logging.getLogger('apostello')


def has_expired(dt_):
    d = get_expiry_date()
    if d is None:
        return False
    else:
        return dt_.date() < d


def get_expiry_date():
    config = SiteConfiguration.get_solo()
    exp_date = config.sms_expiration_date
    try:
        roll_date = datetime.today() - timedelta(days=config.sms_rolling_expiration_days)
        roll_date = roll_date.date()
    except TypeError:
        # no rolling expiration
        roll_date = None

    if roll_date is None and exp_date is None:
        # no expiration set
        return None
    elif roll_date is None:
        # no roll date, use expiration date
        delete_date = exp_date
    elif exp_date is None:
        # no expiration date, use roll date
        delete_date = roll_date
    else:
        # both set, use the most recent date of the tow
        delete_date = max([exp_date, roll_date])

    return delete_date


def cleanup_expired_sms():
    """Remove expired messages."""
    d = get_expiry_date()
    if d is not None:
        SmsInbound.objects.filter(time_received__date__lt=d).delete()
        SmsOutbound.objects.filter(time_sent__date__lt=d).delete()


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
            sms.status = msg.status
            sms.save()
    except Exception:
        logger.error('Could not import sms.', exc_info=True, extra={'msg': msg})


def fetch_generator(direction):
    """Fetch generator from twilio."""
    twilio_num = str(SiteConfiguration.get_solo().twilio_from_num)
    if direction == 'in':
        return get_twilio_client().messages.list(to=twilio_num)
    if direction == 'out':
        return get_twilio_client().messages.list(from_=twilio_num)
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
