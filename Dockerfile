FROM alpine:3.4

# Install required packages
RUN apk add --no-cache \
      boost-system \
      boost-thread \
      ca-certificates \
      qt5-qtbase

COPY main.patch /

RUN set -x \
    # Install build dependencies
 && apk add --no-cache -t deps \
      boost-dev \
      curl \
      cmake \
      g++ \
      make \
      qt5-qttools-dev \
    \
    # Install dumb-init
    # https://github.com/Yelp/dumb-init
 && curl -Lo /usr/local/bin/dumb-init https://github.com/Yelp/dumb-init/releases/download/v1.1.3/dumb-init_1.1.3_amd64 \
 && chmod +x /usr/local/bin/dumb-init \
    \
    # Build lib rasterbar from source code (required by qBittorrent)
 && LIBTORRENT_RASTERBAR_URL=$(curl -L http://www.qbittorrent.org/download.php | grep -Eo 'https?://[^"]*libtorrent[^"]*\.tar\.gz[^"]*' | head -n1) \
 && curl -L $LIBTORRENT_RASTERBAR_URL | tar xzC /tmp \
 && cd /tmp/libtorrent-rasterbar* \
 && mkdir build \
 && cd build \
 && cmake .. \
 && make install \
    \
    # Build qBittorrent from source code
 && QBITTORRENT_URL=$(curl -L http://www.qbittorrent.org/download.php | grep -Eo 'https?://[^"]*qbittorrent[^"]*\.tar\.xz[^"]*' | head -n1) \
 && curl -L $QBITTORRENT_URL | tar xJC /tmp \
 && cd /tmp/qbittorrent* \
 && ln -s /usr/bin/lrelease /usr/bin/lrelease-qt4 \
 && PKG_CONFIG_PATH=/usr/local/lib/pkgconfig ./configure --disable-gui \
    # Patch: Disable stack trace because it requires libexecline-dev which isn't available on Alpine 3.4.
 && cd src/app \
 && patch -i /main.patch \
 && rm /main.patch \
 && cd ../.. \
 && make install \
    \
    # Clean-up
 && cd / \
 && apk del --purge deps \
 && rm -rf /tmp/* \
    \
    # Add non-root user
 && adduser -S -D -u 520 -g 520 -s /sbin/nologin qbittorrent \
    \
    # Create symbolic links to simplify mounting
 && mkdir -p /home/qbittorrent/.config/qBittorrent \
 && mkdir -p /home/qbittorrent/.local/share/data/qBittorrent \
 && mkdir /downloads \
 && chmod go+rw -R /home/qbittorrent /downloads \
 && ln -s /home/qbittorrent/.config/qBittorrent /config \
 && ln -s /home/qbittorrent/.local/share/data/qBittorrent /torrents \
    \
    # Check it works
 && su qbittorrent -s /bin/sh -c 'qbittorrent-nox -v'

# Default configuration file.
COPY qBittorrent.conf /default/qBittorrent.conf
COPY entrypoint.sh /

VOLUME ["/config", "/torrents", "/downloads"]

ENV HOME=/home/qbittorrent

USER qbittorrent

EXPOSE 8080 6881

ENTRYPOINT ["dumb-init", "/entrypoint.sh"]
CMD ["qbittorrent-nox"]
