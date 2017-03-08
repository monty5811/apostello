import logging

from django_twilio.decorators import twilio_view
from twilio import twiml

from apostello.reply import InboundSms
from site_config.models import SiteConfiguration

logger = logging.getLogger('apostello')


@twilio_view
def sms(request):
    """
    Handle all incoming messages from Twilio.

    This is the start of the message processing pipeline.
    """
    logger.info('Received new sms')
    r = twiml.Response()
    msg = InboundSms(request.POST)
    msg.start_bg_tasks()

    config = SiteConfiguration.get_solo()
    if msg.reply and not config.disable_all_replies:
        logger.info('Add reply (%s) to response', msg.reply)
        r.message(msg.reply)

    logger.info('Return response to Twilio')
    return r
