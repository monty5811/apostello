.. _deploy-heroku:

Deploying to Heroku
===================

Heroku lets you run your application in the cloud.
If you click the button below, an instance of apostello will be created for you.
It is possible to run apostello on the free tier of Heroku, however Heroku
requires your app to sleep for 6 hours a day when you are on the free tier and
will sleep your app after inactivity.
It can take a few seconds for an app to wake up from its sleeping state.
This may mean you miss some incoming messages from Twilio.
You can either upgrade to a paid plan or use the ansible playbook or digital
ocean installer instead.

.. image:: https://www.herokucdn.com/deploy/button.png
    :target: https://heroku.com/deploy?template=https://github.com/monty5811/apostello/tree/master

Despite the limitations above, Heroku can be a quick and easy way to evaluate if
you want to invest the time into setting up and using apostello at your church.
