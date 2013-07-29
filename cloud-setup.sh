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

# TODO maybe but probably not:
# pip install repoze.lru tempita decorator lxml

# Hypothesized to be because of virtualenv:
#
# Downloading/unpacking lxml>=2.3 (from -r /opt/stack/cinder/requirements.txt (line 12))
#  Running setup.py egg_info for package lxml
#    /usr/lib/python2.7/distutils/dist.py:267: UserWarning: Unknown distribution option: 'bugtrack_url'
#      warnings.warn(msg)
#    Building lxml version 3.2.3.
#    Building without Cython.
#    ERROR: /bin/sh: 1: xslt-config: not found
#    
#    ** make sure the development packages of libxml2 and libxslt are installed **

if [ -f $DEVSTACK_DIR/unstack.sh ]; then
	$DEVSTACK_DIR/unstack.sh
fi
if [ ! -d $DEVSTACK_DIR ]; then
	git clone -q http://github.com/openstack-dev/devstack.git $DEVSTACK_DIR
fi
git --git-dir=$DEVSTACK_DIR/.git --work-tree=$DEVSTACK_DIR pull origin master
#git --git-dir=$DEVSTACK_DIR/.git --work-tree=$DEVSTACK_DIR checkout 89b58846b5604cdf976074a68004840cc6865bdb
cp -a $JHS_DIR/localrc $DEVSTACK_DIR/localrc
cd $DEVSTACK_DIR
./stack.sh > stack.sh.out 2> stack.sh.err

