FROM php:8.2-fpm

WORKDIR /app

COPY --from=composer/composer:2-bin /composer /usr/bin/composer

RUN apt-get update && \
  apt-get install -y \
  libpq-dev \
  libzip-dev \
  lsb-release \
  gnupg2 \
  curl \
  git \
  procps \
  zip \
  unzip \
  vim \
  locales \
  && rm -rf /var/lib/apt/lists/*

#Update to latest nginx
RUN curl -fsSL https://nginx.org/keys/nginx_signing.key | gpg --dearmor -o /usr/share/keyrings/nginx-archive-keyring.gpg \
  && echo "deb [signed-by=/usr/share/keyrings/nginx-archive-keyring.gpg] http://nginx.org/packages/debian/ $(lsb_release -cs) nginx" > /etc/apt/sources.list.d/nginx.list \
  && apt-get update && apt-get install -y nginx \
  && rm -rf /var/lib/apt/lists/*

# Install postgres 18 client
RUN curl -fsSL https://www.postgresql.org/media/keys/ACCC4CF8.asc | gpg --dearmor -o /usr/share/keyrings/postgresql-archive-keyring.gpg \
  && echo "deb [signed-by=/usr/share/keyrings/postgresql-archive-keyring.gpg] http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list \
  && apt-get update && apt-get install -y postgresql-client-18 \
  && rm -rf /var/lib/apt/lists/*

RUN pecl install redis \
  && docker-php-ext-enable redis \
  && docker-php-ext-install zip opcache pcntl sockets pdo pdo_pgsql

RUN sed -i -e 's/# sv_SE.UTF-8 UTF-8/sv_SE.UTF-8 UTF-8/' /etc/locale.gen && \
  dpkg-reconfigure --frontend=noninteractive locales

