ARG WORDPRESS_VERSION=6.7.2
ARG UID=1000
ARG GID=1000
ARG LIBCURL_VERSION=4

FROM bitnami/wordpress:${WORDPRESS_VERSION} AS build

ARG LIBCURL_VERSION

USER root

# install deps
RUN apt -y update && apt -y install \
    autoconf \
    pkg-config \
    gcc \
    make \
    curl \
    wget \
    imagemagick \
    zip \
    unzip \
    git \
    libc-dev \
    libbz2-dev \
    libfreetype6-dev \
    libicu-dev \
    libjpeg-dev \
    libjpeg62-turbo-dev \
    libmagickwand-dev \
    libmcrypt-dev \
    libonig-dev \
    libcurl$LIBCURL_VERSION \
    libcurl${LIBCURL_VERSION}-openssl-dev \
    libpng-dev \
    liblz4-1 \
    liblz4-dev \
    libyaml-dev \
    libyaml-0-2 \
    libssh2-1-dev \
    libwebp-dev \
    libxml2-dev \
    libxslt1-dev \
    libzip-dev \
    libsodium-dev \
    libmemcached-dev \
    libpcre3-dev \
    libssl-dev \
    libyaml-dev \
    libc-client-dev \
    libkrb5-dev \
    zlib1g-dev \
    libgd-dev \
    libmagick++-dev \
    libsodium-dev \
    libmemcached-dev

RUN pecl channel-update pecl.php.net \
    && pecl install redis yaml libsodium

FROM bitnami/wordpress:${WORDPRESS_VERSION} AS final

ARG UID
ARG GID
ARG LIBCURL_VERSION

LABEL maintainer="Martin Kovachev <miracle@nimasystems.com>"

USER root

COPY conf/php/php.ini /opt/bitnami/php/etc/php.ini
COPY conf/php/conf.d/apcu.ini /opt/bitnami/php/etc/conf.d/apcu.ini
COPY conf/php/conf.d/opcache.ini /opt/bitnami/php/etc/conf.d/opcache.ini
COPY conf/php/conf.d/redis.ini /opt/bitnami/php/etc/conf.d/redis.ini
COPY conf/php/conf.d/yaml.ini /opt/bitnami/php/etc/conf.d/yaml.ini
COPY conf/php/conf.d/imagick.ini /opt/bitnami/php/etc/conf.d/imagick.ini
COPY conf/php/conf.d/memcached.ini /opt/bitnami/php/etc/conf.d/memcached.ini
COPY conf/php/conf.d/libsodium.ini /opt/bitnami/php/etc/conf.d/libsodium.ini

COPY conf/apache/wordpress-htaccess-custom.conf /opt/bitnami/apache2/conf/vhosts/wordpress-htaccess-custom.conf

# copy all prebuilt extensions
COPY --from=build /opt/bitnami/php/lib/php/extensions /opt/bitnami/php/lib/php/extensions

# install deps
RUN apt -y update && apt -y install \
    wget \
    unzip \
    ncurses-bin \
    curl \
    vim \
    ncdu \
    mc \
    lynx \
    imagemagick \
    optipng \
    gifsicle \
    gettext \
    htmldoc \
    webp \
    jpegoptim \
    zip \
    unzip \
    git \
    ca-certificates \
    libcurl$LIBCURL_VERSION \
    libfreetype6 \
    libzip4 \
    libc-client2007e \
    libsodium23 \
    liblz4-1 \
    libyaml-0-2 \
    libmemcached11 \
    libmemcached-tools

RUN apt-get install -y acl locales \
    && echo 'en_US.UTF-8 UTF-8' >> /etc/locale.gen \
    && echo 'es_ES.UTF-8 UTF-8' >> /etc/locale.gen \
    && echo 'bg_BG.UTF-8 UTF-8' >> /etc/locale.gen \
    && echo 'de_DE.UTF-8 UTF-8' >> /etc/locale.gen \
    && echo 'fr_FR.UTF-8 UTF-8' >> /etc/locale.gen \
    && echo 'it_IT.UTF-8 UTF-8' >> /etc/locale.gen \
    && /usr/sbin/locale-gen

RUN groupadd -g "$GID" app \
    && useradd -g "$GID" -u "$UID" -d /bitnami/wordpress -s /bin/bash app \
    && mkdir -p /.config/mc /.cache/mc /.local/share/mc

# install wp-cli \
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x wp-cli.phar \
    && mv wp-cli.phar /usr/local/bin/wp \
    && wp --info

# install wp-cli bash completions \
RUN wget https://raw.githubusercontent.com/wp-cli/wp-cli/master/utils/wp-completion.bash \
    && cat wp-completion.bash >> /bitnami/wordpress/.bashrc \
    && rm -rf wp-completion.bash

WORKDIR /bitnami/wordpress

RUN chown -R app:app /bitnami/wordpress /opt/bitnami

USER $UID:$GID