# -*- coding: utf-8 -*-
from .common import *

DEBUG = True

TEMPLATE_DEBUG = True

INSTALLED_APPS += ('debug_toolbar',)
INTERNAL_IPS = ['*']

ALLOWED_HOSTS = ['*']

DATABASES = {'default': {'ENGINE': 'django.db.backends.sqlite3',
                         'NAME': os.path.join(BASE_DIR, 'db.sqlite3'), }
             }


# celery
BROKER_URL = 'amqp://guest:guest@127.0.0.1:5672'
BROKER_BACKEND = 'memory'
CELERY_ALWAYS_EAGER = True

# compress when debug is on:
COMPRESS_ENABLED = True
# overwrite static files
STATIC_ROOT = BASE_DIR + '/static/'

# overwrite cache backend
CACHES = {
    'default': {
        'BACKEND': 'django.core.cache.backends.locmem.LocMemCache',
    }
}

# don't send email, use console instead
EMAIL_BACKEND = 'django.core.mail.backends.console.EmailBackend'
