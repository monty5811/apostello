To push to production:

Make a copy of `env_vars/example.yml`, then edit `production.yml` to point to
your new file instead of `env_vars/example.yml`.
If you want to store your file in source control, you must encrypt it using
`ansible-vault` or you will expose your credentials when you push to a public
repo.

```
virtualenv venv
. venv/bin/activate
pip install ansible==2.2.0.0
ansible-playbook --ask-vault-pass -i sms.example.com,  production.yml
```

Tested on Ubuntu 14.04 LTS x64, derived from
https://www.calazan.com/using-docker-and-docker-compose-for-local-django-development-replacing-virtualenv/
