#!/bin/bash

# "Cloud setup"
#
# Set up a new cloud machine to run devstack

USER=ubuntu
JAMIE_SETUP_PROJECT=jamie-hpcloud-setup

HOME_DIR=/home/$USER
SRC_DIR=$HOME_DIR/src
DEVSTACK_DIR=$SRC_DIR/devstack
BARBICAN_DIR=$SRC_DIR/barbican
JAMIE_SETUP_DIR=$SRC_DIR/$JAMIE_SETUP_PROJECT

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

sudo apt-get -yqq install python-virtualenv python-pip python-dev libsqlite3-dev libpq-dev
cd $SRC_DIR
git clone https://github.com/stackforge/barbican.git
cd $BARBICAN_DIR
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

# Shut down devstack, except for Keystone, per
# <https://github.com/cloudkeep/barbican/wiki/Developer-Guide#running-openstack-keystone-authentication-middleware>

cd $DEVSTACK_DIR
./unstack.sh
/opt/stack/keystone/bin/keystone-all --verbose --debug > ~/keystone.out 2> ~/keystone.err &
sleep 10
# Replace the sample password with the "1" password from our localrc. This
# creates a "barbican" user and assigns it the "admin" role.
perl -i~ -pe 's/orange/1/' $BARBICAN_DIR/bin/keystone_data.sh
# Patch barbican-api-paste.ini to use Keystone
patch /etc/barbican/barbican-api-paste.ini < $JAMIE_SETUP_DIR/barbican-api-paste.ini.patch || exit 1

# I find "locate" useful

sudo updatedb

# Start Barbican

cd $BARBICAN_DIR
bin/barbican-all > ~/barbican-all.out 2> ~/barbican-all.err &

