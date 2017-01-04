.. _deploy-ansible:


Deploying with Ansible
======================

Ansible is a tool to automate deployments.
An ansible playbook to deploy apostello is bundled in the git repo.

In order to use the playbook, you need a server to point it towards.
Additionally, if you want to use Let's Encrypt to obtain an SSL certificate
(enabled by default), you will need a domain that points to your server.

If you do not want to customise the playbook, you should point it at a dedicated
server as it may delete or mess up other configured applications on any server
you point it at. For example, the playbook may overwrite your nginx config.

Instructions
~~~~~~~~~~~~

To run the playbook

.. code-block:: bash

    git clone https://github.com/monty5811/apostello.git
    cd apostello
    # checkout a specific version:
    git checkout |vversion|
    cd ansible
    python2 -m virtualenv venv --no-site-packages
    . venv/bin/activate
    pip install ansible==2.2.0.0
    cp env_vars/example.yml env_vars/my_site_name.yml
    # fill in the credentials in the new yml file
    ansible-vault encrypt my_site_name.yml
    # replace "env_vars/example.yml" in production.yml
    # run the playbook
    ansible-playbook --ask-vault-pass -i [IP or Domain name of server], production.yml

After the playbook finishes you should have your own apostello server - follow
the first run steps on the :ref:`Getting Started <getting-started>` page to
finish.


Let's Encrypt
~~~~~~~~~~~~~

An SSL certificate can be setup by setting ``setup_lets_encrypt`` to ``yes`` in the file ``production.yml``.
This is disabled by default as it seems to fail on brand new setups.
If you want enable this, run the playbook without lets encrypt, then turn the setting on and run the playbook again.
