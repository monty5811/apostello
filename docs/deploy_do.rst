.. _deploy-do:

Deploying with Digital Ocean One-Click
======================================

Install
~~~~~~~

Assuming you have a `Digital Ocean <https://m.do.co/c/4afdc8b5be2e>`_ account with an SSH key setup, click the following button to deploy apostello:

.. image:: https://img.shields.io/badge/install-Digital%20Ocean-blue.svg
    :target: https://apostello-do-install.netlify.com

This will create a droplet, download apostello and run the :ref:`ansible playbook <deploy-ansible>` to setup apostello.

Once you have an instance running you will need to configure it.

Configuration
~~~~~~~~~~~~~

Log in to your server and edit the config file, updating the file according
to the :ref:`first-run` instructions:

.. code-block:: bash

    nano /home/apostello/apostello-install/ansible/env_vars/example.yml

Then rerun the installer:

.. code-block:: bash

    ./home/apostello/apostello-install/scripts/ansible_install.sh

Upgrading
~~~~~~~~~

To upgrade to a new version of apostello, you need to edit the install script:

.. code-block:: bash

    nano /home/apostello/apostello-install/scripts/ansible_install.sh

and replace `AP_VER=vx.x.x` with a new version, then rerun the install script:

.. code-block:: bash

    ./home/apostello/apostello-install/scripts/ansible_install.sh

Switching to the Ansible Deploy Method
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Having to log in to the droplet to update can be cumbersome.
Since the one-click installer uses the ansible playbook method under the hood,
it is easy to switch by setting up ansible on your own machine.

Set up:

.. code-block:: bash

    # clone apostello:
    git clone https://github.com/monty5811/apostello.git
    cd apostello
    # checkout a specific version:
    git checkout |vversion|
    # create a virtualenv (you need python2 already installed)
    cd ansible
    python2 -m virtualenv venv --no-site-packages
    . venv/bin/activate
    # install ansible
    pip install ansible==2.2.0.0

Now you need to copy your secrets into ``env_vars/example.yml`` (or copy the file from
your existing server).

Run the upgrade:

.. code-block:: bash

    ansible-playbook --ask-vault-pass -i [IP or Domain name of server], production.yml

Subsequent upgrades:

.. code-block:: bash

    cd <path-to-apostello-folder>
    git fetch
    git checkout <version-tag>
    cd ansible
    . venv/bin/activate
    ansible-playbook --ask-vault-pass -i [IP or Domain name of server], production.yml
