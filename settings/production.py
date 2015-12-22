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

INSTALLED_APPS += ['opbeat.contrib.django', ]
MIDDLEWARE_CLASSES = [
    'opbeat.contrib.django.middleware.OpbeatAPMMiddleware',
].extend(MIDDLEWARE_CLASSES)

OPBEAT = {
    'ORGANIZATION_ID': os.environ.get('OPBEAT_ORG_ID', ''),
    'APP_ID': os.environ.get('OPBEAT_APP_ID', ''),
    'SECRET_TOKEN': os.environ.get('OPBEAT_SECRET_TOKEN', ''),
}

STATIC_ROOT = '/webapps/apostello/static/'
STATICFILES_STORAGE = 'django.contrib.staticfiles.storage.ManifestStaticFilesStorage'

LOGGING = {
    'version': 1,
    'disable_existing_loggers': True,
    'formatters': {
        'verbose': {
            'format': '%(levelname)s %(asctime)s %(module)s %(process)d %(thread)d %(message)s'
        },
    },
    'handlers': {
        'opbeat': {
            'level': 'WARNING',
            'class': 'opbeat.contrib.django.handlers.OpbeatHandler',
        },
        'console': {
            'level': 'DEBUG',
            'class': 'logging.StreamHandler',
            'formatter': 'verbose'
        }
    },
    'loggers': {
        'django.db.backends': {
            'level': 'ERROR',
            'handlers': ['console'],
            'propagate': False,
        },
        'apostello': {
            'level': 'WARNING',
            'handlers': ['opbeat'],
            'propagate': False,
        },
        # Log errors from the Opbeat module to the console (recommended)
        'opbeat.errors': {
            'level': 'ERROR',
            'handlers': ['console'],
            'propagate': False,
        },
    },
}
