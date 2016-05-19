web: gunicorn apostello.wsgi:application --log-file -
worker: ./manage.py qcluster --settings=settings.heroku
