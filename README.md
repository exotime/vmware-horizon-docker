
# VMware Horizon Client in a Docker container

A container built on Ubuntu 16.04, this downloads the VMware Horizon client and
includes all the necessary dependencies for you to connect to your VMware DaaS
infrastructure, within a container on your machine.

Nice for when you don't want your host to have all the dependencies installed,
or you'd like some isolation between the VMware binary and the rest of
your machine.

## How to run:
To run the container from the prebuilt image on [Docker Hub](https://hub.docker.com/r/exotime/vmware-horizon-docker/), run this:

    $ docker run -it \
            -v /tmp/.X11-unix:/tmp/.X11-unix \
            -e DISPLAY=$DISPLAY \
            --device /dev/snd \
            exotime/vmware-horizon-docker


## How to build it for yourself:

Building the container locally is also easy:

    $ git clone https://github.com/exotime/vmware-horizon-docker
    $ cd vmware-horizon-docker
    $ docker build .

