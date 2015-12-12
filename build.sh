#!/bin/bash

: ${GENTOO_MIRROR:=http://mirror.csclub.uwaterloo.ca/gentoo-distfiles}
: ${PORTDIR:=/portage}
: ${BASEIMG:=gentoo/stage3-amd64}

[[ -e ${PORTDIR} ]] || {
    curl -sL ${GENTOO_MIRROR}/snapshots/portage-latest.tar.xz | \
        tar -Jxf - -C ${PORTDIR%/*}/
}
cid=$(docker run -dt -v ${PORTDIR}:/usr/portage $BASEDIR})
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
