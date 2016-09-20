FROM debian:jessie

RUN buildDeps=' \
         cmake \
         curl \
         g++ \
         libboost-system-dev \
         libqt4-dev \
         libssl-dev \
         make \
         pkg-config \
         qtbase5-dev \
         qttools5-dev-tools \
    ' \
    && set -x \

       # Install dependencies
    && apt-get update \
    && apt-get install -y --no-install-recommends \
         $buildDeps \
         ca-certificates \
         libboost-system1.55.0 \
         libc6 \
         libgcc1 \
         libqt4-network \
         libqt5network5 \
         libqt5widgets5 \
         libqt5xml5 \
         libqtcore4 \
         libstdc++6 \
         zlib1g \

       # Build lib rasterbar from source code (required by qBittorrent)
    && LIBTORRENT_RASTERBAR_URL=$(curl -L http://www.qbittorrent.org/download.php | grep -Eo 'https?://[^"]*libtorrent[^"]*\.tar\.gz[^"]*' | head -n1) \
    && mkdir -p /tmp/libtorrent-rasterbar \
    && curl -L $LIBTORRENT_RASTERBAR_URL | tar xzC /tmp/libtorrent-rasterbar --strip-components=1 \
    && cd /tmp/libtorrent-rasterbar \
    && mkdir build \
    && cd build \
    && cmake .. \
    && make install \

       # Build qBittorrent from source code
    && QBITTORRENT_URL=$(curl -L http://www.qbittorrent.org/download.php | grep -Eo 'https?://[^"]*qbittorrent[^"]*\.tar\.gz[^"]*' | head -n1) \
    && mkdir -p /tmp/qbittorrent \
    && curl -L $QBITTORRENT_URL | tar xzC /tmp/qbittorrent --strip-components=1 \
    && cd /tmp/qbittorrent \
    && ./configure --disable-gui \
    && make install \

       # Clean-up
    && apt-get purge --auto-remove -y $buildDeps \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \

       # Create symbolic links to simplify mounting
    && useradd --system --uid 520 -m --shell /usr/sbin/nologin qbittorrent \

    && mkdir -p /home/qbittorrent/.config/qBittorrent \
    && ln -s /home/qbittorrent/.config/qBittorrent /config \

    && mkdir -p /home/qbittorrent/.local/share/data/qBittorrent \
    && ln -s /home/qbittorrent/.local/share/data/qBittorrent /torrents \

    && chown -R qbittorrent:qbittorrent /home/qbittorrent/ \

    && mkdir /downloads \
    && chown qbittorrent:qbittorrent /downloads

# Default configuration file.
COPY qBittorrent.conf /default/qBittorrent.conf
COPY entrypoint.sh /

VOLUME ["/config", "/torrents", "/downloads"]

EXPOSE 8080 6881

USER qbittorrent

ENTRYPOINT ["/entrypoint.sh"]
CMD ["qbittorrent-nox"]
