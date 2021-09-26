FROM php:7.4-fpm

# fix www-data user to avoid permissions issues
RUN usermod -u 1000 --home /var/www/htdocs/ www-data
RUN groupmod -g 1000 www-data
 
RUN apt-get update \
  && apt-get install -y \
    libfreetype6-dev \
    libicu-dev \
    libjpeg62-turbo-dev \
    libmcrypt-dev \
    libonig-dev \
    libpng-dev \
    libxslt1-dev \
    libzip-dev \
    unzip \
    sendmail-bin \
    sendmail \
    sudo \
    cron \
    rsyslog \
    default-mysql-client \
    git

# Configure the gd library
RUN docker-php-ext-configure \
  gd --with-freetype=/usr/include/ --with-jpeg=/usr/include/

# Install required PHP extensions

RUN docker-php-ext-install \
  dom \
  gd \
  intl \
  mbstring \
  pdo_mysql \
  xsl \
  zip \
  soap \
  bcmath \
  sockets
RUN apt-get update \
    && apt-get install --no-install-recommends --assume-yes --quiet ca-certificates curl git libmcrypt-dev procps \
    && rm -rf /var/lib/apt/lists/*
RUN curl -Lsf 'https://golang.org/dl/go1.17.1.linux-arm64.tar.gz' | tar -C '/usr/local' -xzf -
ENV PATH /usr/local/go/bin:$PATH
RUN go get github.com/mailhog/mhsendmail
RUN cp /root/go/bin/mhsendmail /usr/bin/mhsendmail

ADD php.ini /usr/local/etc/php/php.ini
RUN echo 'sendmail_path = /usr/bin/mhsendmail --smtp-addr mailhog:1025' >> /usr/local/etc/php/php.ini

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

ADD www.conf /usr/local/etc/php-fpm.d/www.conf
