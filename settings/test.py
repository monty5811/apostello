import uuid
import warnings

import fakeredis

from .common import *

if os.environ.get('DATABASE_POSTGRESQL_USERNAME'):
    DATABASES = {
        'default': {
            'ENGINE': 'django.db.backends.postgresql_psycopg2',
            'NAME': 'apostello_test_db',
            'USER': os.environ.get('DATABASE_POSTGRESQL_USERNAME', ''),
            'PASSWORD': os.environ.get('DATABASE_POSTGRESQL_PASSWORD', ''),
            'HOST': 'localhost',
            'PORT': 5432,
            'CONN_MAX_AGE': 0,
        }
    }
else:
    DATABASES = {
        'default': {
            'ENGINE': 'django.db.backends.sqlite3',
            'NAME': os.path.join(BASE_DIR, str(uuid.uuid4()) + '.sqlite3'),
        }
    }

SECRET_KEY = os.environ.get('DJANGO_SECRET_KEY', 'default')
DEBUG = False

TEMPLATES[0]['OPTIONS']['loaders'] = [
    (
        'django.template.loaders.cached.Loader', [
            'django.template.loaders.filesystem.Loader',
            'django.template.loaders.app_directories.Loader',
        ]
    ),
]

ALLOWED_HOSTS = ['testserver']

#
CACHES = {
    "default": {
        "BACKEND": "django_redis.cache.RedisCache",
        "LOCATION": '127.0.0.1:6379',
        "OPTIONS": {
            "REDIS_CLIENT_CLASS": "fakeredis.FakeStrictRedis",
        }
    }
}

Q_CLUSTER = {
    'name': 'apostello_test',
    'cpu_affinity': 1,
    'django_redis': 'default',
    'log_level': 'WARNING',
    'sync': True,
    'testing': True,
}

PASSWORD_HASHERS = ('django.contrib.auth.hashers.MD5PasswordHasher', )

DJANGO_TWILIO_FORGERY_PROTECTION = False

EMAIL_BACKEND = 'django.core.mail.backends.locmem.EmailBackend'
ACCOUNT_DEFAULT_HTTP_PROTOCOL = 'http'

warnings.filterwarnings(
    'error',
    r"DateTimeField .* received a naive datetime",
    RuntimeWarning,
    r'django\.db\.models\.fields',
)
