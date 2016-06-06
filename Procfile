web: gunicorn apostello.wsgi:application --log-file -
worker: python manage.py qcluster --settings=settings.heroku
