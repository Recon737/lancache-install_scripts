#!/bin/bash
# The lancachenet\monolothic Docker container allows for 
# Docker environment variables to be substituted into the nginx files
# this script uses sed to loop through them and manually substitute ENV variables

# activate env variables
source ~/.bashrc

# Directories to scan
NGINX_DIRS=(
    "/etc/nginx/conf.d"
    "/etc/nginx/sites-available"
    "/etc/nginx/stream-available"
)

# Variables to replace (from your env file)
VARS=(
    "GENERICCACHE_VERSION"
    "CACHE_MODE"
    "WEBUSER"
    "CACHE_INDEX_SIZE"
    "CACHE_DISK_SIZE"
    "MIN_FREE_DISK"
    "CACHE_MAX_AGE"
    "CACHE_SLICE_SIZE"
    "UPSTREAM_DNS"
    "BEAT_TIME"
    "LOGFILE_RETENTION"
    "CACHE_DOMAINS_REPO"
    "CACHE_DOMAINS_BRANCH"
    "NGINX_WORKER_PROCESSES"
    "NGINX_LOG_FORMAT"
    "LOG_FORMAT"
)

# Loop through all .conf files
for DIR in "${NGINX_DIRS[@]}"; do
    [ -d "$DIR" ] || continue
    find "$DIR" -type f -name "*.conf" | while read -r FILE; do
        # Backup original
        #cp "$FILE" "${FILE}.bak.$(date +%F_%T)"
        # Replace each variable assignment with a comment
        for VAR in "${VARS[@]}"; do
            VAL="${!VAR}"
            sed -iv "s|$VAR|$VAL|g" "$FILE"
        done
    done
done

# Test Nginx configuration
nginx -t && systemctl restart nginx