web: gunicorn apostello.wsgi:application --log-file -
worker: ./manage.py celery worker -E -B -l info --concurrency=1