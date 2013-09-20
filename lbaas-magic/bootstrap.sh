#!/bin/bash

# "Cloud image bootstrap, lbaas-magic host"
#
# Make a new HP Cloud server, update it, and install lbaas-magic.
#
# Doesn't run lbaas-magic, but does set up keys for it to use.
#
# First argument is the target machine name, e.g. "lbaas-prod-saltmagic-1",
# second is the number (1-3) of the target AZ, e.g. "1"

if [ "x$OS_TENANT_ID" = 'x' ]
then
	echo "OS_TENANT_ID must be defined, aborting."
	exit 1
fi

MACHINE_NAME=$1
USER=ubuntu
THIS_PROJECT=jamie-hpcloud-setup

HOME_DIR=/home/$USER
SRC_DIR=$HOME_DIR/src
SETUP_DIR=$SRC_DIR/$THIS_PROJECT
MY_KEY_NAME=jamie-hpcloud
MY_SSH_KEY=/Users/jamie/.ssh/id_hpcloud

IMAGE_UBUNTU_PRECISE='9bf86304-b16f-48bd-9bbd-c18d96d76f1c'
IMAGE_UBUNTU_RARING='312de666-45f0-4cc7-b3c9-de02bc328afb'
IMAGE=$IMAGE_UBUNTU_PRECISE

BYPASS_URL_AZ1="https://15.125.0.16:8774/v2/$OS_TENANT_ID"
BYPASS_URL_AZ2="https://15.125.16.73:8774/v2/$OS_TENANT_ID"
BYPASS_URL_AZ3="https://15.125.32.17:8774/v2/$OS_TENANT_ID"
BYPASS_URL=$(eval "echo \$$(echo BYPASS_URL_AZ$2)")
if [ "x$BYPASS_URL" = 'x' ]
then
	echo "Unknown AZ '$2', aborting."
	exit 1
fi
AZ_NAME="dbaas-aw2az$2-v1"

echo "BYPASS_URL = $BYPASS_URL"
echo "AZ_NAME = $AZ_NAME"

FLAVOR_SMALL=2
FLAVOR_MEDIUM=3
FLAVOR_LARGE=4
FLAVOR=$FLAVOR_SMALL

#
# Delete and create the instance.
#

echo "creating $MACHINE_NAME in $AZ_NAME..."

nova --insecure delete $MACHINE_NAME 2> /dev/null

nova --insecure boot --flavor=$FLAVOR --image=$IMAGE --availability-zone=$AZ_NAME --key-name=$MY_KEY_NAME --security-groups=default $MACHINE_NAME

#
# Wait for its status to change from BUILD to ACTIVE, and get its ID and IPs,
# then wait for it to respond to ssh
#

sleep 15
rm -f /tmp/nova_output_$MACHINE_NAME
STATUS=''
while [ "x$STATUS" != 'xACTIVE' ] ; do
	sleep 10
	nova --insecure show $MACHINE_NAME > /tmp/nova_output_$MACHINE_NAME
	STATUS=`perl -nle 'print $1 if /^\| status\s+\| (\S+)/' < /tmp/nova_output_$MACHINE_NAME`
	echo "STATUS: $STATUS"
done
ID=`perl -nle 'print $1 if /^\| id\s+\| (\S+)/' < /tmp/nova_output_$MACHINE_NAME`
PRIVATE_IP=`perl -nle 'print $1 if /^\| dbaas-[\w-]+ network\s+\| ([\d.]+), [\d.]+/' < /tmp/nova_output_$MACHINE_NAME`
PUBLIC_IP=`perl  -nle 'print $1 if /^\| dbaas-[\w-]+ network\s+\| [\d.]+, ([\d.]+)/' < /tmp/nova_output_$MACHINE_NAME`
echo "Created $ID at $PUBLIC_IP"

# TODO Wait for ssh to be ready -- make this smarter, like the "fab check_ls"
# that pcrews wrote in saltmagic.py :)
sleep 30

#
# Update Ubuntu to latest versions of all packages. (dist-upgrade handles
# changing dependencies as well, and will include kernel upgrades.
# Comments welcome.)
#

ssh -oStrictHostKeyChecking=no -i $MY_SSH_KEY $USER@$PUBLIC_IP "touch $HOME_DIR/.bash_history && chmod 600 $HOME_DIR/.bash_history && sudo apt-get -yqq update && sudo apt-get -yqq dist-upgrade"

#
# Reboot for possible new kernel.
#

sleep 5
nova --insecure reboot $ID
sleep 15
rm -f /tmp/nova_output_$MACHINE_NAME
STATUS=''
while [ "x$STATUS" != 'xACTIVE' ] ; do
	sleep 10
	nova --insecure show $ID > /tmp/nova_output_$MACHINE_NAME
	STATUS=`perl -nle 'print $1 if /^\| status\s+\| (\S+)/' < /tmp/nova_output_$MACHINE_NAME`
	echo "STATUS: $STATUS"
done

#
# Install git, clone this repository, and run the script that sets up the saltmaster.
# TODO: Assign a floating IP, and pass it in instead of the public IP
#

ssh -oStrictHostKeyChecking=no -i $MY_SSH_KEY $USER@$PUBLIC_IP "sudo apt-get -yqq install git && mkdir -p $SRC_DIR && rm -rf $SETUP_DIR && git clone -q https://github.com/jamiemccarthy/$THIS_PROJECT.git $SETUP_DIR && $SETUP_DIR/lbaas-magic/lbaas-magic-setup.sh"

echo "Remember to (TODO) patch lbaas-magic's example .cfg, after which..."
echo "lbaas-magic is set up on $MACHINE_NAME"
echo "Connect to it with: ssh -i $MY_SSH_KEY $USER@$PUBLIC_IP"
echo "Run lbaas-magic with: cd $SRC_DIR/lbaas-magic ; python saltmagic.py --verbose"

