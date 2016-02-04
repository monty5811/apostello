# -*- coding: utf-8 -*-
from django.conf import settings

from apostello.models import SiteConfiguration


def global_settings(request):
    """Expose TWILIO_FROM_NUM, DEBUG and site config in templates."""
    return {
        'TWILIO_FROM_NUM': settings.TWILIO_FROM_NUM,
        'DEBUG': settings.DEBUG,
        'CONFIG': SiteConfiguration.get_solo(),
    }
