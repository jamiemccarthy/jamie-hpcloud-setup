#!/bin/bash

# "LBaaS saltmaster setup"
#
# Make the modifications to a freshly-booted instance, to turn it into
# a salt master.

USER=ubuntu
JAMIE_SETUP_PROJECT=jamie-hpcloud-setup

HOME_DIR=/home/$USER
SRC_DIR=$HOME_DIR/src
JAMIE_SETUP_DIR=$SRC_DIR/$JAMIE_SETUP_PROJECT

#
# Packages to install, based on pcrews' lbaas-salt and lbaas-magic repos.
# We install salt-cloud and related packages, even if we aren't yet going
# to use them (my understanding is that salt-cloud isn't yet compatible
# with our --bypass-url requirements).
#

sudo add-apt-repository -y ppa:saltstack/salt
sudo apt-get update
sudo apt-get install -yqq build-essential
sudo apt-get install -yqq salt-common salt-cloud salt-master salt-minion
sudo apt-get install -yqq git debconf-utils python-setuptools python-dev python-pip python-mysqldb
sudo pip install python-keystoneclient python-novaclient python-swiftclient
# lbaas-magic wants to install salt-cloud with pip; existing salt-master
# installed it via apt. The above apt installs brought along e.g. python-zmq
# and python-jinja2. Commenting these out for now.
#sudo apt-get install python-m2crypto
#sudo pip install pyzmq PyYAML pycrypto msgpack-python jinja2 psutil apache-libcloud salt-cloud
# Pip packages missing that are present on 1.0 salt master:
#    botocore distro-info docutils eventlet Fabric gearman gevent
#    greenlet lockfile lxml medusa meld3 nose oauthlib
#    pexpect PIL Pygments python-daemon python-dateutil
#    python-libraclient reportlab rst2pdf salt salt-cloud
#    setuptools-git Sphinx supervisor tornado urllib3
# Pip packages that are a more-recent version on the 1.0 salt master:
#    cloud-init pycrypto pyOpenSSL simplejson Twisted-{Core,Names,Web}

#
# Possible other things to install, based on HPC 1.0 salt-master installation...?
#

# sudo apt-get install autoconf automake autotools-dev daemon fabric ntp

#
# Configure salt master
#

# TODO This should really be a floating IP we assign and pass into this script.
perl -pe 's/^(#master: salt)$/$1\nmaster: '$PUBLIC_IP'/' /etc/salt/minion

#
# Just because I find "locate" useful
#

sudo updatedb

