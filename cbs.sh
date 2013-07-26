#!/bin/bash

# "Cloud bootstrap"
#
# ssh into a new cloud server and run the cloud-setup.sh script.

IP=$1
USER=ubuntu
THIS_PROJECT=jamie-hpcloud-setup

HOME_DIR=/home/$USER
SRC_DIR=$HOME_DIR/src
SETUP_DIR=$SRC_DIR/$THIS_PROJECT

ssh -oStrictHostKeyChecking=no -i ~/.ssh/id_hpcloud $USER@$IP "touch $HOME_DIR/.bash_history && sudo apt-get -yqq update && sudo apt-get -yqq install git && mkdir -p $SRC_DIR && rm -rf $SETUP_DIR && git clone https://github.com/jamiemccarthy/$THIS_PROJECT.git $SETUP_DIR && $SETUP_DIR/cloud-setup.sh"

