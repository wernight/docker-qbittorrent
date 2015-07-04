#!/bin/sh

# Allow groups to change files.
umask 002

# Default configuration file
if [ ! -f /config/qBittorrent.conf ]
then
	cp /default/qBittorrent.conf /config/qBittorrent.conf
fi

echo "Starting qbittorrent..."
exec qbittorrent-nox $*
