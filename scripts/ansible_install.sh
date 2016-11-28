set -e
AP_VER=v1.14.0

cd /home/apostello/
echo "Installing and upgrading packages"
sudo apt-get update -qq
sudo apt-get upgrade -y
sudo apt-get install -y \
    git \
    libffi-dev libssl-dev openssl \
    python-virtualenv python-dev

echo "Setting up ansible environment"
if [ ! -d 'apostello-install' ]; then
    echo "First run, cloning apostello..."
    git clone https://github.com/monty5811/apostello.git apostello-install
    cd apostello-install
    git checkout $VERSION
    if [ -f /home/apostello/custom_vars.yml ]; then
        echo "Moving custom file into place"
        mv /home/apostello/custom_vars.yml /home/apostello/apostello-install/ansible/env_vars/example.yml
    fi
    echo "Setting up virtualenv"
    virtualenv venv --no-site-packages
    ./venv/bin/pip install -U pip
    ./venv/bin/pip install -U setuptools
    ./venv/bin/pip install ansible==2.1.1.0
else
    cd apostello-install
    echo "Updating apostello..."
    git fetch
    git checkout $AP_VER
fi

cd ansible
echo "Detecting IP and writing to config"
IP=`ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1'`
sed -i -e "s/server_name_replace_me/$IP/g" env_vars/example.yml

echo "Running ansible deploy"
./../venv/bin/ansible-playbook -i 127.0.0.1, production.yml --connection=local

echo "###################################################################"
echo "## apostello is now running on this server                       ##"
echo "##                                                               ##"
echo "## If this is your first time setup, you need edit               ##"
echo "## apostello-install/ansible/env_vars/example.yml                ##"
echo "##                                                               ##"
echo "## You must set up your email settings, or apostello will not    ##"
echo "## function correctly!                                           ##"
echo "##                                                               ##"
echo "## Email setup: http://goo.gl/nkjPdy                             ##"
echo "## Twilio setup: http://goo.gl/2lt8dX                            ##"
echo "##                                                               ##"
echo "## Then run the command:                                         ##"
echo "## ./home/apostello/apostello-install/scripts/ansible_install.sh ##"
echo "##                                                               ##"
echo "## More info: https://goo.gl/WWFj3h                              ##"
echo "##                                                               ##"
echo "###################################################################"
