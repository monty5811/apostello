import logging

from django.http import HttpResponse
from twilio.twiml.messaging_response import MessagingResponse

from apostello.reply import InboundSms
from apostello.twilio import twilio_view
from site_config.models import SiteConfiguration

logger = logging.getLogger("apostello")


@twilio_view
def sms(request):
    """
    Handle all incoming messages from Twilio.

    This is the start of the message processing pipeline.
    """
    logger.info("Received new sms")
    r = MessagingResponse()
    msg = InboundSms(request.POST)
    msg.start_bg_tasks()

    config = SiteConfiguration.get_solo()
    if msg.reply and not config.disable_all_replies:
        logger.info("Add reply (%s) to response", msg.reply)
        r.message(msg.reply)

    logger.info("Return response to Twilio")
    return HttpResponse(str(r), content_type="application/xml")
