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
You can either upgrade to a paid plan or use another deploy method instead.

.. image:: https://www.herokucdn.com/deploy/button.png
    :target: https://heroku.com/deploy?template=https://github.com/monty5811/apostello/tree/master

Despite the limitations above, Heroku can be a quick and easy way to evaluate if
you want to invest the time into setting up and using apostello at your church.

Upgrading
~~~~~~~~~

Unfortunately there is no easy way to keep an app deployed with deploy button
updated without using the command line.
Fortunately, it is pretty simple to do.

We are going to use `Git <https://git-scm.com/>`_ to grab a copy of apostello and
then use the `Heroku toolbelt <https://toolbelt.heroku.com/>`_ to create a new
build and push it.
If you don't want to use Git, you can skip those steps and just download a
zip of the source code from Github instead
(`source code <https://github.com/monty5811/apostello/archive/|vversion|.zip>`_).

Before we begin, install the Heroku toolbelt and Git.
Then run the command ``heroku login`` to login.

The first time you update after deploying to Heroku you need to run the
following commands:


.. code-block:: bash

    # install the builds plugin (you only need to do this once)
    heroku plugins:install heroku-builds
    # now, let's grab a copy of apostello
    # if you don't want to use git, then download the code manually
    git clone https://github.com/monty5811/apostello.git
    cd apostello
    # view the different releases:
    git tag
    # grab the latest release (skip this step to use the master branch)
    git checkout v<insert-latest-version-here>
    # now we want to create a new build:
    # substitute your app name into the command e.g.
    # heroku builds:create -a apostello-demo
    heroku builds:create -a <your-app-name-here>
    # you should see a bunch of text scroll by and a successful update
    # if you run into any problems, please get in touch

    # you can check your build history:
    heroku builds -a <your-app-name-here>
    # if a build fails, you can roll back to a previous build in the
    # Heroku dashboard


Subsequent updates are quicker:


.. code-block:: bash

    # move to the apostello folder, then:
    git fetch origin
    # view the different releases:
    git tag
    # Either: grab the latest release:
    git checkout v<insert-latest-version-here>
    # Or: use the latest code in the master branch:
    git pull origin master && git checkout master
    # Then push the code to Heroku
    heroku builds:create -a <your-app-name-here>
    # you may also need to run any migrations:
    heroku run -a <your-app-name-here> ./manage.py migrate


Do be aware that if you make any other changes in this folder, they
will be pushed to Heroku.
You could use this to customise the favicons, or change the configuration
in ``settings/heroku.py``, for example.
