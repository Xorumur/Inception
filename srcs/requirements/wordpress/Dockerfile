FROM alpine:3.16
ARG PHP_VERSION=8 \
    DB_NAME \
    DB_USER \
    DB_PASS
RUN apk update && apk upgrade && apk add --no-cache \
    php${PHP_VERSION} \
    php${PHP_VERSION}-fpm \
    php${PHP_VERSION}-mysqli \
    php${PHP_VERSION}-json \
    php${PHP_VERSION}-curl \
    php${PHP_VERSION}-dom \
    php${PHP_VERSION}-exif \
    php${PHP_VERSION}-fileinfo \
    php${PHP_VERSION}-mbstring \
    php${PHP_VERSION}-openssl \
    php${PHP_VERSION}-xml \
    php${PHP_VERSION}-zip \
    php${PHP_VERSION}-redis \
    php-phar \
    wget \
    unzip && \
    sed -i "s|listen = 127.0.0.1:9000|listen = 9000|g" \
      /etc/php8/php-fpm.d/www.conf && \
    sed -i "s|;listen.owner = nobody|listen.owner = nobody|g" \
      /etc/php8/php-fpm.d/www.conf && \
    sed -i "s|;listen.group = nobody|listen.group = nobody|g" \
      /etc/php8/php-fpm.d/www.conf && \
    rm -f /var/cache/apk/*

#RUN rm -rf /etc/php8/php-fpm.d/www.conf
#COPY www.conf /etc/php8/php-fpm.d/www.conf
#    sed -i 's|listen = 127.0.0.1:9000|listen = 9000|g' \
#    /etc/php8/php-fpm.d/www.conf \
#    sed -i 's|;listen.owner = nobody|listen.owner = nobody|g' \
#    /etc/php8/php-fpm.d/www.conf \
#    sed -i 's|;listen.group = nobody|listen.group = nobody|g' \
#    /etc/php8/php-fpm.d/www.conf \
#    && rm -f /var/cache/apk/*



WORKDIR /var/www/
#RUN wget https://wordpress.org/latest.zip && \
#    unzip latest.zip && \
#    cp -rf wordpress/* . && \
#    rm -rf wordpress latest.zipi

RUN wget https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar 

RUN chmod +x wp-cli.phar

RUN mv -f wp-cli.phar /usr/local/bin/wp

RUN wp core download --allow-root --path="/var/www"

COPY ./requirements/wordpress/conf/wp-config-create.sh .
RUN sh wp-config-create.sh && rm wp-config-create.sh


#RUN wp core install --allow-root --url=$DOMAIN_NAME --title=$TITLE --admin_user=$ADMIN_USER --admin_password=$ADMIN_PASSWORD --admin_email=test@test.com --path="/var/www/"

WORKDIR /var/www/wp-content

RUN touch debug.log

RUN chmod 666 debug.log

WORKDIR /var/www

CMD ["/usr/sbin/php-fpm8", "-F"]
