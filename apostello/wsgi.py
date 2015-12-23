# -*- coding: utf-8 -*-
"""
WSGI config for apostello project.

It exposes the WSGI callable as a module-level variable named ``application``.

For more information on this file, see
https://docs.djangoproject.com/en/1.7/howto/deployment/wsgi/
"""
import os

from django.core.wsgi import get_wsgi_application
from django.conf import settings

from apostello.loaddotenv import loaddotenv

loaddotenv()
application = get_wsgi_application()

if os.environ.get('DYNO_RAM') is not None:
    # detect if we are running on heroku and use whitenoise
    from whitenoise.django import DjangoWhiteNoise
    application = DjangoWhiteNoise(application)
