FROM php:8.0.12

WORKDIR /app

COPY --from=composer /usr/bin/composer /usr/bin/composer

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

RUN pecl install redis swoole \
  && docker-php-ext-enable redis \
  && docker-php-ext-install zip opcache pcntl sockets pdo pdo_pgsql

RUN sed -i -e 's/# sv_SE.UTF-8 UTF-8/sv_SE.UTF-8 UTF-8/' /etc/locale.gen && \
  dpkg-reconfigure --frontend=noninteractive locales

