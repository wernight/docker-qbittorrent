FROM debian:jessie

MAINTAINER Werner Beroux <werner@beroux.com>

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
    && echo "Install dependencies" \
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
    && echo "Download qBittorrent source code" \
    && LIBTORRENT_RASTERBAR_URL=https://github.com/arvidn/libtorrent/releases/download/libtorrent-1_0_8/libtorrent-rasterbar-1.0.8.tar.gz \
    && QBITTORRENT_URL=http://sourceforge.net/projects/qbittorrent/files/qbittorrent/qbittorrent-3.3.3/qbittorrent-3.3.3.tar.gz/download \
    && mkdir -p /tmp/libtorrent-rasterbar \
    && mkdir -p /tmp/qbittorrent \
    && curl -L $LIBTORRENT_RASTERBAR_URL | tar xzC /tmp/libtorrent-rasterbar --strip-components=1 \
    && curl -L $QBITTORRENT_URL | tar xzC /tmp/qbittorrent --strip-components=1 \

    && echo "Build and install" \
    && cd /tmp/libtorrent-rasterbar \
    && mkdir build \
    && cd build \
    && cmake .. \
    && make install \

    && cd /tmp/qbittorrent \
    && ./configure --disable-gui \
    && make install \

    && echo "Clean-up" \
    && apt-get purge --auto-remove -y $buildDeps \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \

    && echo "Create symbolic links to simplify mounting" \
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

VOLUME /config
VOLUME /torrents
VOLUME /downloads

EXPOSE 8080
EXPOSE 6881

USER qbittorrent

ENTRYPOINT ["/entrypoint.sh"]
CMD ["qbittorrent-nox"]
