.. _getting-started:

Getting Started
===============

There are a number of ways you can deploy apostello:

* **Recommended**: Using the :ref:`ansible playbook <deploy-ansible>` included in the repo
* One click :ref:`Heroku <deploy-heroku>` deploy
* One click :ref:`Digital Ocean <deploy-do>` deploy

Prerequisites
-------------

* *Required*: A domain name and a server (or you can use Heroku instead).
* *Required*: A `Twilio <https://www.twilio.com/>`_ account with a purchased number.
* *Required*: An SMTP server or `Mailgun <https://www.mailgun.com/>`_, etc account for sending email notifications. You can setup apostello without this, but it will not be able to send emails. See :ref:`Email Setup <email-setup>` for more details.
* *Optional*: A web app registered for authentication with a Google account
* *Optional*: An `Elvanto <https://www.elvanto.com/r_Y7HXKNE6>`_ API Key for importing Elvanto groups.
* *Optional*: A `rollbar <https://rollbar.com/>`_ account for error logging.

.. _first-run:

First Run
---------

After you have successfully installed apostello there are a few more steps to finish setup.

* Open your instance of apostello, you will be redirected to the initial setup page
* This page lets you create a new admin user.
* You can check various settings. If somthing doesn't look right change the setting and reload the page to check it has updated
* If you have issues sending an email or SMS, you will be shown the corresponding error message. If you need help, please get in touch
* Once you have created your account, refresh the page and login with you email and password
* You can now continue to set up apostello: import contacts, start sending messages, publicise your number, etc

Configuration
~~~~~~~~~~~~~

Once you have successfully logged in, navigate to the Site Configuration page (click the menu button, then Site Configuration).
There are various settings on this page, but the first thing to do is to configure Twilio and email.

* Just fill in your credentials and submit the form
* Now you need to :ref:`setup Twilio <setup-twilio>` so you can receive messages
* You can also test your setup using the link provided

Other options:

* You can edit the default responses by going to `Menu -> Defaault Responses`
* If you want to let users sign in with Google, then you need to follow the steps `here <https://django-allauth.readthedocs.org/en/stable/providers.html#google>`_
* Any future users will be able to use the normal sign up page. If you do not whitelist any domains, you will need to approve new users manually before they can do anything. Please be extremely careful with the whitelisting setting - if you set it to a domain that you have no control over (e.g ``gmail.com``), then anyone will be able to access your instance of apostello
* If you need to approve new users, use the User Permissions page


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

Use the `Site Configuration` form to tell apostello about your mail server.
