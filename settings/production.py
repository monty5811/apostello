# -*- coding: utf-8 -*-
import os

from .common import *

DEBUG = False

ALLOWED_HOSTS = ['*']  # must define this

DATABASES = {'default': {'ENGINE': 'django.db.backends.postgresql_psycopg2',
                         'NAME': os.environ['DATABASE_NAME'],
                         'USER': os.environ['DATABASE_USER'],
                         'PASSWORD': os.environ['DATABASE_PASSWORD'],
                         'HOST': 'localhost',
                         'PORT': '',
                         }
             }

# cache templates in production
TEMPLATES[0]['OPTIONS']['loaders'] = [
    ('django.template.loaders.cached.Loader', [
        'django.template.loaders.filesystem.Loader',
        'django.template.loaders.app_directories.Loader',
    ]),
]

# Only run Opbeat in production
INSTALLED_APPS += (
    'opbeat.contrib.django',
)
OPBEAT = {
    'ORGANIZATION_ID': os.environ.get('OPBEAT_ORG_ID', ''),
    'APP_ID': os.environ.get('OPBEAT_APP_ID', ''),
    'SECRET_TOKEN': os.environ.get('OPBEAT_SECRET_TOKEN', ''),
}
MIDDLEWARE_CLASSES = (
    'opbeat.contrib.django.middleware.OpbeatAPMMiddleware',
) + MIDDLEWARE_CLASSES
