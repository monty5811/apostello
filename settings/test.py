# -*- coding: utf-8 -*-
import djcelery

from .common import *

TESTING = True

# SECURITY WARNING: keep the secret key used in production secret!
SECRET_KEY = os.environ.get('DJANGO_SECRET_KEY', 'default')

# SECURITY WARNING: don't run with debug turned on in production!
DEBUG = False

TEMPLATES[0]['OPTIONS']['loaders'] = [
    ('django.template.loaders.cached.Loader', [
        'django.template.loaders.filesystem.Loader',
        'django.template.loaders.app_directories.Loader',
    ]),
]

ALLOWED_HOSTS = []

DATABASES = {'default': {'ENGINE': 'django.db.backends.sqlite3'}}

# celery - use test runner
djcelery.setup_loader()

BROKER_BACKEND = 'memory'
TEST_RUNNER = 'djcelery.contrib.test_runner.CeleryTestSuiteRunner'
CELERY_ALWAYS_EAGER = True

PASSWORD_HASHERS = (
    'django.contrib.auth.hashers.MD5PasswordHasher',
)

DJANGO_TWILIO_FORGERY_PROTECTION = False

EMAIL_BACKEND = 'django.core.mail.backends.console.EmailBackend'
