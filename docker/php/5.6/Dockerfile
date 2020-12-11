FROM php:5.6-fpm

# fix www-data user to avoid permissions issues
RUN groupmod -g 1000 www-data
RUN groupmod -g 1000 www-data

##########################################################
# Install dependencies for mailhog and redirect mail to it
##########################################################
RUN apt-get update \
    && apt-get install --no-install-recommends --assume-yes --quiet ca-certificates curl git libmcrypt-dev procps \
    && rm -rf /var/lib/apt/lists/*
RUN curl -Lsf 'https://storage.googleapis.com/golang/go1.8.3.linux-amd64.tar.gz' | tar -C '/usr/local' -xvzf -
ENV PATH /usr/local/go/bin:$PATH
RUN go get github.com/mailhog/mhsendmail
RUN cp /root/go/bin/mhsendmail /usr/bin/mhsendmail


RUN apt-get update && \
    apt-get install -qq -y libgd-dev libfreetype6-dev libjpeg62-turbo-dev libpng-dev libxml2-dev && \
    docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ && \
    docker-php-ext-install gd && \
    docker-php-ext-install soap

ADD php.ini /usr/local/etc/php/php.ini
RUN echo 'sendmail_path = /usr/bin/mhsendmail --smtp-addr mailhog:1025' >> /usr/local/etc/php/php.ini \
	&& docker-php-ext-install mysqli pdo_mysql mcrypt gd soap

ADD www.conf /usr/local/etc/php-fpm.d/www.conf
