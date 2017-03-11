import uuid

from .common import *

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

import warnings
warnings.filterwarnings(
    'error',
    r"DateTimeField .* received a naive datetime",
    RuntimeWarning,
    r'django\.db\.models\.fields',
)
