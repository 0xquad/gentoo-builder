#!/bin/bash

: ${GENTOO_MIRROR:=http://mirror.csclub.uwaterloo.ca/gentoo-distfiles}
: ${PORTDIR:=/usr/portage}
: ${BASEIMG:=gentoo-minimal}

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

cid=$(docker run -dt --volumes-from $(hostname) ${BASEIMG})
[[ -z "$cid" ]] && exit 1
if ! docker exec $cid emerge -q "$@"; then
    docker stop $cid >/dev/null
    docker rm $cid >/dev/null
    exit 1
fi
docker exec $cid eselect news read --quiet
docker exec $cid eix-update
docker exec $cid q -r
docker stop $cid >/dev/null
sleep 1
newtag=gentoo-${cid:0:6}
docker commit -c 'CMD ["bash"]' -c 'VOLUME /usr/portage' $cid $newtag
docker rm $cid >/dev/null
echo "New Gentoo image created: $newtag"
docker images | awk "$(printf '$1 == "%s"' $newtag)"
