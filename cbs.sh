#!/bin/bash

# "Cloud bootstrap"
#
# ssh into a new cloud server and run the cloud-setup.sh script.

IP=$1
USER=ubuntu
SRC_DIR=/home/$USER/src
THIS_PROJECT=jamie-hpcloud-setup
SETUP_DIR=$SRC_DIR/$THIS_PROJECT

ssh -oStrictHostKeyChecking=no -i ~/.ssh/id_hpcloud $USER@$IP 'sudo apt-get update && sudo apt-get install git && mkdir -p $SRC_DIR && git clone https://github.com/jamiemccarthy/$THIS_PROJECT.git $SETUP_DIR && $SETUP_DIR/cloud-setup.sh'

