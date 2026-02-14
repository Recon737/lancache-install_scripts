# LanCache-Install_Scripts

A set of scripts that derived by translating the Dockerfiles of the monolithic install of [LanCache.net](https://github.com/lancachenet/monolithic)

I wrote these to help in setting up LanCache in a LXC container on proxmox. Currently, placing all scripts into /root of an Ubuntu 24.04 LXC and running install.sh produces a functional lancache server. This does not provide the lancache-dns functionality, and requires dns to be resolved separately. 

All environment variables are stored in ```/opt/lancache/lancache-monolithic.env```. Editing the fields in this file and resarting the nginx systemd service will update the nginx .conf files with the new values.