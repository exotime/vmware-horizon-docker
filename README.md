# VMware Horizon Client in a Docker container

[![](https://images.microbadger.com/badges/image/exotime/vmware-horizon-docker.svg)](https://microbadger.com/images/exotime/vmware-horizon-docker)

A container built on Debian Stretch, this downloads the VMware Horizon client
and includes all the necessary dependencies for you to connect to your VMware
DaaS infrastructure, within a container on your machine.

Nice for when you don't want your host to have all the dependencies installed,
or you'd like some isolation between the VMware binary and the rest of
your machine.

## VMware View Configuration

There are two files related to the VMware Horizon Client configuration. They
are copied into /etc/vmware/ when the container is built, and provide two types
of configuration - user changable, and immutable. This can be handy to enforce
settings across your environment - perhaps by enforcing that all connections
only work when the SSL certificate is verified, or not allowing users to change
the domain they connect to - but allowing them to choose the client resolution.

Some settings have been provided by default - you are free to change these as
you require. I recommend you use Docker volume mapping to map /root/.vmware/ to
the ${HOME}/.vmware/ to let users keep settings persistent between sessions.

For more information, read the [VMware Horizon Client documentation](https://docs.vmware.com/en/VMware-Horizon-Client-for-Linux/4.7/horizon-client-linux-installation/GUID-D4D962F3-0EE0-4E5C-BC0C-6BE452FF0601.html).

## How to run:
To run the container from the prebuilt image on [Docker Hub](https://hub.docker.com/r/exotime/vmware-horizon-docker/), run this:

```shell
    $ docker run -it \
            --privileged \
            -v /tmp/.X11-unix:/tmp/.X11-unix \
            -v ${HOME}/.vmware:/root/.vmware/ \
            -v /etc/localtime:/etc/localtime:ro \
            -v /dev/bus/usb:/dev/bus/usb \
            -e DISPLAY=$DISPLAY \
            --device /dev/snd \
            exotime/vmware-horizon-docker
```

## How to build it for yourself:

Building the container locally is also easy:

```shell
    $ git clone https://github.com/exotime/vmware-horizon-docker
    $ cd vmware-horizon-docker
    $ docker build .
```
