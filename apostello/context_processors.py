# -*- coding: utf-8 -*-
from django.conf import settings


def global_settings(request):
    # return any necessary values
    return {'TWILIO_FROM_NUM': settings.TWILIO_FROM_NUM,
            'DEBUG': settings.DEBUG}
