# apostello

[![Chat with us](https://img.shields.io/badge/chat-slack-e01563.svg)](http://chat.church.io/)

Apostello is free SMS communication software for your church.

*more info coming soon*

[![Circle CI](https://circleci.com/gh/monty5811/apostello.svg?style=svg)](https://circleci.com/gh/monty5811/apostello)[![Codacy Badge](https://api.codacy.com/project/badge/38dd43ee8d9643e9b9bfb063750b8485)](https://www.codacy.com/app/montgomery-dean97/apostello)[![Coverage Status](https://coveralls.io/repos/monty5811/apostello/badge.svg?branch=master&service=github)](https://coveralls.io/github/monty5811/apostello?branch=master)[![Code Issues](https://www.quantifiedcode.com/api/v1/project/742104b6d18f48c8a6fedf4e1c57c36a/badge.svg)](https://www.quantifiedcode.com/app/project/742104b6d18f48c8a6fedf4e1c57c36a)

## Features

 - Send messages to ad-hoc or predefined groups.
 - Automatically respond to incoming messages that match keywords.
 - Track sign ups, questions, etc using keywords.
 - Manage access permissions - you can let anyone in you church have read only access.
 - Receive daily digest emails of incoming messages.
 - Live "wall" - curate and display incoming messages on a big screen. Great for a Q&A.
 - Post all messages to a slack channel.
 - Import contacts (CSV or [Elvanto](https://www.elvanto.com/r_Y7HXKNE6)).

## Prerequisites

In order to set up an instance of apostello you will need:

 - Twilio account and a purchased number.
 - Google account, preferably a Google Apps Domain. Currently all users log in with a Google account. A Google Apps domain can be white listed in the application settings. Alternatively individual Google accounts can also be white listed. Support for other login options is planned.

## Development

To get a local instance running:

```
git clone https://github.com/monty5811/apostello.git
cd apostello
virtualenv-3.4 venv
. venv/bin/activate
pip install -r requirements
cp .env.example .env # Fill in .env
export DJANGO_SETTINGS_MODULE=settings.dev
./manage.py migrate
./manage.py runserver 0.0.0.0:8000
```
