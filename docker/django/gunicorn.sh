#!/usr/bin/env sh
gunicorn apostello.wsgi:application --log-file - \
    --bind 0.0.0.0:8000 \
    --workers 3 \
    --max-requests $GUNICORN_MAX_REQUESTS \
    --log-level debug
