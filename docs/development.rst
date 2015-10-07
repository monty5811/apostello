Development
===========

Pull requests are encouraged. Please open an issue before working on anything other than minor bug fixes.


Local Set Up
------------

Getting a local instance running is pretty simple:

.. code-block:: bash

  git clone https://github.com/monty5811/apostello.git
  cd apostello
  virtualenv-3.4 venv
  . venv/bin/activate
  pip install -r requirements
  cp .env.example .env # Fill in .env
  export DJANGO_SETTINGS_MODULE=settings.dev
  ./manage.py migrate
  ./manage.py runserver 0.0.0.0:8000

TODO: add Twilio and Google info
