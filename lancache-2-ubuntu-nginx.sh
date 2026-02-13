#!/bin/bash
# Script #2/3
# This script is designed to replicate the commands in the Dockerfile for the 
# lancachenet/ubuntu-nginx docker img located at 
# https://github.com/lancachenet/ubuntu-nginx

# Run this script after running lancache-1-ubuntu.sh

# exit script if any step fails
set -e

# clone/fetch the github repo and copy overlay directory
if [ -d ~/lancachenet-ubuntu-nginx ]; then 
    git -C ~/lancachenet-ubuntu-nginx fetch
else
    git clone https://github.com/lancachenet/ubuntu-nginx.git ~/lancachenet-ubuntu-nginx
    
fi
cp -r ~/lancachenet-ubuntu-nginx/overlay/* /

# update, upgrade, and install dependencies
apt-get update -y && \
# apt-get upgrade -y && \ # this upgrade is superfluous
apt-get install inotify-tools --no-install-recommends -y

# Create modules-enabled and ensure that the stream module is loaded
mkdir -p /etc/nginx/modules-enabled
echo "load_module modules/ngx_stream_module.so;" > /etc/nginx/modules-enabled/50-mod-stream.conf

# install nginx
apt-get install nginx-full --no-install-recommends -y

# clean apt cache
apt-get -y clean && rm -rf /var/lib/apt/lists/*

# set perms for nginx start script
chmod 777 /opt/nginx/startnginx.sh && \

# remove nginx defaults
rm -f /etc/nginx/sites-available/default /etc/nginx/sites-enabled/default && \

# create sites-enabled and symlink available sites to enabled directory
mkdir -p /etc/nginx/sites-enabled/ && \
for SITE in /etc/nginx/sites-available/*; do 
    [ -e "$SITE" ] || continue; 
    ln -sf $SITE /etc/nginx/sites-enabled/`basename $SITE`; 
done

# create stream-enabled and symlink available streams to enabled directory
mkdir -p /etc/nginx/stream-enabled/ && \
for SITE in /etc/nginx/stream-available/*; do 
    [ -e "$SITE" ] || continue;
    ln -sf $SITE /etc/nginx/stream-enabled/`basename $SITE`;
done

# Set misc permissions
mkdir -p /var/www/html && chmod 777 /var/www/html 
chmod 777 /var/lib/nginx
chmod -R 777 /var/log/nginx && \
chmod -R 755 /hooks /init && \
chmod 755 /var/www && \
chmod -R 666 /etc/nginx/sites-* /etc/nginx/conf.d/* /etc/nginx/stream.d/* /etc/nginx/stream-*