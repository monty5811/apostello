Development
===========

Pull requests are encouraged. Please open an issue before working on anything other than minor bug fixes.


Prerequisites
~~~~~~~~~~~~~

* `Python 3 <https://www.python.org/>`_
* `Git <https://www.atlassian.com/git/tutorials/install-git/>`_
* Optional: `Node <https://nodejs.org/>`_ for frontend development
* Optional: Firefox to run integration tests

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
    pip install -r requirements/test.txt

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


Frontend
~~~~~~~~

A significant portion of the frontend is uses `React <https://facebook.github.io/react/>_`.

Setup:

.. code-block:: bash

    cd assets/
    npm install -g elm # some of the site also uses elm
    npm install # this may take a while

Changes must then be compiled:

.. code-block:: bash

    npm run build # regenerate all the assets
    npm run watchjs # watch js and elm code for changes
    npm run prodjs # build the js and elm for production
