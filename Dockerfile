FROM php:8.5-fpm

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
RUN curl -fsSL https://nginx.org/keys/nginx_signing.key | gpg --dearmor -o /usr/share/keyrings/nginx-archive-keyring.gpg \
  && echo "deb [signed-by=/usr/share/keyrings/nginx-archive-keyring.gpg] http://nginx.org/packages/debian/ bookworm nginx" > /etc/apt/sources.list.d/nginx.list \
  && apt-get update && apt-get install -y nginx \
  && rm -rf /var/lib/apt/lists/*

#Add PostgreSQL repo for pg18 client
RUN curl -fsSL https://www.postgresql.org/media/keys/ACCC4CF8.asc | gpg --dearmor -o /usr/share/keyrings/postgresql-archive-keyring.gpg \
  && echo "deb [signed-by=/usr/share/keyrings/postgresql-archive-keyring.gpg] http://apt.postgresql.org/pub/repos/apt bookworm-pgdg main" > /etc/apt/sources.list.d/pgdg.list \
  && apt-get update && apt-get install -y postgresql-client-18 \
  && rm -rf /var/lib/apt/lists/*

RUN pecl install redis-6.3.0 \
  && docker-php-ext-enable redis \
  && docker-php-ext-install zip pcntl sockets pdo pdo_pgsql

RUN sed -i -e 's/# sv_SE.UTF-8 UTF-8/sv_SE.UTF-8 UTF-8/' /etc/locale.gen && \
  dpkg-reconfigure --frontend=noninteractive locales

