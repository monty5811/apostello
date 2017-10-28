from django.conf import settings
from django.core.exceptions import ValidationError
from django.core.validators import RegexValidator

TWILIO_STOP_WORDS = ("stop", "stopall", "unsubscribe", "cancel", "end", "quit")
TWILIO_START_WORDS = ("start", "yes")
TWILIO_INFO_WORDS = ("help", "info")


def validate_lower(value):
    """Ensure value is all lowercase."""
    if value.lower() != value:
        raise ValidationError('{0} must be all lower case.'.format(value))


def not_twilio_num(value):
    """Ensure value does not match the sending number."""
    from site_config.models import SiteConfiguration
    twilio_num = str(SiteConfiguration.get_solo().twilio_from_num)
    if str(value) == twilio_num:
        raise ValidationError("You cannot add the number from which we send messages. Inception!")


def twilio_reserved(value):
    """Ensure value does not overlap a twilio reserverd keyword."""
    if value.lower() in TWILIO_INFO_WORDS + TWILIO_START_WORDS + TWILIO_STOP_WORDS + ('name', ):
        raise ValidationError('{0} is a reserved keyword, please choose another.'.format(value.lower()))


gsm_validator = RegexValidator(
    '^[\s\w@?£!1$"¥#è?¤é%ù&ì\\ò(Ç)*:Ø+;ÄäøÆ,<LÖlöæ\-=ÑñÅß.>ÜüåÉ/§à¡¿\']+$', message="You can only use GSM characters."
)


def no_overlap_keyword(value):
    """Ensure value does not overlap an existing keyword."""
    from apostello.models import Keyword
    keywords = [str(x) for x in Keyword.objects.all()]
    if value in keywords:
        # if exact match, then we are updating, should validate
        return
    keywords += TWILIO_INFO_WORDS + TWILIO_START_WORDS + TWILIO_STOP_WORDS + ('name', )
    for keyword in keywords:
        if keyword.startswith(value) or value.startswith(keyword):
            raise ValidationError('{0} clashes with {1}, please choose another.'.format(value.lower(), keyword))


def less_than_sms_char_limit(value):
    """Ensure message is less than the maximum character limit."""
    from site_config.models import SiteConfiguration
    s = SiteConfiguration.get_solo()
    sms_char_lim = s.sms_char_limit

    if '%name%' in value:
        # if `%name%` in value, then adjust limit to handle substitutions
        sms_char_lim = sms_char_lim - settings.MAX_NAME_LENGTH + len('%name%')

    if len(value) > sms_char_lim:
        raise ValidationError('You have exceeded the maximum char limit of {0}.'.format(sms_char_lim))


def validate_starts_with_plus(value):
    """Ensure value starts with a `+`."""
    if value.startswith('+'):
        return
    raise ValidationError('Phone numbers must start with a "+".')
