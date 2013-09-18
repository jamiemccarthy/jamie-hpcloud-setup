#!/bin/bash

# "LBaaS template image setup"
#
# Make the modifications to a freshly-booted instance, for it to become a
# template for future instances.

USER=ubuntu
JAMIE_SETUP_PROJECT=jamie-hpcloud-setup

HOME_DIR=/home/$USER
SRC_DIR=$HOME_DIR/src
JAMIE_SETUP_DIR=$SRC_DIR/$JAMIE_SETUP_PROJECT

#
# Install salt-minion
#

sudo add-apt-repository -y ppa:saltstack/salt
sudo apt-get update
sudo apt-get install -yqq build-essential
sudo apt-get install -yqq salt-common salt-minion
sudo apt-get install -yqq git debconf-utils python-setuptools python-dev python-pip python-mysqldb

#
# Just because I find "locate" useful
#

sudo updatedb

#
# From pcrews's deploy_libra_env.py, prior to making an image
#

sudo sync

