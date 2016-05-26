.. _deploy-docker:


Deploying with Docker
=====================

*This deployment option is still experimental, please try it out and get in touch if you run into any issues.*

Deploying with docker is quick and simple with our command line tool.

The docker setup uses caddy as a web server which means that we get automatic SSL for free with no additional setup.

Instructions
~~~~~~~~~~~~

Assuming you already have docker `installed <https://docs.docker.com/engine/installation/>`_.

(Or you can create a new server with Docker ready to go at `Digital Ocean <https://m.do.co/c/4afdc8b5be2e>`_.)

.. code-block:: bash

    . venv/bin/activate
    pip install apostello-cli
    apostello init
    cd apostello
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
    cd apostello # we must run commands in the folder we installed apostello
    apostello upgrade

Demo
~~~~
.. raw:: html
    
    <script type="text/javascript" src="https://asciinema.org/a/9ai6n1hamr14cu2k5ljfccvor.js" id="asciicast-9ai6n1hamr14cu2k5ljfccvor" async></script>
