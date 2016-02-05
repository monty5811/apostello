Getting Started
===============

Getting an instance of apostello running is fairly simple if you have deployed a Django application before. If not, this guide should help.

TODO: release ansible playbook for deployment and add instructions

Prerequisites
-------------

* *Required*: Twilio account with a purchased number
* *Required*: An SMTP server or Mailgun, Madrill, etc account for sending email notifications
* *Optional*: A web app registered for authentication with a Google account
* *Optional*: An Elvanto API Key for importing Elvanto groups


Server Setup
------------

Ubuntu is recommended (Debian should work too) for this setup guide.

The ansible playbook in the repo is the recommended deployment method - you can simply point the playbook at a server and then skip to the first run section.

If you would rather proceed manually, then you will need to

TODO: add manual deploy script/instructions

First Run
---------

After you have successfully set up your copy of apostello you should create a superuser:

.. code-block:: bash

  # ssh into your machine
  # cd to the apostello directory
  # activate virtualenv, etc
  export DJANGO_SETTINGS_MODULE=settings.production
  ./manage.py createsuperuser

* Now visit the admin site, if your instance of apostello is at example.com, go to `example.com/admin`
* Sign in with your super user account
* Edit any settings and default responses you wish by clicking on the Site Configuration and Default Responses links TODO: link to docs
* You can also set up authenitcation with Google now TODO: link to instructions
* When you are done, sign out of the admin site and click `View Site` at the top of the page
* Now set up a new user account
* You should receive a verification email in your inbox
* Verify your email to gain access
* Once you are in, you may see the not approved screen if you have not whitelisted any domains, you will have to return to the admin panel to authorise your email:
  * Sign out of your account (menu on the top right of the screen)
  * Return to the admin panel and log in with your superuser credentials
  * Click on `Users`
  * Click on the user account you created through the site
  * Tick the `Staff Status` and `Superuser Status` boxes to give your account access to everything, including the admin interface. Scroll down and save your changes.
  * *Optional:* delete the admin user you created with `createsuperuser`
* Log out of the admin panel and return the normal site
* Log in with your user account again
* Now you can continue to set up apostello: import contacts, start sending messages, publicise your number, etc


Google Authentication
~~~~~~~~~~~~~~~~~~~~~

If you want to let users sign in with Google, then you need to follow the steps `here <https://django-allauth.readthedocs.org/en/stable/providers.html#google>`_..
