#!/bin/bash

: ${GENTOO_MIRROR:=http://mirror.csclub.uwaterloo.ca/gentoo-distfiles}
: ${PORTDIR:=/portage}
: ${BASEIMG:=gentoo/stage3-amd64}

docker version >/dev/null 2>&1 || {
    echo "Docker version cannot be determined"
    exit 1
}

[[ $# -ne 0 ]] || {
    echo "No arguments given."
    echo "usage: docker run -dt builder ARGS..."
    echo "ARGS are packages to install to create a new Gentoo image"
    exit 1
}

[[ -e ${PORTDIR} ]] || {
    curl -sL ${GENTOO_MIRROR}/snapshots/portage-latest.tar.xz | \
        tar -Jxf - -C ${PORTDIR%/*}/
}

# TODO: Check for a valid $BASEIMG image

cid=$(docker run -dt -v ${PORTDIR}:/usr/portage $BASEIMG})
docker exec $cid emerge -q eix gentoolkit vim net-misc/curl
docker exec $cid eselect news read --quiet
docker exec $cid eix-update
docker exec $cid q -r
docker exec $cid sed -i -e '$a MAKEOPTS="-j2"' /etc/portage/make.conf
docker stop $cid
sleep 1
docker commit -c 'CMD ["bash"]' -c 'VOLUME /usr/portage' $cid gentoo-base
docker rm $cid
echo "Base Gentoo image created."
docker images | awk '$1 == "gentoo-base"'
