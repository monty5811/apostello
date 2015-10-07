Features
========

* Send messages to ad-hoc or predefined groups.
* Automatically respond to incoming messages that match keywords.
* Track sign ups, questions, etc using keywords.
* Manage access permissions - you can let anyone in you church have read only access.
* Receive daily digest emails of incoming messages.
* Live "wall" - curate and display incoming messages on a big screen. Great for a Q&A.
* Post all messages to a slack channel.
* Import contacts (CSV or `Elvanto <https://www.elvanto.com/r_Y7HXKNE6>`_).


Keywords
--------

All incoming messages are expected to start with a keyword. This allows for custom replies to be sent back and is useful for tracking things like event sign ups or questions for a Q&A.

Special Keywords
~~~~~~~~~~~~~~~~

There is a small set of reserved keywords, some by Twilio and some by apostello.

* Twilio's reserved keywords can be found here:
* apostello also reserves the keyword **name**. Any SMS that matches **name** will be parsed for a name and used to update the name associated with that contact in the DB. If the parsing fails, then the contact is sent another message asking them to try again.

Custom Keywords
~~~~~~~~~~~~~~~

You can create as many keywords as you like, and each keyword comes with the following features:

* Custom response
* Number of response tracked
* Ability to mark each response as "Requires Action" or "Dealt With"
* Archiving of old responses
* Activation time and a too early custom response
* Deactivation time and a too late custom response
* Ability to lock a keyword to certain users (staff can see all)
* Daily email digests - send digest of today's responses every night
* CSV export of messages
* Live wall - a curatable live wall to display incoming messages at a Q&A

Keyword Matching
~~~~~~~~~~~~~~~~

TODO: describe keyword matching process

Sending Messages
----------------


