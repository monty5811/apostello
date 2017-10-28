import json

from django import template
from django.conf import settings
from django.contrib.messages import get_messages
from django.core.cache import cache
from django.urls import reverse
from django.utils.safestring import mark_safe

from api.serializers import UserProfileSerializer
from apostello.models import Keyword, UserProfile
from site_config.models import ConfigurationError, SiteConfiguration

register = template.Library()


@register.simple_tag
def elm_settings(user):
    try:
        profile = user.profile
    except AttributeError:
        profile = UserProfile.nullProfile()

    config = SiteConfiguration.get_solo()
    try:
        twilio_settings = config.get_twilio_settings()
        # remove sensitive settings:
        del twilio_settings['auth_token']
        del twilio_settings['sid']
    except ConfigurationError:
        twilio_settings = None

    bk_key = f'blocked_keywords_user_{user.pk}'
    blocked_keywords = cache.get(bk_key)
    if blocked_keywords is None:
        blocked_keywords = [
            x.keyword for x in Keyword.objects.all().prefetch_related('owners') if not x.can_user_access(user)
        ]
        cache.set(bk_key, blocked_keywords, 120)

    elm = {
        'userPerms': UserProfileSerializer(profile).data,
        'twilio': twilio_settings,
        'isEmailSetup': config.is_email_setup(),
        'smsCharLimit': config.sms_char_limit,
        'defaultNumberPrefix': config.default_number_prefix,
        'noAccessMessage': config.not_approved_msg,
        'blockedKeywords': blocked_keywords,
    }
    return mark_safe(json.dumps(elm))


@register.simple_tag
def gcm_sender_id():
    return settings.CM_SENDER_ID
