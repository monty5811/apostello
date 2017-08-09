Frequently Asked Questions
==========================

What is the character limit for an SMS?
---------------------------------------

By default, each SMS is limited to 160 characters.
Twilio can send messages up to 1600 characters long, but it will charge you multiple times, e.g. a 1600 character message will be charged the same as 10 messages.

The character limit can be increased on the Site Configuration page (``Tools --> Site Configuration``).

How do I "mail merge" my messages?
----------------------------------

Any occurrence of ``%name%`` in outgoing messages or keyword replies will be replaced by the first name of the contact.
For example, ``Hi %name%!`` becomes ``Hi John!``


How do I cancel scheduled messages?
-----------------------------------

Go to ``Menu --> Scheduled Messages``, and click the cancel button for any scheduled messages you wish to cancel.

How do I setup the slack integration?
-------------------------------------

Create a new Slack incoming `webhook <https://my.slack.com/services/new/incoming-webhook/>`_.
Then open the Site Configuration page (``Tools --> Site Configuration``) and paste the hook URL you were given by Slack.
Click save and all your incoming messages should show up in the Slack channel you picked when creating the webhook.

How do I prepopulate the send SMS form?
---------------------------------------

The send SMS form will read url parameters. So an URL ``apostello-demo.herokuapp.com/send/adhoc/?content=test&recipients=[1,2]`` will prepopulate the SMS form with ``test`` in the content box and the recipients ``1`` and ``2`` (you can get these numbers from the api or the url when editing a contact) in the send field.

The URLs in my emails are incorrect
-----------------------------------

You may need to let apostello know what your domain is.
You can do this by opening ``<your domain>/admin/sites/site/``, click on the first entry and update the domain name field, then click save.

How can I get rid of old messages?
----------------------------------

Open the Site Configuration page (``Tools --> Site Configuration``), scroll down to find the ``SMS Expiration`` section.
You can set a hard cut off date: any messages before this date will be purged from the system.
Or you can choose the number of days to hold on to messages: any messages older than this number of days will be purged.
The purge is run daily. You can use this to hide old messages you no longer care about or to make sure you stay within the limits of the Heroku hobby database.

How can I get notified of new messages?
---------------------------------------

You can use the Slack integration (see above), or if you use Chrome or Firefox you can get push notifications when any new message arrives.

There are a few steps to get this working:

* Sign up for a `Firebase <https://firebase.google.com/>`_ account
* Login and create a new Firebase project
* Open you project, then go to ``Settings -> Cloud Messaging``
* You need two bits of information from this page - the Sender ID and the Server Key. You need to provide these to apostello so we can send notifications. Do this by setting the environment variables ``CM_SENDER_ID`` and ``CM_SERVER_KEY``.

Once you are all setup, open apostello, open the ``Tools`` menu and subscribe to notifications - you will be notified everytime a new SMS is received. You can turn it off at any time.
