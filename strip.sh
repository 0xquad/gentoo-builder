#!/bin/bash


echo "Syncing a temporary copy of the portage tree..."
emerge-webrsync -q

USE=internal-glib emerge -q1 pkgconfig
emerge -qND @world
eselect news read --quiet
etc-update -q --automode=-3

CLEAN_DELAY=0 emerge -c
rm -fr /usr/share/{doc,man} /usr/lib/python3.4/test /usr/portage /var/tmp/portage
