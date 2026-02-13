#!/bin/bash
# Script #3/3
# This script is designed to replicate the commands in the Dockerfile for the 
# lancachenet/monolithic docker img located at 
# https://github.com/lancachenet/monolithic

# Run this script after running lancache-1-ubuntu.sh and lancache-2-ubuntu-nginx.sh

# exit script if any step fails
set -e

# update, upgrade, and install dependencies
apt-get update -y && apt-get install jq --no-install-recommends -y

# create env file, add it to .bashrc and activate them
cat <<EOF >> ~/lancache-monolithic.env
# LanCache Script 3 - lancachenet/monolithic environment variables
export GENERICCACHE_VERSION=2
export CACHE_MODE=monolithic
export WEBUSER=www-data
export CACHE_INDEX_SIZE=500m
export CACHE_DISK_SIZE=50g
export MIN_FREE_DISK=10g
export CACHE_MAX_AGE=3560d
export CACHE_SLICE_SIZE=1m
export UPSTREAM_DNS="8.8.8.8 8.8.4.4"
export BEAT_TIME=1h
export LOGFILE_RETENTION=3560
export CACHE_DOMAINS_REPO="https://github.com/uklans/cache-domains.git"
export CACHE_DOMAINS_BRANCH=master
export NGINX_WORKER_PROCESSES=auto
export NGINX_LOG_FORMAT=cachelog
export LOG_FORMAT=cachelog
EOF
echo "source /root/lancache-monolithic.env" >> ~/.bashrc
source ~/.bashrc

# clone/fetch the github repo and copy overlay directory
if [ -d ~/lancachenet-monolithic ]; then 
    git -C ~/lancachenet-monolithic fetch
else
    git clone https://github.com/lancachenet/monolithic.git ~/lancachenet-monolithic
fi
cp -r ~/lancachenet-monolithic/overlay/* /

# delete nginx defaults
rm -f /etc/nginx/sites-enabled/* /etc/nginx/stream-enabled/*
rm -f /etc/nginx/conf.d/gzip.conf

#create dummy tallylog and set perms
touch /var/log/tallylog && \
chmod 754  /var/log/tallylog

# create WEBUSER with disabled login
id -u ${WEBUSER} &> /dev/null || adduser --system --home /var/www/ --no-create-home --shell /bin/false --group --disabled-login ${WEBUSER} ;\

# create misc directories
mkdir -m 755 -p /data/cache
mkdir -m 755 -p /data/info
mkdir -m 755 -p /data/logs
mkdir -m 755 -p /tmp/nginx/

# set perms/ownership  
chmod 755 /scripts/*
chown -R ${WEBUSER}:${WEBUSER} /data

# create sites-enabled and symlink available sites to enabled directory    
mkdir -p /etc/nginx/sites-enabled
ln -sf /etc/nginx/sites-available/10_cache.conf /etc/nginx/sites-enabled/10_generic.conf
ln -sf /etc/nginx/sites-available/20_upstream.conf /etc/nginx/sites-enabled/20_upstream.conf
ln -sf /etc/nginx/sites-available/30_metrics.conf /etc/nginx/sites-enabled/30_metrics.conf
ln -sf /etc/nginx/stream-available/10_sni.conf /etc/nginx/stream-enabled/10_sni.conf

# clone the cache-domains repo if it doesnt already exist
# modified and adapated from '/overlay/hooks/entrypoint-pre.d/15_generate_maps.sh'
export GIT_SSH_COMMAND="ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no"
if [ -d /data/cachedomains.git ]; then 
    git fetch origin
    git reset --hard origin/${CACHE_DOMAINS_BRANCH}
else
    git clone --depth=1 --no-single-branch https://github.com/uklans/cache-domains/ /data/cachedomains
fi

# Create volume mount points
mkdir -p /data/logs /data/cache /data/cachedomains /var/www

# Create /scripts symlink in home directory (WORKDIR replacement)
ln -fs /scripts ~/scripts
