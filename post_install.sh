#!/bin/bash
source ~/.bashrc
cp -r ~/overlay/* /
chmod +x /hooks/entrypoint-pre.d/*  
chmod +x /hooks/supervisord-pre.d/*
#bash /hooks/entrypoint-pre.d/10_setup.sh
systemctl daemon-reload
systemctl restart nginx