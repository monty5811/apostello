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

Front End
---------

The front end uses the `Semantic UI <http://semantic-ui.com/>`_ framework.
Assets are compiled with Gulp and webpack.

Assets are stored in ``apostello/assets`` and moved to ``apostello/static/`` on
compilation.

Setup
~~~~~

Install `node <https://nodejs.org>`_ and `gulp <http://gulpjs.com/>`_.

.. code-block:: bash

  # assuming you are in the apostello repo
  cd apostello/assets
  npm install  # this may take a couple of minutes
  npm install semantic-ui

Building the Assets
~~~~~~~~~~~~~~~~~~~

.. code-block:: bash

  # assuming you are in the apostello repo
  cd apostello/assets
  gulp css  # recompile css
  gulp webpack  # recompile js
  gulp  # recompile everything