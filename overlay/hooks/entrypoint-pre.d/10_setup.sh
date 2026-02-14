#!/bin/bash
set -e

NGINX_DIR=/etc
LANCACHE_DIR=/opt/lancache
ENV_FILE=$LANCACHE_DIR/lancache-monolithic.env
LANCACHENET_MONOLITHIC_DIR=$LANCACHE_DIR/lancachenet-monolithic

# Handle CACHE_MEM_SIZE deprecation
if [[ ! -z "${CACHE_MEM_SIZE}" ]]; then
    CACHE_INDEX_SIZE=${CACHE_MEM_SIZE}
fi

# Preprocess UPSTREAM_DNS to allow for multiple resolvers using the same syntax as lancache-dns
UPSTREAM_DNS="$(echo -n "${UPSTREAM_DNS}" | sed 's/[;]/ /g')"

# create template files
mkdir -p $LANCACHE_DIR/templates/nginx/conf.d
mkdir -p $LANCACHE_DIR/templates/nginx/sites-available/cache.conf.d/root
mkdir -p $LANCACHE_DIR/templates/nginx/sites-available/upstream.conf.d
mkdir -p $LANCACHE_DIR/templates/nginx/stream-available

echo "worker_processes NGINX_WORKER_PROCESSES;" > $LANCACHE_DIR/templates/nginx/workers.conf
cp $LANCACHENET_MONOLITHIC_DIR/overlay/etc/nginx/nginx.conf $LANCACHE_DIR/templates/nginx/nginx.conf
cp $LANCACHENET_MONOLITHIC_DIR/overlay/etc/nginx/conf.d/20_proxy_cache_path.conf $LANCACHE_DIR/templates/nginx/conf.d
cp $LANCACHENET_MONOLITHIC_DIR/overlay/etc/nginx/sites-available/cache.conf.d/root/20_cache.conf $LANCACHE_DIR/templates/nginx/sites-available/cache.conf.d/root
cp $LANCACHENET_MONOLITHIC_DIR/overlay/etc/nginx/sites-available/cache.conf.d/10_root.conf $LANCACHE_DIR/templates/nginx/sites-available/cache.conf.d
cp $LANCACHENET_MONOLITHIC_DIR/overlay/etc/nginx/sites-available/upstream.conf.d/10_resolver.conf $LANCACHE_DIR/templates/nginx/sites-available/upstream.conf.d
cp $LANCACHENET_MONOLITHIC_DIR/overlay/etc/nginx/stream-available/10_sni.conf $LANCACHE_DIR/templates/nginx/stream-available
cp $LANCACHENET_MONOLITHIC_DIR/overlay/etc/nginx/sites-available/10_cache.conf $LANCACHE_DIR/templates/nginx/sites-available
cp $LANCACHENET_MONOLITHIC_DIR/overlay/etc/nginx/sites-available/20_upstream.conf $LANCACHE_DIR/templates/nginx/sites-available

# substitute templates
sed -i "s/NGINX_WORKER_PROCESSES/\${NGINX_WORKER_PROCESSES}/" $LANCACHE_DIR/templates/nginx/workers.conf
sed -i "s/^user .*/user \${WEBUSER};/" $LANCACHE_DIR/templates/nginx/nginx.conf
sed -i "s/CACHE_INDEX_SIZE/\${CACHE_INDEX_SIZE}/"  $LANCACHE_DIR/templates/nginx/conf.d/20_proxy_cache_path.conf
sed -i "s/CACHE_DISK_SIZE/\${CACHE_DISK_SIZE}/" $LANCACHE_DIR/templates/nginx/conf.d/20_proxy_cache_path.conf
sed -i "s/MIN_FREE_DISK/\${MIN_FREE_DISK}/" $LANCACHE_DIR/templates/nginx/conf.d/20_proxy_cache_path.conf
sed -i "s/CACHE_MAX_AGE/\${CACHE_MAX_AGE}/" $LANCACHE_DIR/templates/nginx/conf.d/20_proxy_cache_path.conf
sed -i "s/CACHE_MAX_AGE/\${CACHE_MAX_AGE}/"    $LANCACHE_DIR/templates/nginx/sites-available/cache.conf.d/root/20_cache.conf
sed -i "s/slice 1m;/slice \${CACHE_SLICE_SIZE};/" $LANCACHE_DIR/templates/nginx/sites-available/cache.conf.d/root/20_cache.conf
sed -i "s/UPSTREAM_DNS/\${UPSTREAM_DNS}/"    $LANCACHE_DIR/templates/nginx/sites-available/cache.conf.d/10_root.conf
sed -i "s/UPSTREAM_DNS/\${UPSTREAM_DNS}/"    $LANCACHE_DIR/templates/nginx/sites-available/upstream.conf.d/10_resolver.conf
sed -i "s/UPSTREAM_DNS/\${UPSTREAM_DNS}/"    $LANCACHE_DIR/templates/nginx/stream-available/10_sni.conf
sed -i "s/LOG_FORMAT/\${NGINX_LOG_FORMAT}/"  $LANCACHE_DIR/templates/nginx/sites-available/10_cache.conf
sed -i "s/LOG_FORMAT/\${NGINX_LOG_FORMAT}/"  $LANCACHE_DIR/templates/nginx/sites-available/20_upstream.conf

# move files, and substitute variables
source $ENV_FILE
# copy base files and overlay the templates
cp -r $LANCACHENET_MONOLITHIC_DIR/overlay/etc/nginx/* $NGINX_DIR
# substitute env vars in templates and overlay into NGINX_DIR
envsubst "\$NGINX_WORKER_PROCESSES" < $LANCACHE_DIR/templates/nginx/workers.conf > $NGINX_DIR/nginx/workers.conf
envsubst "\$WEBUSER" < $LANCACHE_DIR/templates/nginx/nginx.conf > $NGINX_DIR/nginx/nginx.conf
envsubst "\$CACHE_INDEX_SIZE,\$CACHE_DISK_SIZE,\$MIN_FREE_DISK,\$CACHE_MAX_AGE" < $LANCACHE_DIR/templates/nginx/conf.d/20_proxy_cache_path.conf > $NGINX_DIR/nginx/conf.d/20_proxy_cache_path.conf
envsubst "\$CACHE_MAX_AGE,\$CACHE_SLICE_SIZE" < $LANCACHE_DIR/templates/nginx/sites-available/cache.conf.d/root/20_cache.conf > $NGINX_DIR/nginx/sites-available/cache.conf.d/root/20_cache.conf
envsubst "\$UPSTREAM_DNS" < $LANCACHE_DIR/templates/nginx/sites-available/cache.conf.d/10_root.conf > $NGINX_DIR/nginx/sites-available/cache.conf.d/10_root.conf
envsubst "\$UPSTREAM_DNS" < $LANCACHE_DIR/templates/nginx/sites-available/upstream.conf.d/10_resolver.conf > $NGINX_DIR/nginx/sites-available/upstream.conf.d/10_resolver.conf
envsubst "\$UPSTREAM_DNS" < $LANCACHE_DIR/templates/nginx/stream-available/10_sni.conf > $NGINX_DIR/nginx/stream-available/10_sni.conf
envsubst "\$NGINX_LOG_FORMAT" < $LANCACHE_DIR/templates/nginx/sites-available/10_cache.conf > $NGINX_DIR/nginx/sites-available/10_cache.conf
envsubst "\$NGINX_LOG_FORMAT" < $LANCACHE_DIR/templates/nginx/sites-available/20_upstream.conf > $NGINX_DIR/nginx/sites-available/20_upstream.conf
