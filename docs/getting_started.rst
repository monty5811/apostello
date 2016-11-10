.. _getting-started:

Getting Started
===============

There are a number of ways you can deploy apostello:

* One click :ref:`Heroku <deploy-heroku>` deploy
* *Recommended* Using the :ref:`ansible playbook <deploy-ansible>` included in the repo
* One click `Digital Ocean deploy <http://installer.71m.us/install?url=https://github.com/monty5811/apostello>`_

Prerequisites
-------------

* *Required*: A domain name and a server (or you can use Heroku instead).
* *Required*: A `Twilio <https://www.twilio.com/>`_ account with a purchased number.
* *Required*: An SMTP server or `Mailgun <https://www.mailgun.com/>`_, etc account for sending email notifications. You can setup apostello without this, but it will not be able to send emails. See :ref:`Email Setup <email-setup>` for more details.
* *Optional*: A web app registered for authentication with a Google account
* *Optional*: An `Elvanto <https://www.elvanto.com/r_Y7HXKNE6>`_ API Key for importing Elvanto groups.
* *Optional*: An `opbeat <https://opbeat.com/>`_ account for error logging. You can setup opbeat logging on the front and back ends in separate opbeat apps: one for the django app and one for the js front end.

First Run
---------

After you have successfully installed apostello there are a few more steps to finish setup.

* Open your instance of apostello, you will be redirected to the initial setup page
* Here you can check various settings and tokens and test sending an email and an SMS
* If you see an incorrect setting, change it and reload the page to check it has updated
* If you have issues sending an email or SMS, you will be shown the corresponding error message. If you need help, please get in touch
* When you are confident everything is working, use the form at the bottom to create an admin. Note that once you do this, you will lose access to this page
* Once you have created your account, refresh the page and login with you email and password
* Open the `Tools` menu where you can edit the site configuration and some canned responses
* If you want to let users sign in with Google, then you need to follow the steps `here <https://django-allauth.readthedocs.org/en/stable/providers.html#google>`_
* If you need to approve new users, you can use the User Permissions page under the tools menu
* Now you need to :ref:`setup Twilio <setup-twilio>` so you can receive messages
* You can now continue to set up apostello: import contacts, start sending messages, publicise your number, etc
* Any future users will be able to use the normal sign up page. If you do not whitelist any domains, you will need to approve new users manually before they can do anything. Please be extremely careful with the whitelisting setting - if you set it to a domain that you have no control over (e.g ``gmail.com``), then anyone will be able to access your instance of apostello


.. _setup-twilio:

Twilio Setup
------------

Once you have apostello setup we need to tell Twilio what url to talk to when it receives an SMS:

* Open https://www.twilio.com/user/account/messaging/phone-numbers
* Click the number you are using in apostello and a popup should appear
* Click the "Messaging" tab if it is not already selected
* Select "Configure with URL"
* Ensure the HTTP method is set to ``POST``
* In the "Request URL field" add the url to your server, followed by ``/sms/``. If you are using Heroku it may look like ``https://apostello-demo.herokuapp.com/sms/`` or if your site is hosted at ``https://sms.example.com``, your URL would be ``https://sms.example.com/sms``
* Click save

Now you should be able to test your setup - send a message to your number and you should receive an automated reply. If not, raise an `issue <https://github.com/monty5811/apostello/issues/new?title=[Setup%20Help]>`_ or get in touch on `slack <http://chat.church.io>`_.

.. _email-setup:

Email Setup
-----------

Emails are sent for a number of reasons by apostello:

* Email verfication on sign up
* Daily keyword digests
* Warnings and notifications on some events are sent to the "office email"

apostello needs a mail server to send these emails.
We recommend using `Mailgun <https://www.mailgun.com/>`_ which allows you to send 10,000 emails for free each month.

There are two ways to tell apostello about your mail server:

1. Set environment variables. The relevant variables are:

   * ``DJANGO_EMAIL_HOST``
   * ``DJANGO_EMAIL_HOST_PORT``
   * ``DJANGO_EMAIL_HOST_USER``
   * ``DJANGO_EMAIL_HOST_PASSWORD``
   * ``DJANGO_FROM_EMAIL``

2. Use the `Site Configuration` form after getting apostello up and running. **N.B.** These values will override those set as environment variables.

.. _misc-setup:

Misc Setup
----------

The URLs in my emails are incorrect
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

You may need to let apostello know what your domain is.
You can do this by opening ``<your domain>//admin/sites/site/``, click on the first entry and update the domain name field, then click save.

