"""Settings for a heroku deploy."""
import dj_database_url

from .production import *

SECURE_PROXY_SSL_HEADER = ('HTTP_X_FORWARDED_PROTO', 'https')
# add whitenoise to handle static files
MIDDLEWARE_CLASSES = [
    'whitenoise.middleware.WhiteNoiseMiddleware',
] + MIDDLEWARE_CLASSES
STATIC_ROOT = os.path.join(BASE_DIR, 'staticfiles')
STATICFILES_STORAGE = 'whitenoise.storage.CompressedManifestStaticFilesStorage'
# read db url:
DATABASES['default'] = dj_database_url.config()
# use redis as cache backend
CACHES = {
    "default": {
        "BACKEND": "django_redis.cache.RedisCache",
        "LOCATION": os.environ.get('REDIS_URL', ''),
        "OPTIONS": {
            "CLIENT_CLASS": "django_redis.client.DefaultClient",
        }
    }
}
