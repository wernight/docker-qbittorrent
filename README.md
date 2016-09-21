Supported tags and respective `Dockerfile` links
================================================

  * [`latest` is the latest release built from source code on Alpine Linux (currently 3.3.x)](https://github.com/wernight/docker-qbittorrent/blob/master/Dockerfile) [![](https://images.microbadger.com/badges/image/wernight/qbittorrent.svg)](http://microbadger.com/images/wernight/qbittorrent "Get your own image badge on microbadger.com")
  * [`stable` is the latest packaged stable Debian packaged version (currently 3.1.x)](https://github.com/wernight/docker-qbittorrent/blob/stable/Dockerfile) [![](https://images.microbadger.com/badges/image/wernight/qbittorrent:stable.svg)](http://microbadger.com/images/wernight/qbittorrent "Get your own image badge on microbadger.com")
  * [`3`, `3.3`, `3.3.7` tagged version built from source code (based on Alpine)](https://github.com/wernight/docker-qbittorrent/blob/v3.3.7/Dockerfile)
  * [`3.3.3` tagged version built from source code (based on Debian)](https://github.com/wernight/docker-qbittorrent/blob/v3.3.3/Dockerfile)
  * [`3.3.1` tagged version built from source code (based on Debian)](https://github.com/wernight/docker-qbittorrent/blob/v3.3.1/Dockerfile)


What is qBittorrent?
====================

[qBittorrent](http://www.qbittorrent.org/) NoX is the headless with remote web interface version of qBittorrent BitTorrent client.

![qBittorrent logo](https://github.com/wernight/docker-qbittorrent/blob/master/docs/qbittorrent-logo.png?raw=true)


How to use this image
=====================

This image is:

  * **Small**: `:latest` is based on official [Alpine](https://registry.hub.docker.com/_/alpine/) Docker image.
  * **Simple**: Exposes correct ports, configured for remote access...
  * **Secure**: Runs as non-root user with random UID/GID `520`, and handles correctly PID 1 (using dumb-init).

Usage
-----

All mounts and ports are optional and qBittorrent will work even with only:

    $ docker run wernight/qbittorrent

... however that way some ports used to connect to peers are not exposed, accessing the
web interface requires you to proxy port 8080, and all settings as well as downloads will
be lost if the container is removed.

So let's create some directories as user 520 (`qbittorrent`):

    $ mkdir config torrents downloads
    $ chown 520 config torrents downloads

... and start using this command:

	$ docker run -d \
		-p 8080:8080 -p 6881:6881/tcp -p 6881:6881/udp \
		-v $PWD/config:/config \
		-v $PWD/torrents:/torrents \
		-v $PWD/downloads:/downloads \
		wernight/qbittorrent

... to have webUI running on [http://localhost:8080](http://localhost:8080) (username: `admin`, password: `adminadmin`) with config in the following locations mounted:

  * `/config`: qBittorrent configuration files
  * `/torrents`: Torrent files
  * `/downloads`: Download location

It is probably a good idea to add `--restart=always` so the container restarts if it goes down.

You can change `6081` to some random  port number (also change in the settings).

_Note: For the container to run, the legal notice had to be automatically accepted. By running the container, you are accepting its terms. Toggle the flag in `qBittorrent.conf` to display the notice again._

_Note: `520` was chosen randomly to prevent running as root or as another known user on your system; at least until [issue #11253](https://github.com/docker/docker/pull/11253) is fixed._

Image Variants
--------------

### `wernight/qbittorrent:<version>`

Those are tagged versions built from source code. Older versions are based on Debian while newer ones are based on Alpine Linux (just like `:latest`).

### `wernight/qbittorrent:stable`

Works like `:latest` but based on Debian using only the package manager to install it. It's **more tested**, by Debian and package manager, but the image is *larger* than the one based on Alpine and it's an *older* version.


User Feedbacks
==============

Having more issues? [Report a bug on GitHub](https://github.com/wernight/docker-qbittorrent/issues).
