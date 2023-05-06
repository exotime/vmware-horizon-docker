# VMware Horizon Client in a Docker container

[![](https://images.microbadger.com/badges/image/exotime/vmware-horizon-docker.svg)](https://microbadger.com/images/exotime/vmware-horizon-docker)

A container built on Debian Bullseye, this downloads the VMware Horizon client
and includes all the necessary dependencies for you to connect to your VMware
DaaS infrastructure, within a container on your machine.

Nice for when you don't want your host to have all the dependencies installed,
or you'd like some isolation between the VMware binary and the rest of
your machine.

While this container will run the client as root by default, using [Podman](https://podman.io/),
it can be run as any user easily.

## VMware View Configuration

There are two files related to the VMware Horizon Client configuration. They
are copied into /etc/vmware/ when the container is built, and provide two types
of configuration - user changeable, and immutable. This can be handy to enforce
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

## GTK/Gnome Theme Support
Normally, the container will not have access to your Gnome themes, icons, etc.
However, these can be mounted into the container and the client will use them just fine.
The `run-gnome.sh` script includes a way to detect the themes configured on the
running dconf based desktop and mount them into the container:

```shell
IMAGE_NAME=${IMAGE_NAME:-exotime/vmware-horizon-docker}

if [[ "${XDG_SESSION_DESKTOP}" = "deepin" ]]; then
    ICON_THEME=$(gsettings get com.deepin.dde.appearance icon-theme | tr -d "'")
    GTK_THEME=$(gsettings get com.deepin.dde.appearance gtk-theme | tr -d "'")
    CURSOR_THEME=$(gsettings get com.deepin.dde.appearance cursor-theme | tr -d "'")
else
    ICON_THEME=$(gsettings get org.gnome.desktop.interface icon-theme | tr -d "'")
    GTK_THEME=$(gsettings get org.gnome.desktop.interface gtk-theme | tr -d "'")
    CURSOR_THEME=$(gsettings get org.gnome.desktop.interface cursor-theme | tr -d "'")
fi

if [[ ! "${CURSOR_THEME}" = "${ICON_THEME}" ]]; then
    if [[ -d "${HOME}/.icons/${CURSOR_THEME}" ]]; then
        CURSOR_THEME="-v ${HOME}/.icons/${CURSOR_THEME}:/usr/share/icons/${CURSOR_THEME}:ro"
    elif [[ -d "${HOME}/.local/share/icons/${CURSOR_THEME}" ]]; then
        CURSOR_THEME="-v ${HOME}/.local/share/icons/${CURSOR_THEME}:/usr/share/icons/${CURSOR_THEME}:ro"
    elif [[ -d "/usr/share/icons/${CURSOR_THEME}" ]]; then
        CURSOR_THEME="-v /usr/share/icons/${CURSOR_THEME}:/usr/share/icons/${CURSOR_THEME}:ro"
    else
        CURSOR_THEME=""
    fi
else
    CURSOR_THEME=""
fi

if [[ -d "${HOME}/.icons/${ICON_THEME}" ]]; then
    ICON_THEME="-v ${HOME}/.icons/${ICON_THEME}:/usr/share/icons/${ICON_THEME}:ro"
elif [[ -d "${HOME}/.local/share/icons/${ICON_THEME}" ]]; then
    ICON_THEME="-v ${HOME}/.local/share/icons/${ICON_THEME}:/usr/share/icons/${ICON_THEME}:ro"
elif [[ -d "/usr/share/icons/${ICON_THEME}" ]]; then
    ICON_THEME="-v /usr/share/icons/${ICON_THEME}:/usr/share/icons/${ICON_THEME}:ro"
else
    ICON_THEME=""
fi

if [[ -d "${HOME}/.themes/${GTK_THEME}" ]]; then
    GTK_THEME="-v ${HOME}/.themes/${GTK_THEME}:/usr/share/themes/${GTK_THEME}:ro"
elif [[ -d "${HOME}/.local/share/themes/${GTK_THEME}" ]]; then
    GTK_THEME="-v ${HOME}/.local/share/themes/${GTK_THEME}:/usr/share/themes/${GTK_THEME}:ro"
elif [[ -d "/usr/share/themes/${GTK_THEME}" ]]; then
    GTK_THEME="-v /usr/share/themes/${GTK_THEME}:/usr/share/themes/${GTK_THEME}:ro"
else
    GTK_THEME=""
fi

GTK_ENGINES=""
for ENGINE64 in $(find /usr/lib64/gtk*/*/engines -iname '*.so'); do
    GTK_ENGINES="${GTK_ENGINES} -v ${ENGINE64}:/usr/lib/x86_64-linux-gnu/$(echo ${ENGINE64} | sed 's|/usr/lib64/||'):ro"
done

docker run --rm -it \
            --privileged \
            -v /tmp/.X11-unix:/tmp/.X11-unix \
            -v ${HOME}/.vmware:/root/.vmware/ \
            -v /etc/localtime:/etc/localtime:ro \
            -v /dev/bus/usb:/dev/bus/usb \
            -v ${HOME}:/home/$(whoami) \
            -e DISPLAY=$DISPLAY \
            --device /dev/snd \
            ${ICON_THEME} ${GTK_THEME} ${CURSOR_THEME} ${GTK_ENGINES} ${IMAGE_NAME}
```

## How to build it for yourself:

Building the container locally is also easy:

```shell
    $ git clone https://github.com/exotime/vmware-horizon-docker
    $ cd vmware-horizon-docker
    $ docker build .
```
