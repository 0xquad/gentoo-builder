# debian-small: see https://gist.github.com/0xquad/8aa3812ea7788d2bc687
FROM debian-small
LABEL A docker image holding the Gentoo portage tree to build Gentoo images
RUN apt-get update && \
    apt-get install -y apt-transport-https && \
    apt-key adv --keyserver hkp://pgp.mit.edu:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D && \
    echo "deb https://apt.dockerproject.org/repo debian-jessie main" >> /etc/apt/sources.list && \
    apt-get update && \
    apt-get install -y wget bzip2 xz-utils docker-engine && \
    rm -fr /var/lib/apt /usr/share/{doc,man}
RUN wget -T 2 -t 2 \
    ${GENTOO_MIRROR:-http://gentoo.osuosl.org/}/snapshots/portage-latest.tar.xz && \
    tar -vxJf portage-latest.tar.xz -C / && \
    rm portage-latest.tar.xz
VOLUME /run/docker.sock
VOLUME /dockerfiles
