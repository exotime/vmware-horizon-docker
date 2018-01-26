FROM debian:stretch
LABEL maintainer="exotime <exotime@users.noreply.github.com>"
LABEL version="0.1.1"

# Update this URL as necessary. One day I might work this into the script.
# Run the following command to find the latest URL:
# $ curl -s "https://my.vmware.com/web/vmware/details?downloadGroup=CART18FQ4_LIN64_470&productId=578&rPId=20573" | grep -o '<a href="http[^"]*.x64.bundle"' | sed 's/<a href="//;s/"$//' `
ENV URL https://download3.vmware.com/software/view/viewclients/CART18FQ4/VMware-Horizon-Client-4.7.0-7395152.x64.bundle

# To run the container:
# $ xhost local:docker
#
# $ docker run -it \
#       -v /tmp/.X11-unix:/tmp/.X11-unix \
#       -e DISPLAY=$DISPLAY \
#       --device /dev/snd \
#       exotime/vmware-horizon

RUN apt update && \
    apt install --yes --no-install-recommends \
        binutils \
        ca-certificates \
        curl \
        freerdp-x11 \
        libatk1.0-dev \
        libgdk-pixbuf2.0-dev \
        libgtk2.0-dev \
        libusb-dev \
        libxtst-dev \
        libxss-dev \
        grep \
        python \
        rdesktop \
        sed \
        tar \
        wget && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN wget $URL && \
    chmod +x VMware-Horizon-Client-*.x64.bundle && \
    env TERM=dumb VMWARE_EULAS_AGREED=yes ./VMware-Horizon-Client-*.x64.bundle --console --required && \
    rm ./VMware-Horizon-Client-*.x64.bundle

# Run it!
CMD /usr/lib/vmware/view/usb/vmware-usbarbitrator & /usr/lib/vmware/view/usb/vmware-view-usbd &  /usr/bin/vmware-view
