FROM php:8.1-fpm

WORKDIR /app

COPY --from=composer/composer:2-bin /composer /usr/bin/composer

RUN apt-get update && \
  apt-get install -y \
  postgresql-client-15 \
  libpq-dev \
  libzip-dev \
  lsb-release \
  gnupg2 \
  git \
  procps \
  zip \
  unzip \
  vim \
  locales \
  && rm -rf /var/lib/apt/lists/*

# Install postgres 15 client
RUN echo "deb https://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list \
&& curl -s https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -

RUN apt-get update && \
  apt-get install -y \
  postgresql-client-15 \
  && rm -rf /var/lib/apt/lists/*

#Update to latest nginx
RUN echo "deb http://nginx.org/packages/debian/ stretch nginx" >> /etc/apt/sources.list.d/nginx.list \
  && echo "deb-src http://nginx.org/packages/debian/ stretch nginx" >> /etc/apt/sources.list.d/nginx.list \
  && curl -L https://nginx.org/keys/nginx_signing.key | apt-key add - \
  && apt-get update && apt-get install -y nginx \
  && rm -rf /var/lib/apt/lists/*

RUN pecl install redis \
  && docker-php-ext-enable redis \
  && docker-php-ext-install zip opcache pcntl sockets pdo pdo_pgsql

RUN sed -i -e 's/# sv_SE.UTF-8 UTF-8/sv_SE.UTF-8 UTF-8/' /etc/locale.gen && \
  dpkg-reconfigure --frontend=noninteractive locales

