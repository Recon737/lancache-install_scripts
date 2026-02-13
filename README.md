# LanCache-Install_Scripts

A set of scripts that derived by translating the Dockerfiles of the monolithic install of [LanCache.net](https://github.com/lancachenet/monolithic)

I wrote these to help in setting up LanCache in a LXC container on proxmox. Currently, placing all scripts into /root of an Ubuntu 24.04 LXC and running install.sh produces a functional lancache server. This does not provide the lancache-dns functionality, and requires dns to be resolved separately. 

All environment variables are hardcoded and embedded into the nginx files during install using scripts in ['/overlay/hooks/entrypoint-pre.d'](https://github.com/lancachenet/monolithic/tree/master/overlay/hooks/entrypoint-pre.d). In the future, modifying the nginx.service to execute them prior to starting should allow for updating the env variables and populating the new values to the nginx .conf files.
