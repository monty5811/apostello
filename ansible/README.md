To push to production:

Make a copy of `env_vars/example.yml`, then edit `production.yml` to point to
your new file instead of `env_vars/example.yml`.
If you want to store your file in source control, you must encrypt it using
`ansible-vault` or you will expose your credentials when you push to a public
repo.

```
virtualenv venv
. venv/bin/activate
pip install ansible==2.5.0.0
ansible-playbook --ask-vault-pass -i sms.example.com,  production.yml
```

Tested on:

 - Ubuntu 16.04 LTS x64
 - Ubuntu 14.04 LTS x64

Should work:

 - Ubuntu 18.04 LTS x64 - the deployment tests, when run with docker, fail for 18.04, but when using a real server, they pass. For the minute 18.04 is not officially supported, but it should work if you want to try.

Originally derived from https://www.calazan.com/using-docker-and-docker-compose-for-local-django-development-replacing-virtualenv/
