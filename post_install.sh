#!/bin/bash
source ~/.bashrc
chmod +x /hooks/entrypoint-pre.d/*  
chmod +x /hooks/supervisord-pre.d/*
#bash /hooks/entrypoint-pre.d/10_setup.sh
cp -r ~/overlay/* /
systemctl daemon-reload
systemctl restart nginx