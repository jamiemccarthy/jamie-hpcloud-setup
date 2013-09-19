#!/bin/bash

# "lbaas-magic setup"
#
# Make the modifications to a freshly-booted instance, so it can run
# lbaas-magic.py properly.

LBAAS_MAGIC_IP=$1

USER=ubuntu
JAMIE_SETUP_PROJECT=jamie-hpcloud-setup

HOME_DIR=/home/$USER
SRC_DIR=$HOME_DIR/src
JAMIE_SETUP_DIR=$SRC_DIR/$JAMIE_SETUP_PROJECT

#
# Packages needed by lbaas-magic.
#
# For now I'm installing salt-cloud and related packages, even though they
# aren't used on the lbaas-magic instance.
#

sudo add-apt-repository -y ppa:saltstack/salt
sudo apt-get update
sudo apt-get install -yqq build-essential
sudo apt-get install -yqq salt-common salt-cloud salt-master salt-minion
sudo apt-get install -yqq debconf-utils python-setuptools python-dev python-pip python-mysqldb
sudo pip install python-keystoneclient python-novaclient python-swiftclient

#
# Just because I find "locate" useful
#

sudo updatedb

