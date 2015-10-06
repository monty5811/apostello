# -*- coding: utf-8 -*-
# Build paths inside the project like this: os.path.join(BASE_DIR, ...)
import os

import djcelery

# Django settings
BASE_DIR = os.path.dirname(os.path.dirname(__file__))

SECRET_KEY = os.environ.get('DJANGO_SECRET_KEY',
                            'w;ioufpwqofjpwoifwpa09fuq039uq3u4uepoivqnwjdfvlwdv')

INSTALLED_APPS = (
    # built in apps
    'django.contrib.admin',
    'django.contrib.admindocs',
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.messages',
    'django.contrib.staticfiles',
    # apostello
    'apostello',
    'api',
    'graphs',
    # third party apps
    'rest_framework',
    'social.apps.django_app.default',
    'djcelery',
    'bootstrap3',
    'datetimewidget',
    'compressor',
    'django_extensions',
    'solo',
)

MIDDLEWARE_CLASSES = (
    'debug_toolbar.middleware.DebugToolbarMiddleware',
    'django.contrib.sessions.middleware.SessionMiddleware',
    'django.middleware.common.CommonMiddleware',
    'django.middleware.csrf.CsrfViewMiddleware',
    'django.contrib.auth.middleware.AuthenticationMiddleware',
    'django.contrib.auth.middleware.SessionAuthenticationMiddleware',
    'django.contrib.messages.middleware.MessageMiddleware',
    'django.middleware.clickjacking.XFrameOptionsMiddleware',
)

TEMPLATE_CONTEXT_PROCESSORS = (
    'social.apps.django_app.context_processors.backends',
    'social.apps.django_app.context_processors.login_redirect',
    "django.core.context_processors.request",
    'django.core.context_processors.static',
    'django.contrib.auth.context_processors.auth',
    'django.contrib.messages.context_processors.messages',
    'apostello.context_processors.global_settings',
)

STATICFILES_FINDERS = (
    'django.contrib.staticfiles.finders.FileSystemFinder',
    'django.contrib.staticfiles.finders.AppDirectoriesFinder',
    # other finders..
    'compressor.finders.CompressorFinder',
)

STATIC_URL = '/static/'
STATICFILES_STORAGE = 'django.contrib.staticfiles.storage.StaticFilesStorage'
STATIC_ROOT = '/webapps/apostello/static/'

AUTHENTICATION_BACKENDS = (
    'django.contrib.auth.backends.ModelBackend',
    'social.backends.google.GoogleOAuth2',
)

ROOT_URLCONF = 'apostello.urls'
WSGI_APPLICATION = 'apostello.wsgi.application'
LANGUAGE_CODE = 'en-gb'
TIME_ZONE = 'GMT'
USE_I18N = True
USE_L10N = True
USE_TZ = True

# session settings
SESSION_ENGINE = 'django.contrib.sessions.backends.cached_db'

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
    vhost=os.environ.get('RABBITMQ_APPLICATION_VHOST'))

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
    ]
}

# email settings
EMAIL_USE_TLS = True
EMAIL_HOST = os.environ.get('DJANGO_EMAIL_HOST', 'smtp.mailgun.org')
EMAIL_HOST_USER = os.environ.get('DJANGO_EMAIL_HOST_USER', '')
EMAIL_HOST_PASSWORD = os.environ.get('DJANGO_EMAIL_HOST_PASSWORD', '')
EMAIL_PORT = 587

# social login settings
SOCIAL_AUTH_URL_NAMESPACE = 'social'
SOCIAL_AUTH_LOGIN_REDIRECT_ULR = '/'
SOCIAL_AUTH_MODEL = 'apostello'
SOCIAL_AUTH_USER_MODEL = 'auth.User'
SOCIAL_AUTH_STRATEGY = 'social.strategies.django_strategy.DjangoStrategy'

LOGIN_URL = '/login/google-oauth2'
LOGIN_ERROR_URL = '/'
LOGIN_REDIRECT_URL = '/'

SOCIAL_AUTH_GOOGLE_OAUTH2_KEY = os.environ['SOCIAL_AUTH_GOOGLE_OAUTH2_KEY']
SOCIAL_AUTH_GOOGLE_OAUTH2_SECRET = os.environ['SOCIAL_AUTH_GOOGLE_OAUTH2_SECRET']
SOCIAL_AUTH_GOOGLE_OAUTH2_WHITELISTED_DOMAINS = os.environ['SOCIAL_AUTH_GOOGLE_OAUTH2_WHITELISTED_DOMAINS'].split(',')
SOCIAL_AUTH_GOOGLE_OAUTH2_WHITELISTED_EMAILS = os.environ['SOCIAL_AUTH_GOOGLE_OAUTH2_WHITELISTED_EMAILS'].split(',')

# Elvanto credentials
ELVANTO_KEY = os.environ['ELVANTO_KEY']

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

NO_ACCESS_WARNING = 'You do not have access to this page. If you believe you are seeing it in error please contact the office'

# Notification settings
SLACK_URL = os.environ.get('SLACK_URL', '')

# Testing
TESTING = False
