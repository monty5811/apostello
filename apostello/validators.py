# -*- coding: utf-8 -*-
from django.conf import settings
from django.core.exceptions import ValidationError
from django.core.validators import RegexValidator

TWILIO_STOP_WORDS = ("stop", "stopall", "unsubscribe", "cancel", "end", "quit")
TWILIO_START_WORDS = ("start", "yes")
TWILIO_INFO_WORDS = ("help", "info")


def validate_lower(value):
    if value.lower() != value:
        raise ValidationError('%s must be all lower case.' % value)


def not_twilio_num(value):
    if str(value) == str(settings.TWILIO_FROM_NUM):
        raise ValidationError("You cannot add the number from which we send messages. Inception!")


def twilio_reserved(value):
    if value.lower() in TWILIO_INFO_WORDS + TWILIO_START_WORDS + TWILIO_STOP_WORDS + ('name',):
        raise ValidationError('%s is a reserved keyword, please choose another.' % value.lower())


gsm_validator = RegexValidator('^[\s\w@?£!1$"¥#è?¤é%ù&ì\\ò(Ç)*:Ø+;ÄäøÆ,<LÖlöæ\-=ÑñÅß.>ÜüåÉ/§à¡¿\']+$',
                               message="You can only use GSM characters.")


def no_overlap_keyword(value):
    from apostello.models import Keyword
    keywords = [str(x) for x in Keyword.objects.all()]
    if value in keywords:
        # if exact match, then we are updating, should validate
        return
    keywords += TWILIO_INFO_WORDS + TWILIO_START_WORDS + TWILIO_STOP_WORDS + ('name',)
    for keyword in keywords:
        if keyword.startswith(value) or value.startswith(keyword):
            raise ValidationError('%s clashes with %s, please choose another.' % (value.lower(), keyword))


def less_than_sms_char_limit(value):
    from apostello.models import SiteConfiguration
    s = SiteConfiguration.get_solo()
    sms_char_lim = s.sms_char_limit - settings.MAX_NAME_LENGTH + len('%name%')
    if len(value) > sms_char_lim:
        raise ValidationError('You have exceed the maximum char limit of %i.' % (sms_char_lim))
