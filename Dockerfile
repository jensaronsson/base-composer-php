FROM php:7.4-fpm

WORKDIR /app

RUN apt-get update && \
  apt-get install -y \
  libpq-dev \
  libzip-dev \
  gnupg2 \
  git \
  procps \
  zip \
  unzip \
  vim \
  locales \
  && rm -rf /var/lib/apt/lists/*

#Update to latest nginx
RUN echo "deb http://nginx.org/packages/debian/ stretch nginx" >> /etc/apt/sources.list.d/nginx.list \
  && echo "deb-src http://nginx.org/packages/debian/ stretch nginx" >> /etc/apt/sources.list.d/nginx.list \
  && curl -L https://nginx.org/keys/nginx_signing.key | apt-key add - \
  && apt-get update && apt-get install -y nginx \
  && rm -rf /var/lib/apt/lists/*

RUN curl -s https://getcomposer.org/installer | php -- --quiet \
  && mv composer.phar /usr/local/bin/composer \
  && composer self-update \
  && composer global require "hirak/prestissimo:^0.3" \
  && pecl install redis \
  && docker-php-ext-enable redis \
  && docker-php-ext-install zip opcache pcntl sockets pdo pdo_pgsql

RUN sed -i -e 's/# sv_SE.UTF-8 UTF-8/sv_SE.UTF-8 UTF-8/' /etc/locale.gen && \
  dpkg-reconfigure --frontend=noninteractive locales

