# -*- coding: utf-8 -*-
"""Common settings module."""
# Build paths inside the project like this: os.path.join(BASE_DIR, ...)
import os

import djcelery

# Django settings
BASE_DIR = os.path.dirname(os.path.dirname(__file__))

SECRET_KEY = os.environ.get(
    'DJANGO_SECRET_KEY', 'w;ioufpwqofjpwoifwpa09fuq039uq3u4uepoivqnwjdfvlwdv'
)

INSTALLED_APPS = [
    # built in apps
    'django.contrib.admin',
    'django.contrib.admindocs',
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.sites',
    'django.contrib.messages',
    'django.contrib.staticfiles',
    # apostello
    'apostello.apps.ApostelloConfig',
    'api',
    'elvanto',
    'graphs',
    'site_config',
    # third party apps
    'rest_framework',
    'djcelery',
    'semanticuiform',
    'django_extensions',
    'solo',
    'django_twilio',
    # auth
    'allauth',
    'allauth.account',
    'allauth.socialaccount',
    'allauth.socialaccount.providers.google',
]

SITE_ID = 1

MIDDLEWARE_CLASSES = [
    'django.contrib.sessions.middleware.SessionMiddleware',
    'django.middleware.common.CommonMiddleware',
    'django.middleware.csrf.CsrfViewMiddleware',
    'django.contrib.auth.middleware.AuthenticationMiddleware',
    'django.contrib.auth.middleware.SessionAuthenticationMiddleware',
    'django.contrib.messages.middleware.MessageMiddleware',
    'django.middleware.clickjacking.XFrameOptionsMiddleware',
]

TEMPLATES = [
    {
        'BACKEND': 'django.template.backends.django.DjangoTemplates',
        'OPTIONS': {
            'context_processors': [
                "django.template.context_processors.request",
                'django.template.context_processors.static',
                'django.contrib.auth.context_processors.auth',
                'django.contrib.messages.context_processors.messages',
                'apostello.context_processors.global_settings',
                'apostello.context_processors.opbeat_js_settings',
            ],
            'loaders': [
                'django.template.loaders.filesystem.Loader',
                'django.template.loaders.app_directories.Loader',
            ],
        },
    },
]

STATICFILES_FINDERS = [
    'django.contrib.staticfiles.finders.FileSystemFinder',
    'django.contrib.staticfiles.finders.AppDirectoriesFinder',
]

STATIC_URL = '/static/'
STATICFILES_STORAGE = 'django.contrib.staticfiles.storage.StaticFilesStorage'
STATIC_ROOT = os.path.join(BASE_DIR, 'static')

AUTHENTICATION_BACKENDS = [
    'django.contrib.auth.backends.ModelBackend',
    'allauth.account.auth_backends.AuthenticationBackend',
]

ROOT_URLCONF = 'apostello.urls'
WSGI_APPLICATION = 'apostello.wsgi.application'
LANGUAGE_CODE = 'en-gb'
TIME_ZONE = 'GMT'
USE_I18N = True
USE_L10N = True
USE_TZ = True

# session settings
SESSION_ENGINE = 'django.contrib.sessions.backends.cached_db'
MESSAGE_STORAGE = 'django.contrib.messages.storage.session.SessionStorage'

# Celery settings
CELERY_DISABLE_RATE_LIMITS = True
CELERY_TIMEZONE = 'Europe/London'
CELERYBEAT_SCHEDULER = 'djcelery.schedulers.DatabaseScheduler'
CELERY_IGNORE_RESULT = True
CELERY_ACCEPT_CONTENT = ['pickle']

# rabbit MQ settings
djcelery.setup_loader()
BROKER_URL = 'amqp://{user}:{password}@127.0.0.1:5672/{vhost}'.format(
    user=os.environ.get('RABBITMQ_APPLICATION_USER'),
    password=os.environ.get('RABBITMQ_APPLICATION_PASSWORD'),
    vhost=os.environ.get('RABBITMQ_APPLICATION_VHOST')
)

# Cache settings
CACHES = {
    'default': {
        'BACKEND': 'django.core.cache.backends.memcached.MemcachedCache',
        'LOCATION': '127.0.0.1:11211',
    }
}

REST_FRAMEWORK = {
    # Use Django's standard `django.contrib.auth` permissions,
    # or allow read-only access for unauthenticated users.
    'DEFAULT_PERMISSION_CLASSES': [
        'rest_framework.permissions.DjangoModelPermissions'
    ],
    'DEFAULT_PAGINATION_CLASS':
    'rest_framework.pagination.PageNumberPagination',
}

# email settings
EMAIL_USE_TLS = True
EMAIL_HOST = os.environ.get('DJANGO_EMAIL_HOST', 'smtp.mailgun.org')
EMAIL_HOST_USER = os.environ.get('DJANGO_EMAIL_HOST_USER', '')
EMAIL_HOST_PASSWORD = os.environ.get('DJANGO_EMAIL_HOST_PASSWORD', '')
EMAIL_FROM = os.environ.get('DJANGO_FROM_EMAIL')
EMAIL_PORT = 587

# social login settings
ACCOUNT_AUTHENTICATION_METHOD = 'email'
ACCOUNT_EMAIL_REQUIRED = True
ACCOUNT_EMAIL_VERIFICATION = 'mandatory'
ACCOUNT_USERNAME_REQUIRED = False
ACCOUNT_DEFAULT_HTTP_PROTOCOL = os.environ.get(
    'ACCOUNT_DEFAULT_HTTP_PROTOCOL', 'http'
)
WHITELISTED_LOGIN_DOMAINS = os.environ.get(
    'WHITELISTED_LOGIN_DOMAINS', ''
).split(',')

LOGIN_REDIRECT_URL = '/'

# Elvanto credentials
ELVANTO_KEY = os.environ.get('ELVANTO_KEY', '')

# Twilio credentials
TWILIO_ACCOUNT_SID = os.environ['TWILIO_ACCOUNT_SID']
TWILIO_AUTH_TOKEN = os.environ['TWILIO_AUTH_TOKEN']
TWILIO_FROM_NUM = os.environ['TWILIO_FROM_NUM']

# Sms settings - note that messages over 160 will be charged twice
MAX_NAME_LENGTH = 16
SMS_CHAR_LIMIT = 160 - MAX_NAME_LENGTH + len('{name}')
SENDING_COST = 0.04  # cost in USD
# Used for nomalising elvanto imports, use twilio to limit sending to
# particular countries:
# https://www.twilio.com/help/faq/voice/what-are-global-permissions-and-why-do-they-exist
COUNTRY_CODE = os.environ['COUNTRY_CODE']

NO_ACCESS_WARNING = 'You do not have access to this page. '
'If you believe you are seeing it in error please contact the office'

# Testing
TESTING = False

# opbeat django:
OPBEAT = {
    'ORGANIZATION_ID': os.environ.get('OPBEAT_ORG_ID', ''),
    'APP_ID': os.environ.get('OPBEAT_APP_ID', ''),
    'SECRET_TOKEN': os.environ.get('OPBEAT_SECRET_TOKEN', ''),
}
# opbeat js:
OPBEAT_JS_APP_ID = os.environ.get('OPBEAT_APP_ID')
OPBEAT_JS_ORG_ID = os.environ.get('OPBEAT_JS_ORG_ID')
