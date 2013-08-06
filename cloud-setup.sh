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

# Try to undo installation before redo. May or may not work.

if [ -f $DEVSTACK_DIR/unstack.sh ]; then
	$DEVSTACK_DIR/unstack.sh
fi

# Install devstack

if [ ! -d $DEVSTACK_DIR ]; then
	git clone -q http://github.com/openstack-dev/devstack.git $DEVSTACK_DIR
fi
git --git-dir=$DEVSTACK_DIR/.git --work-tree=$DEVSTACK_DIR pull origin master
cp -a $JHS_DIR/localrc $DEVSTACK_DIR/localrc
cd $DEVSTACK_DIR
./stack.sh > stack.sh.out 2> stack.sh.err

sudo apt-get -yqq install python-virtualenv libsqlite3-dev
cd $SRC_DIR
git clone https://github.com/stackforge/barbican.git
cd barbican
#virtualenv .venv
#source .venv/bin/activate
pip install uwsgi
pip install paste
pip install -r tools/pip-requires
pip install -r tools/test-requires
cp -a etc/barbican/barbican-api.conf ~/ # TODO review how barbiban-all does this if the file is missing
sudo mkdir /var/lib/barbican ; sudo chown ubuntu:ubuntu /var/lib/barbican
sudo mkdir /var/log/barbican ; sudo chown ubuntu:ubuntu /var/log/barbican
sudo mkdir /etc/barbican     ; sudo chown ubuntu:ubuntu /etc/barbican
cp etc/barbican/barbican-{api,admin}-paste.ini /etc/barbican/
bin/barbican-all

