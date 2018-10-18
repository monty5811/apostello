set -e
# this is a hack to get redis running inside the container
# the setup appears to work fine on a real ubuntu 18.04 box:
redis-server --daemonize yes
# run test ansible setup
ansible-playbook -i 127.0.0.1, test.yml --connection=local
# check if login page is there
curl 127.0.0.1/config/first_run/ --fail
# check django-q is working
cd /webapps/apostello_py36
. bin/activate
. bin/postactivate
cd apostello
./manage.py qinfo
# run django checks
./manage.py check
