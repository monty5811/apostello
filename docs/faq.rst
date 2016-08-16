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

The send SMS form will read url parameters. So an URL ``apostello-demo.herokuapp.com/send/adhoc/?content=test&recipient=1&recipient=2`` will prepopulate the SMS form with ``test`` in the content box and the recipients ``1`` and ``2`` (you can get these numbers from the api or the url when editing a contact) in the send field.
