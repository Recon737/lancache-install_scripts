#!/bin/bash
# Script #1/3
# This script is designed to replicate the commands in the Dockerfile for the 
# lancachenet/ubuntu docker img located at 
# https://github.com/lancachenet/ubuntu

# exit script if any step fails
set -e

# add this to .bashrc later
export DEBIAN_FRONTEND=noninteractive

# update, upgrade, and install dependencies
apt-get -y update && apt-get -y upgrade
apt-get -y install supervisor curl wget bzip2 locales-all tzdata git --no-install-recommends

# set local
#locale-gen en_GB.utf8 && update-locale LANG=en_GB.utf8
locale-gen en_US.UTF-8 && update-locale LANG=en_US.UTF-8

# clean apt cache
apt-get -y clean && rm -rf /var/lib/apt/lists/*


# add env variables to .bashrc and  activate them
cat <<EOF >> ~/.bashrc
export DEBIAN_FRONTEND=noninteractive
export SUPERVISORD_EXIT_ON_FATAL=1
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
export LANGUAGE=en_US.UTF-8
export TZ=America/New_York
export SUPERVISORD_LOGLEVEL=WARN
EOF
source ~/.bashrc

# clone the github repo and copy overlay directory
git clone https://github.com/lancachenet/ubuntu.git ~/lancachenet-ubuntu
cp -r ~/lancachenet-ubuntu/overlay/* /

# Set perms
chmod -R 755 /init /hooks

# Dockerfile ENTRYPOINT + CMD
/bin/bash -e /init/entrypoint /init/supervisord