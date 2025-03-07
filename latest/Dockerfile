# https://hub.docker.com/_/alpine
FROM alpine:3.20

# Install required packages
RUN apk add --no-cache \
        boost \
        ca-certificates \
        curl \
        dumb-init \
        icu \
        libtool \
        openssl \
        python3 \
        qt6-qtbase \
        qt6-qtsvg \
        qt6-qttools \
        re2c \
        zlib

# Compiling qBitTorrent following instructions on
# https://github.com/qbittorrent/qBittorrent/wiki/Compilation-Alpine-Linux
RUN set -x \
    #
    # Install build dependencies
 && apk add --no-cache -t .build-deps \
        autoconf \
        automake \
        boost-dev \
        build-base \
        cmake \
        git \
        jq \
        libtool \
        linux-headers \
        ninja-build \
        ninja-is-really-ninja \
        perl \
        pkgconf \
        python3 \
        python3-dev \
        re2c \
        tar \
        icu-dev \
        openssl-dev \
        qt6-qtbase-dev \
        qt6-qttools-dev \
        zlib-dev \
        qt6-qtsvg-dev \
        xz \
    #
    # Boost
    # https://github.com/boostorg/boost/releases
 && mkdir -p ~/boost-dev \
 && curl -L https://github.com/boostorg/boost/releases/download/boost-1.86.0/boost-1.86.0-b2-nodocs.tar.xz | tar xJf - --strip-components=1 -C ~/boost-dev \
    #
    # Libtorrent
 && git clone --shallow-submodules --recurse-submodules https://github.com/arvidn/libtorrent.git /tmp/libtorrent \
 && cd /tmp/libtorrent \
 && git checkout "$(git tag -l --sort=-v:refname | awk '/v2/' | head -1)" \
 && cmake -Wno-dev -G Ninja -B build \
        -D CMAKE_BUILD_TYPE="Release" \
        -D CMAKE_CXX_STANDARD=20 \
        -D BOOST_INCLUDEDIR="$HOME/boost-dev/" \
        -D CMAKE_INSTALL_LIBDIR="lib" \
        -D CMAKE_INSTALL_PREFIX="/usr/local" \
 && cmake --build build \
 && cmake --install build \
    #
    # Build qBittorrent
 && git clone --shallow-submodules --recurse-submodules https://github.com/qbittorrent/qBittorrent.git /tmp/qbittorrent \
 && cd /tmp/qbittorrent \
 && git checkout "$(git tag -l --sort=-v:refname | awk '!/[0-9][a-zA-Z]/' | head -1)" \
 && cmake -Wno-dev -G Ninja -B build \
        -D CMAKE_BUILD_TYPE="release" \
        -D CMAKE_CXX_STANDARD=20 \
        -D BOOST_INCLUDEDIR="$HOME/boost-dev/" \
        -D CMAKE_INSTALL_PREFIX="/usr/local" \
        -D GUI=OFF \
 && cmake --build build \
 && cmake --install build \
    #
    # Clean-up
 && cd / \
 && apk del --purge .build-deps \
 && rm -rf ~/boost-dev/ \
 && rm -rf /tmp/*

RUN set -x \
    # Add non-root user
 && adduser -S -D -u 520 -g 520 -s /sbin/nologin qbittorrent \
    # Create symbolic links to simplify mounting
 && mkdir -p /home/qbittorrent/.config/qBittorrent \
 && mkdir -p /home/qbittorrent/.local/share/qBittorrent \
 && mkdir /downloads \
 && chmod go+rw -R /home/qbittorrent /downloads \
 && ln -s /home/qbittorrent/.config/qBittorrent /config \
 && ln -s /home/qbittorrent/.local/share/qBittorrent /torrents \
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

HEALTHCHECK --interval=5s --timeout=2s --retries=20 CMD curl --connect-timeout 15 --silent --show-error --fail http://localhost:8080/ >/dev/null || exit 1
