#!/bin/bash
./lancache-1-ubuntu.sh
./lancache-2-ubuntu-nginx.sh
./lancache-3-monolithic.sh
./fix_nginx_env_vars.sh