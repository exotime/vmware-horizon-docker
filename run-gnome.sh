#!/bin/bash
# This script will launch the VMWare Horizon Client via Docker and has
# been tested on Fedora 30 with the Deepin desktop. It should, in theory
# work for Gnome too as well as others that use the same gsettings keys.
#
# It should also work for those that don't, but you won't get theme
# support.
#
# THIS WILL RUN VMWARE VIEW AS ROOT WHICH IS A TERRIBLE IDEA. SORRY.
# Someone may be able to work around this by tweaking the container
# and passing `--user` to Docker but...
#
# This was tested with Podman, which won't run it as root, by the way.
set -e
IMAGE_NAME=${IMAGE_NAME:-exotime/vmware-horizon-docker}

if [[ "${1}" = "check-image" ]] ; then
    [[ -z "$(docker images -q -f "reference=${IMAGE_NAME}" 2>/dev/null)" ]]
elif [[ "${1}" = "pull-only" ]] ; then
    docker pull ${IMAGE_NAME}
else
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
fi
