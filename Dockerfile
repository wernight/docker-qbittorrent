FROM debian:jessie

MAINTAINER Werner Beroux <werner@beroux.com>

RUN apt-get update && \
    apt-get install -y qbittorrent-nox && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN useradd --system --uid 520 -m --shell /usr/sbin/nologin qbittorrent

# Default configuration file.
ADD qBittorrent.conf /default/qBittorrent.conf
ADD start.sh /

# Create symbolic links to simplify mounting
RUN ln -s /home/qbittorrent/.config/qBittorrent /config
RUN ln -s /home/qbittorrent/.local/share/data/qBittorrent /torrents
RUN mkdir /downloads && chown qbittorrent /downloads

VOLUME /config
VOLUME /torrents
VOLUME /downloads

EXPOSE 8080
EXPOSE 6881

USER qbittorrent

CMD ["/start.sh"]
