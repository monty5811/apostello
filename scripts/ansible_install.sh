#!/bin/bash
set -e
# setup some constants
AP_VER=v1.14.0
REPO_URL=https://github.com/monty5811/apostello.git
HOME_DIR=/home/apostello
CUSTOM_VARS_FILE=$HOME_DIR/custom_vars.yml
APOSTELLO_INSTALL_DIR=$HOME_DIR/apostello-install
ANSIBLE_DIR=$APOSTELLO_INSTALL_DIR/ansible

presetup() {
    echo "Installing and upgrading packages"
    sudo apt-get update -qq
    sudo apt-get upgrade -qq -y
    sudo apt-get install -qq -y \
        git \
        libffi-dev libssl-dev openssl \
        python-virtualenv python-dev
}

pull_repo() {
    echo "Setting up ansible environment"
    cd $HOME_DIR
    if [ ! -d 'apostello-install' ]; then
        echo "First run, cloning apostello..."
        git clone $REPO_URL $APOSTELLO_INSTALL_DIR -q
        cd $APOSTELLO_INSTALL_DIR
        git checkout $VERSION -q
        if [ -f $CUSTOM_VARS_FILE ]; then
            echo "Moving custom file into place"
            mv $CUSTOM_VARS_FILE $ANSIBLE_DIR/env_vars/example.yml
        fi
        echo "Setting up virtualenv"
        virtualenv venv --no-site-packages
        ./venv/bin/pip install -q -U pip
        ./venv/bin/pip install -q -U setuptools
        ./venv/bin/pip install -q ansible==2.2.0.0
    else
        echo "Updating apostello..."
        cd $APOSTELLO_INSTALL_DIR
        git fetch -q
        git checkout $AP_VER -q
    fi
}

replace_ip() {
    echo "Detecting IP and writing to nginx config"
    cd $ANSIBLE_DIR
    IP=`ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1'`
    sed -i -e "s/server_name_replace_me/$IP/g" env_vars/example.yml
}

install() {
    echo "Running ansible deploy"
    $APOSTELLO_INSTALL_DIR/venv/bin/ansible-playbook -i 127.0.0.1, production.yml --connection=local
}

print_help() {
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
    echo "## ./$APOSTELLO_INSTALL_DIR/scripts/ansible_install.sh ##"
    echo "##                                                               ##"
    echo "## More info: https://goo.gl/WWFj3h                              ##"
    echo "##                                                               ##"
    echo "###################################################################"
}

presetup
pull_repo
replace_ip
install
print_help
