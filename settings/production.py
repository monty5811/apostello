"""Settings used in production with ansible deploy."""
import os

from .common import *

DEBUG = False

ALLOWED_HOSTS = ['*']  # must define this

DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.postgresql_psycopg2',
        'NAME': os.environ.get('DATABASE_NAME', ''),
        'USER': os.environ.get('DATABASE_USER', ''),
        'PASSWORD': os.environ.get('DATABASE_PASSWORD', ''),
        'HOST': 'localhost',
        'PORT': '',
        'CONN_MAX_AGE': 600,
    }
}

# cache templates in production
TEMPLATES[0]['OPTIONS']['loaders'] = [
    (
        'django.template.loaders.cached.Loader', [
            'django.template.loaders.filesystem.Loader',
            'django.template.loaders.app_directories.Loader',
        ]
    ),
]

STATIC_ROOT = os.path.join(BASE_DIR, '../static/')  # store static files outside deployed git repo
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
        'console': {
            'level': 'DEBUG',
            'class': 'logging.StreamHandler',
            'formatter': 'verbose'
        }
    },
    'loggers': {
        'django': {
            'level': 'ERROR',
            'handlers': ['console'],
            'propagate': False,
        },
        'apostello': {
            'level': 'WARNING',
            'handlers': ['console'],
            'propagate': False,
        },
    },
}

if ROLLBAR_ACCESS_TOKEN is not None:
    MIDDLEWARE = ['rollbar.contrib.django.middleware.RollbarNotifierMiddleware', ] + MIDDLEWARE

    ROLLBAR = {
        'access_token': ROLLBAR_ACCESS_TOKEN,
        'environment': 'development' if DEBUG else 'production',
        'branch': 'master',
        'root':  os.path.join(BASE_DIR, '..'),
    }

    Q_CLUSTER['error_reporter'] = {
        'rollbar': {
            'access_token': ROLLBAR_ACCESS_TOKEN,
            'environment': 'Django-Q'
        }
    }
