qBittorrent Docker Image
========================

[Docker](https://www.docker.com/) image for [qBittorrent](http://www.qbittorrent.org/).

Fix create some directories as user 520 (`qbittorrent`):

    $ mkdir config torrents downloads
    $ chown 520 config torrents downloads

Run using this command:

	$ docker run -d \
		-p 8080:8080 -p 6881:6881/tcp -p 6881:6881/udp \
		-v /data/qbittorrent/config:/config \
		-v /data/qbittorrent/torrents:/torrents \
		-v /data/qbittorrent/downloads:/downloads \
		wernight/qbittorrent

To have webUI running on [http://localhost:8080](http://localhost:8080) (username: `admin`, password: `adminadmin`) with config in the following locations mounted:

  * `/config`: qBittorrent configuration files
  * `/torrents`: Torrent files
  * `/downloads`: Download location

It is probably a good idea to add `--restart=always` so the container restarts if it goes down.

You should change `6081` to some random  port number (also change in the settings).

_Note: For the container to run, the legal notice had to be automatically accepted. By running the container, you are accepting its terms. Toggle the flag in `qBittorrent.conf` to display the notice again._

_Note: `520` was chosen randomly to prevent running as root or as another known user on your system; at least until [issue #11253](https://github.com/docker/docker/pull/11253) is fixed._


Feedbacks
---------

Having more issues? [Report a bug on GitHub](https://github.com/wernight/docker-qbittorrent/issues).
