"""Settings used for local development."""
from .common import *

DEBUG = True
INSTALLED_APPS += ['debug_toolbar', ]
INTERNAL_IPS = ('*', )


def show_toolbar(request):
    """Always show the debug toolbar."""
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

# overwrite static files (use white noise instead of runserver)
MIDDLEWARE = [
    'whitenoise.middleware.WhiteNoiseMiddleware',
] + MIDDLEWARE
STATIC_ROOT = BASE_DIR + '/static/'
STATICFILES_STORAGE = 'whitenoise.storage.CompressedManifestStaticFilesStorage'

# overwrite cache backend
import fakeredis
CACHES = {
    "default": {
        "BACKEND": "django_redis.cache.RedisCache",
        "LOCATION": '127.0.0.1:6379',
        "OPTIONS": {
            "REDIS_CLIENT_CLASS": "fakeredis.FakeStrictRedis",
        }
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
        'django': {
            'level': 'INFO',
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
