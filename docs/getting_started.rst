Getting Started
===============

Getting an instance of apostello running is fairly simple if you have deployed a Django application before. If not, this guide should help.

TODO: release ansible playbook for deployment

Prerequisites
-------------

* Twilio account with a purchased number
* *Optional:* A web app registered for authentication with a Google account
* *Optional:* An SMTP server or Mailgun, Madrill, etc account for sending email notifications
* *Optional:* An Elvanto API Key for importing Elvanto groups


Server Setup
------------

Ubuntu is recommended (Debian should work too) for this setup guide.

The ansible playbook in the repo is the recommended deployment method - just set up a new 512Mb Digital Ocean droplet and point the playbook at it, then skip to the first run section.

If you would rather proceed manually, then you will need to 

TODO: add manual deploy script/instructions

First Run
---------

After you have successfully set up your copy of apostello you should create a superuser:
  
.. code-block:: bash

  # cd to apostello directory
  # activate virtualenv, etc
  export DJANGO_SETTINGS_MODULE=settings.production
  ./manage.py createsuperuser

* Now visit your running site and set up a new account.
* Once you are in, you may see the not approved screen if you have not whitelisted any domains
* Click on `Users`
* Click on the user account you created through the web site
* Tick the `Staff Status` and `Superuser Status` boxes to give you access to everything, including the admin interface. Scroll down and save your changes.
* *Optional:* delete the admin user you created with `createsuperuser`
* Now you can continue to set up apostello: import contacts, start sending messages, publicise your number, etc


Google Authentication
~~~~~~~~~~~~~~~~~~~~~

If you want to use Google authentication, then you need to follow the steps here.

TODO: link to allauth
