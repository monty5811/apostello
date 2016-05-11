.. _deploy-docker:


Deploying with Docker
=====================

Deploying with docker is quick and simple with the command line tool bundled in apostello.

The docker setup uses caddy as a web server which means that we get automatic SSL for free with no setup required.

Instructions
~~~~~~~~~~~~

Assuming you already have docker `installed <https://docs.docker.com/engine/installation/>`_.

(Or you can create a new server with Docker ready to go at `Digital Ocean <https://m.do.co/c/4afdc8b5be2e>`_.)

.. code-block:: bash

    git clone https://github.com/monty5811/apostello.git
    cd apostello
    virtualenv venv
    . venv/bin/activate
    pip install --editable .
    apostello config
    apostello build
    apostello start
    apostello migrate

apostello should now be running.
If your server has a proper host name (i.e. not an IP address) you should see a valid SSL cert on the site.

Follow the first run steps on the :ref:`Getting Started <getting-started>` page to finish your setup.

Future updates are a matter of:

.. code-block:: bash

    . venv/bin/activate
    git pull orgin {version}
    apostello config # only if new config options
    apostello stop
    apostello build
    apostello start
    apostello migrate # only if database schema has changed
