#!/bin/bash

# "Cloud setup"
#
# Set up a new cloud machine to run devstack

USER=ubuntu
JHS_PROJECT=jamie-hpcloud-setup

HOME_DIR=/home/$USER
SRC_DIR=$HOME_DIR/src
DEVSTACK_DIR=$SRC_DIR/devstack
JHS_DIR=$SRC_DIR/$JHS_PROJECT

git clone -q http://github.com/openstack-dev/devstack.git $DEVSTACK_DIR
cp -a $JHS_DIR/localrc $DEVSTACK_DIR/localrc
cd $DEVSTACK_DIR
./stack.sh > stack.sh.out 2> stack.sh.err

