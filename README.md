# Inception

Salut,

Comme beaucoup j'ai suivi le tuto russe sur inception. Mais je me suis retrouvé devant un problème :
- A chaque fois que je relancais mon docker je devais refaire la configuration de wordpress.
- Ce problème engendre lui meme le fait que rien ne se sauvegardais.

Je vais vous montrer en quelques étapes comment j'ai réussi à fix le problème.

(Le tuto russe en question : https://github-com.translate.goog/codesshaman/inception?_x_tr_sl=auto&_x_tr_tl=fr&_x_tr_hl=fr&_x_tr_pto=wapp)

# 1er étape

Qui dit aucune persistence des configurations dit problème de volume !

Dans le tuto, le docker-compose manque 2 lignes qui semble pourtant assez évidente : 

```version: '3'

services:
  nginx:
    build:
      context: .
      dockerfile: requirements/nginx/Dockerfile
    container_name: nginx
    depends_on:
      - wordpress
    ports:
      - "443:443"
    networks:
      - inception
    volumes:
      - ./requirements/nginx/conf/:/etc/nginx/http.d/
      - ./requirements/nginx/tools:/etc/nginx/ssl/
      - wp-volume:/var/www/
    restart: always

  mariadb:
    build:
      context: .
      dockerfile: requirements/mariadb/Dockerfile
      args:
        DB_NAME: ${DB_NAME}
        DB_USER: ${DB_USER}
        DB_PASS: ${DB_PASS}
        DB_ROOT: ${DB_ROOT}
    container_name: mariadb
    ports:
      - "3306:3306"
    networks:
      - inception
    restart: always
    volumes: # <--- 1er oublie de la ligne volume.
      - db-volume:/var/lib/mysql 

  wordpress:
    build:
      context: .
      dockerfile: requirements/wordpress/Dockerfile
      args:
        DB_NAME: ${DB_NAME}
        DB_USER: ${DB_USER}
        DB_PASS: ${DB_PASS}
    container_name: wordpress
    depends_on:
      - mariadb
    restart: always
    networks:
      - inception
    volumes: # <--- 2eme oublie de la ligne volume.
      - wp-volume:/var/www

volumes:
  wp-volume:
    driver_opts:
      o: bind
      type: none
      device: /home/${USER}/data/wordpress

  db-volume:
    driver_opts:
      o: bind
      type: none
      device: /home/${USER}/data/mariadb

networks:
    inception:
        driver: bridge
```

# 2eme étape

J'ai un peu trifouille pour trouver l'erreur sur wordpress et en voici mon Dockerfile ainsi modifié et commenté : 

```FROM alpine:3.16
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
    php-phar \ # <---- Cette ligne sert pour la suite, elle installe une dépendance de wp-cli.
    wget \
    unzip && \
    sed -i "s|listen = 127.0.0.1:9000|listen = 9000|g" \
      /etc/php8/php-fpm.d/www.conf && \
    sed -i "s|;listen.owner = nobody|listen.owner = nobody|g" \
      /etc/php8/php-fpm.d/www.conf && \
    sed -i "s|;listen.group = nobody|listen.group = nobody|g" \
      /etc/php8/php-fpm.d/www.conf && \
    rm -f /var/cache/apk/*

WORKDIR /var/www/

# Dans le tuto, il prend un zip avec la configuration de wordpress qu'il décompresse ensuite.
# En galerant comme un rat mort, j'en suis venu à faire d'une façon différente : 
# - Installe wp-cli, celle-ci nous donnes accès à la commande wp.
# - On lui donne les droits d'executable.
# - On la move dans un emplacement où donnés dans la variable d'environnement PATH 
# (petit reminder de minishell).
# - Et pour finir, grâce à la commande wp, 
# on peut installer tout les fichiers de config wordpress nécessaire.
# Pour les curieux : https://developer.wordpress.org/cli/commands/core/download/ 
# (doc wp core download).
 
RUN wget https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar

RUN chmod +x wp-cli.phar

RUN mv -f wp-cli.phar /usr/local/bin/wp

RUN wp core download --allow-root --path="/var/www"

COPY ./requirements/wordpress/conf/wp-config-create.sh .
RUN sh wp-config-create.sh && rm wp-config-create.sh

CMD ["/usr/sbin/php-fpm8", "-F"]
```

Il y a une autre différence, dans le wp-config-create.sh j'ai rajouté quelques champs a vous de voir s'ils sont 
nécessaire.

Enjoy.
