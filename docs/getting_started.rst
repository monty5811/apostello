.. _getting-started:

Getting Started
===============

There are a number of ways you can deploy apostello:

* On your server using the :ref:`ansible playbook <deploy-ansible>` included in the repo
* One click :ref:`Heroku <deploy-heroku>` deploy
* Manually on your own server, you will need to setup a message broker, a database, a web server and the django app and celery background worker. If you have deployed a Django app before, then you should be able to do this

Prerequisites
-------------

* *Required*: A domain name and a server (or you can use Heroku instead)
* *Required*: A `Twilio <https://www.twilio.com/>`_ account with a purchased number
* *Required*: An SMTP server or `Mailgun <https://www.mailgun.com/>`_, `Mandrill <https://mandrillapp.com/>`_, etc account for sending email
notifications
* *Optional*: A web app registered for authentication with a Google account
* *Optional*: An `Elvanto <https://www.elvanto.com/r_Y7HXKNE6>`_ API Key for importing Elvanto groups
* *Optional*: An `opbeat <https://opbeat.com/>`_ account for error logging

First Run
---------

After you have successfully installed apostello there are a few more steps to
finish setup.

First, setup a superuser in apostello:

.. code-block:: bash
  
  # if using the ansible playbook or your own machine:
  # ssh into your machine
  cd /webapps/apostello
  . venv/bin/activate # activate virtualenv, etc
  export DJANGO_SETTINGS_MODULE=settings.production
  cd apostello
  ./manage.py createsuperuser # (leave email blank)

  # if using heroku:
  heroku run ./manage.py createsuperuser # (leave email blank)

* Now visit the admin site: if your instance of apostello is at example.com, go to `example.com/admin`
* Sign in with your super user account
* Edit any settings and default responses you wish by clicking on the Site Configuration and Default Responses links TODO: link to docs
* If you want to let users sign in with Google, then you need to follow the steps `here <https://django-allauth.readthedocs.org/en/stable/providers.html#google>`_.
* When you are done, sign out of the admin site and click `View Site` at the top of the page
* Now set up a new user account
* You should receive a verification email in your inbox
* Verify your email to gain access
* Once you are in, you may see the not approved screen if you have not whitelisted any domains, you will have to return to the admin panel to authorise your email:
  * Sign out of your new account (menu on the top right of the screen)
  * Return to the admin panel and log in with the superuser account
  * Click on `Users`
  * Click on the user account you created through the site
  * Tick the `Staff Status` and `Superuser Status` boxes to give your account access to everything, including the admin interface. Scroll down and save your changes.
  * *Optional:* delete the admin user you created with `createsuperuser`. You should no longer need this account, so you can delete it. (you can always create a new one later if neccessary)
* Log out of the admin panel and return the normal site
* Log in with your user account again
* Now you need to :ref:`setup Twilio <setup-twilio>`
* Now you can continue to set up apostello: import contacts, start sending messages, publicise your number, etc
* Any future users will be able to use the sign up page. If you do not whitelist any domains, you will need to approve new users before they can do anything


.. _setup-twilio:

Twilio Setup
============

Once you have apostello setup we need to tell Twilio what url to talk to when
it receives an SMS:

* Open https://www.twilio.com/user/account/messaging/phone-numbers
* Click the number you are using in apostello and a popup should appear
* Click the "Messaging" tab if it is not already selected
* Select "Configure with URL"
* Ensure the HTTP method is set to `POST`
* In the "Request URL field" add the url to your server, followed by "/sms/". If you are using Heroku it may look like `https://apostello-demo.herokuapp.com/sms/` or if your site is hosted at `https://sms.example.com`, your URL would be `https://sms.example.com/sms`.
* Click save

Now you should be able to test your setup - send a message to your number and you should receive an automated reply. If not, raise an `issue <https://github.com/monty5811/apostello/issues/new?title=[Setup%20Help]>`_ or get in touch on `slack <http://chat.church.io>`_.
