# debian-small: see https://gist.github.com/0xquad/8aa3812ea7788d2bc687
FROM debian-small
MAINTAINER Alexandre Hamelin <alexandre.hamelin gmail.com>
LABEL description="A docker image holding the Gentoo portage tree to build Gentoo images" \
      copyright="(c) 2015, Alexandre Hamelin <alexandre.hamelin gmail.com>" \
      license="MIT"
RUN apt-get update && \
    apt-get install -y apt-transport-https && \
    apt-key adv --keyserver hkp://pgp.mit.edu:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D && \
    echo "deb https://apt.dockerproject.org/repo debian-jessie main" >> /etc/apt/sources.list && \
    apt-get update && \
    apt-get install -y wget bzip2 xz-utils docker-engine && \
    rm -fr /var/lib/apt /usr/share/{doc,man}
RUN wget -q -T 2 -t 2 \
    ${GENTOO_MIRROR:-http://gentoo.osuosl.org/}/snapshots/portage-latest.tar.xz && \
    tar -xJf portage-latest.tar.xz -C /usr && \
    rm portage-latest.tar.xz
COPY build.sh /usr/local/sbin/
ENTRYPOINT ["/usr/local/sbin/build.sh"]
VOLUME /run/docker.sock
