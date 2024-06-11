FROM debian:bullseye
LABEL maintainer="exotime <exotime@users.noreply.github.com>"
LABEL version="0.1.4"
LABEL org.opencontainers.image.source https://github.com/exotime/vmware-horizon-docker

# Update this URL as necessary. One day I might work this into the script.
# Run the following command to find the latest URL:
# $ curl -s "https://my.vmware.com/web/vmware/details?downloadGroup=CART20FQ2_LIN64_510&productId=863&rPId=34529" | grep -o '<a href="http[^"]*.x64.bundle"' | sed 's/<a href="//;s/"$//'
ENV URL https://download3.omnissa.com/software/CART25FQ1_LIN64_2312.1/VMware-Horizon-Client-2312.1-8.12.1-23543969.x64.bundle

# To run the container:
# $ xhost local:docker
#
# $ docker run -it \
#       --privileged \
#       -v /tmp/.X11-unix:/tmp/.X11-unix \
#       -v ${HOME}/.vmware:/root/.vmware/ \
#       -v /etc/localtime:/etc/localtime:ro \
#       -v /dev/bus/usb:/dev/bus/usb \
#       -e DISPLAY=$DISPLAY \
#       -e USER=$USER \
#       --device /dev/snd \
#    exotime/vmware-horizon-docker

RUN apt update && \
    apt install --yes --no-install-recommends \
        binutils \
        ca-certificates \
        curl \
        freerdp2-x11 \
        grep \
        libatk-bridge2.0-dev \
        libatk1.0-dev \
        libengine-pkcs11-openssl \
        libffi-dev \
        libgdk-pixbuf2.0-dev \
        libgtk-3-dev \
        libgtk2.0-dev \
        libpkcs11-helper1-dev \
        libpng-dev \
        libudev-dev \
        libusb-dev \
        libxss-dev \
        libxtst-dev \
        libmagic-dev \
        lsb-release \
        python \
        rdesktop \
        sed \
        tar \
        wget && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN wget $URL && \
    chmod +x VMware-Horizon-Client-*.x64.bundle && \
    env TERM=dumb VMWARE_EULAS_AGREED=yes ./VMware-Horizon-Client-*.x64.bundle --console --required -I && \
    rm ./VMware-Horizon-Client-*.x64.bundle

# Fix libudev symlink (VMware expects an older version, different path)
RUN ln -sf /lib/x86_64-linux-gnu/libudev.so.1.6.5 /lib/x86_64-linux-gnu/libudev.so.0

# Set some preferences. See here for more options:
# https://docs.vmware.com/en/VMware-Horizon-Client-for-Linux/4.7/horizon-client-linux-installation/GUID-AB6F0B4D-03DD-4E7A-AE16-BAB77CE4D42D.html
# TL;DR: Anything specified in the mandatory config cannot be overridden by the end user. Useful for enforcing that they can only connect to SSL verified servers.
RUN mkdir -p /etc/vmware/
COPY view-mandatory-config /etc/vmware/
COPY view-default-config /etc/vmware/
RUN chmod 0444 /etc/vmware/view-mandatory-config
RUN chmod 0644 /etc/vmware/view-default-config

# Run the VMware USB Arbitrator, wait for it to start, and then start the view client.
CMD /usr/lib/vmware/view/usb/vmware-usbarbitrator & sleep 15 && chmod 777 /var/run/vmware/usbarbitrator-socket && /usr/bin/vmware-view
