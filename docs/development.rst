Development
===========

Pull requests are encouraged. Please open an issue before working on anything other than minor bug fixes.


Local Set Up
------------

A docker compose config is provided for easy local development.

Instructions:

1. Install docker and docker compose (or docker toolbox on windows)
2. Copy ``.env.example`` to ``.env`` and fill in the values. (You do not need the DB, RabbitMQ or opbeat values)
3. Run ``docker-compose up``
4. In a separate terminal run ``docker-compose run web ./manage.py migrate``
5. Visit 127.0.0.1:4000
6. You can run django management commands by running ``docker-compose run web ./manage.py createsuperuser``

The frontend assets can be found in ``apostello/assets``, here you can see the different gulp tasks, etc.
