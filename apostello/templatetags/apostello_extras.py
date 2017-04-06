import json

from django import template
from django.conf import settings
from django.contrib.messages import get_messages
from django.urls import reverse
from django.utils.safestring import mark_safe

from api.serializers import UserProfileSerializer
from apostello.models import Keyword, UserProfile
from site_config.models import SiteConfiguration

register = template.Library()


@register.simple_tag
def elm_settings(user):
    try:
        profile = user.profile
    except AttributeError:
        profile = UserProfile.nullProfile()

    config = SiteConfiguration.get_solo()
    elm = {
        'userPerms': UserProfileSerializer(profile).data,
        'twilioSendingCost': settings.TWILIO_SENDING_COST,
        'twilioFromNumber': settings.TWILIO_FROM_NUM,
        'smsCharLimit': config.sms_char_limit,
        'noAccessMessage': config.not_approved_msg,
        'blockedKeywords': [
            x.keyword for x in Keyword.objects.all()
            if x.is_locked and not x.can_user_access(user)
        ],
    }
    return mark_safe(json.dumps(elm))


@register.simple_tag
def elm_messages(request):
    storage = get_messages(request)
    data = [{'type_': message.tags, 'text': str(message)} for message in storage]
    return mark_safe(json.dumps(data))
