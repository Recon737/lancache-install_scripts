# LanCache-Install_Scripts

A set of scripts that derived by translating the Dockerfiles of the monolithic install of [LanCache.net](https://github.com/lancachenet/monolithic)

I wrote these to help in setting up LanCache in a LXC container on proxmox. Currently, placing all scripts into /root of an Ubuntu 24.04 LXC and running install.sh produces a functional lancache server. This does not provide the lancache-dns functionality, and requires dns to be resolved separately. 

All environment variables are hardcoded and embedded into the nginx files during install using scripts in ['/overlay/hooks/entrypoint-pre.d'](https://github.com/lancachenet/monolithic/tree/master/overlay/hooks/entrypoint-pre.d). Currently, the nginx service is overidden to run these scripts prior to starting nginx, but the current implementation does not allow for updating environment variables and having the new values populate into the nginx .conf files after the initial install.
