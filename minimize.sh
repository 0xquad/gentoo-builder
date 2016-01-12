#!/bin/bash

[[ $# -eq 1 ]] || {
    echo "usage: ${0##*/} DOCKER-GENTOO-IMAGE"
    exit 1
}
image=$1
cid=$(docker run $image true)
echo "Importing minimized image"
docker export $cid | docker import -c 'VOLUME /usr/portage' -c 'CMD ["/bin/bash"]' - gentoo-minimal
cid=$(docker rm $cid)
