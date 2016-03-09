"""Settings used for local development."""
from .common import *

DEBUG = True
INSTALLED_APPS += ['debug_toolbar', ]
INTERNAL_IPS = ('*', )


def show_toolbar(request):
    return True


DEBUG_TOOLBAR_CONFIG = {"SHOW_TOOLBAR_CALLBACK": show_toolbar, }

TEMPLATES[0]['OPTIONS']['debug'] = True

ALLOWED_HOSTS = ['*']

DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.sqlite3',
        'NAME': os.path.join(BASE_DIR, 'db.sqlite3'),
    }
}

# celery
BROKER_URL = 'amqp://guest:guest@127.0.0.1:5672'

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

# logging
LOGGING = {
    'version': 1,
    'disable_existing_loggers': True,
    'formatters': {
        'verbose': {
            'format':
            '[%(asctime)s][%(levelname)s][%(module)s.py][%(process)d][%(thread)d] %(message)s'
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
        'django.db.backends': {
            'level': 'ERROR',
            'handlers': ['console'],
            'propagate': False,
        },
        'apostello': {
            'level': 'DEBUG',
            'handlers': ['console'],
            'propagate': False,
        },
    },
}
