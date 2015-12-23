web: gunicorn apostello.wsgi --log-file -
worker: ./manage.py celery worker -E -B -l info --concurrency=1