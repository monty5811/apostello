"""Common settings module."""
# Build paths inside the project like this: os.path.join(BASE_DIR, ...)
import os
APPEND_SLASH = True

# Django settings
BASE_DIR = os.path.dirname(os.path.dirname(__file__))

SECRET_KEY = os.environ.get('DJANGO_SECRET_KEY', 'w;ioufpwqofjpwoifwpa09fuq039uq3u4uepoivqnwjdfvlwdv')

INSTALLED_APPS = [
    # built in apps
    'django.contrib.admin',
    'django.contrib.admindocs',
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.sites',
    'whitenoise.runserver_nostatic',
    'django.contrib.staticfiles',
    # apostello
    'apostello.apps.ApostelloConfig',
    'api',
    'elvanto',
    'graphs',
    'site_config',
    # third party apps
    'rest_framework',
    'rest_framework.authtoken',
    'django_extensions',
    'solo',
    'django_redis',
    'django_q',
    'cookielaw',
    # auth
    'allauth',
    'allauth.account',
    'allauth.socialaccount',
    'allauth.socialaccount.providers.google',
]

SITE_ID = 1

MIDDLEWARE = [
    'django.middleware.security.SecurityMiddleware',
    'django.contrib.sessions.middleware.SessionMiddleware',
    'django.middleware.common.CommonMiddleware',
    'django.middleware.csrf.CsrfViewMiddleware',
    'django.contrib.auth.middleware.AuthenticationMiddleware',
    'django.contrib.messages.middleware.MessageMiddleware',
    'django.middleware.clickjacking.XFrameOptionsMiddleware',
    'apostello.middleware.FirstRunRedirect',
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
TIME_ZONE = os.environ.get('DJANGO_TIME_ZONE', 'Europe/London')
USE_I18N = True
USE_L10N = True
USE_TZ = True

# session settings
SESSION_ENGINE = 'django.contrib.sessions.backends.cached_db'
MESSAGE_STORAGE = 'django.contrib.messages.storage.fallback.FallbackStorage'

# Cache settings
CACHES = {
    "default": {
        "BACKEND": "django_redis.cache.RedisCache",
        "LOCATION": '127.0.0.1:6379',
        "OPTIONS": {
            "CLIENT_CLASS": "django_redis.client.DefaultClient",
        }
    }
}

#
Q_CLUSTER = {
    'name': 'apostello',
    'workers': 1,
    'recycle': 250,
    'timeout': 120,
    'compress': True,
    'save_limit': 500,
    'queue_limit': 500,
    'cpu_affinity': 1,
    'label': 'Django Q',
    'django_redis': 'default',
}

REST_FRAMEWORK = {
    # Use Django's standard `django.contrib.auth` permissions,
    # or allow read-only access for unauthenticated users.
    'DEFAULT_PERMISSION_CLASSES': ['rest_framework.permissions.DjangoModelPermissions'],
    'DEFAULT_PAGINATION_CLASS':
    'rest_framework.pagination.PageNumberPagination',
    'DEFAULT_AUTHENTICATION_CLASSES': (
        'rest_framework.authentication.SessionAuthentication',
        'rest_framework.authentication.TokenAuthentication',
    ),
}

# email settings
EMAIL_BACKEND = 'apostello.mail.ApostelloEmailBackend'
EMAIL_USE_TLS = True

# social login settings
ACCOUNT_ADAPTER = 'apostello.account.ApostelloAccountAdapter'
ACCOUNT_AUTHENTICATION_METHOD = 'email'
ACCOUNT_EMAIL_REQUIRED = True
ACCOUNT_EMAIL_VERIFICATION = 'mandatory'
ACCOUNT_USERNAME_REQUIRED = False
ACCOUNT_DEFAULT_HTTP_PROTOCOL = os.environ.get('ACCOUNT_DEFAULT_HTTP_PROTOCOL', 'https')
WHITELISTED_LOGIN_DOMAINS = os.environ.get('WHITELISTED_LOGIN_DOMAINS', '').split(',')

LOGIN_REDIRECT_URL = '/'

# Elvanto credentials
ELVANTO_KEY = os.environ.get('ELVANTO_KEY', '')
# Onebody credentials - if left blank, no syncing will be done, otherwise, data
# is pulled automatically once a day
# details on how to obtain the api key:
# https://github.com/churchio/onebody/wiki/API
ONEBODY_BASE_URL = os.environ.get('ONEBODY_BASE_URL')
ONEBODY_USER_EMAIL = os.environ.get('ONEBODY_USER_EMAIL')
ONEBODY_API_KEY = os.environ.get('ONEBODY_API_KEY')
ONEBODY_WAIT_TIME = 10

# Sms settings - note that messages over 160 will be charged twice
MAX_NAME_LENGTH = 16
SMS_CHAR_LIMIT = 160 - MAX_NAME_LENGTH + len('{name}')
# Used for nomalising elvanto imports, use twilio to limit sending to
# particular countries:
# https://www.twilio.com/help/faq/voice/what-are-global-permissions-and-why-do-they-exist
COUNTRY_CODE = os.environ.get('COUNTRY_CODE', '44')

NO_ACCESS_WARNING = 'You do not have access to that page. ' \
    'If you believe you are seeing it in error please contact the office'

ROLLBAR_ACCESS_TOKEN = os.environ.get('ROLLBAR_ACCESS_TOKEN')
ROLLBAR_ACCESS_TOKEN_CLIENT = os.environ.get('ROLLBAR_ACCESS_TOKEN_CLIENT')

# solo caching:
SOLO_CACHE = 'default'

# cloud messaging server key:
CM_SERVER_KEY = os.environ.get('CM_SERVER_KEY', '')
CM_SENDER_ID = os.environ.get('CM_SENDER_ID', '')

# maximum number of SMS to send to clients from api
# if this is too large it may crash the elm run time
MAX_SMS_N = os.environ.get('MAX_SMS_TO_CLIENT', 5000)
try:
    MAX_SMS_N = int(MAX_SMS_N)
except ValueError:
    MAX_SMS_N = 5000
