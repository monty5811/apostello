# -*- coding: utf-8 -*-
"""
WSGI config for apostello project.

It exposes the WSGI callable as a module-level variable named ``application``.

For more information on this file, see
https://docs.djangoproject.com/en/1.7/howto/deployment/wsgi/
"""
import os

from django.core.wsgi import get_wsgi_application

from apostello.loaddotenv import loaddotenv

if os.environ.get('DYNO_RAM') is None:
    loaddotenv()

application = get_wsgi_application()
