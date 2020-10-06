FROM php:7.4-fpm

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update -qq && apt-get dist-upgrade -qqy && \
    apt-get install libpq-dev -qqy && \
    apt-get install libgmp-dev -qqy && \
    docker-php-ext-configure pgsql -with-pgsql=/usr/local/pgsql && \
    docker-php-ext-install pdo pdo_pgsql pgsql && \
    docker-php-ext-install gmp