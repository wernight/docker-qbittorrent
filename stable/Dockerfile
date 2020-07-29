FROM debian:stretch-slim

RUN set -x \
    # Install qBittorrent-NoX
    && apt-get update \
    && apt-get install -y qbittorrent-nox dumb-init \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \

    # Add non-root user
    && useradd --system --uid 520 -m --shell /usr/sbin/nologin qbittorrent \

    # Create symbolic links to simplify mounting
    && mkdir -p /home/qbittorrent/.config/qBittorrent \
    && chown qbittorrent:qbittorrent /home/qbittorrent/.config/qBittorrent \
    && ln -s /home/qbittorrent/.config/qBittorrent /config \

    && mkdir -p /home/qbittorrent/.local/share/data/qBittorrent \
    && chown qbittorrent:qbittorrent /home/qbittorrent/.local/share/data/qBittorrent \
    && ln -s /home/qbittorrent/.local/share/data/qBittorrent /torrents \

    && mkdir /downloads \
    && chown qbittorrent:qbittorrent /downloads


# Default configuration file.
COPY qBittorrent.conf /default/qBittorrent.conf
COPY entrypoint.sh /

VOLUME ["/config", "/torrents", "/downloads"]

EXPOSE 8080 6881

USER qbittorrent

ENTRYPOINT ["dumb-init", "/entrypoint.sh"]
CMD ["qbittorrent-nox"]
