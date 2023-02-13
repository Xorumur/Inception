FROM alpine:3.16

# Environement variable
ARG DB_NAME \
    DB_USER \
    DB_PASS

# Install package for mariadb
RUN apk update && apk add --no-cache mariadb mariadb-client

# Create the data directory + config mysql in the file conf
RUN mkdir /var/run/mysqld; \
    chmod 777 /var/run/mysqld; \
    { echo '[mysqld]'; \
      echo 'skip-host-cache'; \
      echo 'skip-name-resolve'; \
      echo 'bind-address=0.0.0.0'; \
    } | tee  /etc/my.cnf.d/docker.cnf; \
    sed -i "s|skip-networking|skip-networking=0|g" \
      /etc/my.cnf.d/mariadb-server.cnf

# Create the database
RUN mysql_install_db --user=mysql --datadir=/var/lib/mysql

# Port
EXPOSE 3306

# Execute the script that create the database and the user
COPY requirements/mariadb/conf/create_db.sh .
RUN sh create_db.sh && rm create_db.sh


USER mysql

#COPY tools/db.sh

# Will execute this script 
#ENTRYPOINT  ["sh", "create_db.sh"]

CMD ["/usr/bin/mysqld", "--skip-log-error"]
