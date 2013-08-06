#!/bin/bash

# "Cloud setup"
#
# Set up a new cloud machine to run devstack

USER=ubuntu
JAMIE_SETUP_PROJECT=jamie-hpcloud-setup

HOME_DIR=/home/$USER
SRC_DIR=$HOME_DIR/src
DEVSTACK_DIR=$SRC_DIR/devstack
JAMIE_SETUP_DIR=$SRC_DIR/$JAMIE_SETUP_PROJECT

# Try to undo installation before redo. May or may not work.

if [ -f $DEVSTACK_DIR/unstack.sh ]; then
	$DEVSTACK_DIR/unstack.sh
fi

# Install devstack

if [ ! -d $DEVSTACK_DIR ]; then
	git clone -q http://github.com/openstack-dev/devstack.git $DEVSTACK_DIR
fi
git --git-dir=$DEVSTACK_DIR/.git --work-tree=$DEVSTACK_DIR pull origin master
# My localrc sets all devstack's passwords to "1"
cp -a $JAMIE_SETUP_DIR/localrc $DEVSTACK_DIR/localrc
cd $DEVSTACK_DIR
./stack.sh > stack.sh.out 2> stack.sh.err

# Install barbican, per <https://github.com/cloudkeep/barbican/wiki/Developer-Guide>

sudo apt-get -yqq install virtualenv python-virtualenv python-pip python-dev libsqlite3-dev libpq-dev
cd $SRC_DIR
git clone https://github.com/stackforge/barbican.git
cd barbican
virtualenv .venv
source .venv/bin/activate
export VENV_HOME=$SRC_DIR/barbican
pip install uwsgi                  || exit 1
pip install -r tools/pip-requires  || exit 1
pip install -r tools/test-requires || exit 1
pip install -e .                   || exit 1
cp -a etc/barbican/barbican-api.conf ~/
sudo mkdir /var/lib/barbican ; sudo chown ubuntu:ubuntu /var/lib/barbican
sudo mkdir /var/log/barbican ; sudo chown ubuntu:ubuntu /var/log/barbican
sudo mkdir /etc/barbican     ; sudo chown ubuntu:ubuntu /etc/barbican
cp etc/barbican/barbican-{api,admin}-paste.ini /etc/barbican/
sudo updatedb # I find "locate" useful
bin/barbican-all

