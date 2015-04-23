#!/bin/sh

if [ ! -f /config/qBittorrent.conf ]
then
	cp /default/qBittorrent.conf /config/qBittorrent.conf
fi

echo "Starting qbittorrent..."
exec qbittorrent-nox