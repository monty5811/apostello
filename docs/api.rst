API
===

An API is availale for programmatic access to your instance of apostello.
Currently the API is read only and experimental.

Setup
~~~~~

In order to access the API, you must generate an API key.
Open your instance of apostello and navigate to ``/api-setup/``, or click ``Tools -> API Setup``, then generate an API key. Only staff users can access this page.

You can also regenerate or remove your API keys on this page.

You can change another user's API key in the admin panel.

Documentation
~~~~~~~~~~~~~

Documentation of the API endpoints can be found at ``<your-apostello-url>/api-docs/``.

The API key must be included in the ``Authorization`` HTTP header (``Authorization: Token <API-KEY>``).

An example request might look like:

.. code-block:: python

    import requests

    r = requests.get(
        url,
        headers={'Authorization': 'Token {0}'.format(API_KEY)}
    )
    print(r.json())
