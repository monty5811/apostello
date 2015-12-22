# -*- coding: utf-8 -*-
from django.conf import settings


def global_settings(request):
    """Expose TWILIO_FROM_NUM and DEBUG in templates."""
    return {'TWILIO_FROM_NUM': settings.TWILIO_FROM_NUM,
            'DEBUG': settings.DEBUG}
