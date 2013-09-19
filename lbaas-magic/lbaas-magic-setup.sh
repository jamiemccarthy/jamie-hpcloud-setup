#!/bin/bash

# "lbaas-magic setup"
#
# Make the modifications to a freshly-booted instance, so it can run
# lbaas-magic.py properly.

USER=ubuntu
LBAAS_MAGIC_PROJECT=lbaas-magic

HOME_DIR=/home/$USER
SRC_DIR=$HOME_DIR/src
LBAAS_MAGIC_DIR=$SRC_DIR/$LBAAS_MAGIC_PROJECT

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
# Install lbaas-magic.
#

mkdir -p $SRC_DIR
git clone -q https://github.com/jamiemccarthy/$LBAAS_MAGIC_PROJECT.git $LBAAS_MAGIC_DIR

#
# Set up keys for lbaas-magic to use.
#

mkdir -p $HOME_DIR/.ssh
chmod 644 $HOME_DIR/.ssh
ssh-keygen -f $HOME_DIR/.ssh/id_rsa -C 'auto-generated-lbaas-magic' -N ''

#
# TODO Patch lbaas-magic's example .cfg, taking the nova auth from
# current env vars.
#

#
# Just because I find "locate" useful
#

sudo updatedb

