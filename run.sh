#!/bin/bash

# Sometimes this is needed to allow the container to talk to Xorg.
# If you're having problems connecting to the socket, try uncommenting this.
#xhost local:docker

docker run -it \
        --privileged \
        -v /tmp/.X11-unix:/tmp/.X11-unix \
        -v ${HOME}/.vmware:/root/.vmware/ \
        -v /etc/localtime:/etc/localtime:ro \
        -v /dev/bus/usb:/dev/bus/usb \
        -e DISPLAY=unix$DISPLAY \
        -e USER=$USER \
        --device /dev/snd \
	exotime/vmware-horizon-docker:latest
