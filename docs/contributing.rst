Contributing
============

Thank you for considering contributing to apostello, please read these guidelines so we can best manage things.

There are many ways for you to contribute: writing tutorials, improving the documentation, submitting bug reports or feature requests and writing code.

Code Contributions
------------------

Guidelines for code contributions:

* Unless it is a small or trivial fix, please open an issue before starting
* Any new features must include tests - if a feature requires interaction through the browser, please add selenium backed tests
* Please do not hit the network in tests - see how vcrpy is used in the test suite for help with this
* Please run ``./scripts/run_yapf.py`` before committing to maintain code style
* Please ensure any changes to javascript code compile without warnings
* Please add only a single feature per pull request

Please do not hesitate to ask for help in our `chat <http://chat.church.io/>`_.


Development Environment
#######################

Prerequisites
~~~~~~~~~~~~~

* `Python 3 <https://www.python.org/>`_
* `Git <https://www.atlassian.com/git/tutorials/install-git/>`_
* Optional: `Node <https://nodejs.org/>`_ for frontend development
* Optional: Java for minifying JS
* Optional: Firefox (<46) to run integration tests

Get Started
~~~~~~~~~~~

Fork apostello on Github (`how-to <https://help.github.com/articles/fork-a-repo/>`_), then clone the repo:

.. code-block:: bash

    git clone <url-to-your-fork-here>
    cd apostello
    # create a branch for your feature/fix:
    git checkout -b <branch-name>

Create a python virtualenv and install dependencies:

.. code-block:: bash

    python3 -m venv venv
    pip install -r requirements/dev.txt

Create a development database (this uses sqlite, if you need to reset the database, just delete db.sqlite3 and run this command again):

.. code-block:: bash

    ./manage.py migrate

Create a super user:

.. code-block:: bash

    ./manage.py createsuperuser  # follow the prompts

Start the development server:

.. code-block:: bash

    ./manage.py runserver

Open your browser and go to ``127.0.0.1:8000/admin`` and login.


Running Tests
~~~~~~~~~~~~~

.. code-block:: bash

    pip install tox
    tox # you need firefox < 46 installed
    tox -e py35 # runs tests only for py35
    tox -e py35 -- -m \"not slow" # runs only quick tests on py35


Frontend
~~~~~~~~

A significant portion of the frontend uses `Elm <https://elm-lang.org>`_.

Setup:

.. code-block:: bash

    cd assets/
    npm install # this may take a while

Changes must then be compiled:

.. code-block:: bash

    npm run build # regenerate all the assets
    npm run watchjs # watch js and elm code for changes
    npm run prodjs # build the js and elm for production
