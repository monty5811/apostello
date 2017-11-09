#!/bin/bash
set -e

read CUR_VER < VERSION

rpl $CUR_VER $1 VERSION scripts/ansible_install.sh ansible/env_vars/base.yml
