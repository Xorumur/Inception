#!bin/sh

# Check if there is already a database
if [ ! -d "/var/lib/mysql/mysql" ]; then
	# If it doesn't, it sets the ownership of "/var/lib/mysql" to the "mysql" user and group, 
	# initializes the database using the "mysql_install_db" command chown -R mysql:mysql /var/lib/mysql

        # init database
        mysql_install_db --basedir=/usr --datadir=/var/lib/mysql --user=mysql --rpm

        tfile=`mktemp`
        if [ ! -f "$tfile" ]; then
                return 1
        fi
fi

if [ ! -d "/var/lib/mysql/wordpress" ]; then
# The sql does this.

# - Connects to the MySQL database.

# - Flushes the privileges.

# - Deletes any anonymous user accounts.

# - Drops the "test" database if it exists.

# - Deletes any remote root user accounts.

# - Alters the password for the root user on localhost.

# - Creates a new database named "wordpress" with UTF8 encoding and the "utf8_General_ci" collation.

# - Creates a new user with the specified username and password 
#	and grants them all privileges on the "wordpress" database.

# - Flushes the privileges again.

        cat << EOF > /tmp/create_db.sql
USE mysql;
FLUSH PRIVILEGES;
DELETE FROM     mysql.user WHERE User=''; 
DROP DATABASE test;
DELETE FROM mysql.db WHERE Db='test';
DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT}';
CREATE DATABASE ${DB_NAME} CHARACTER SET utf8 COLLATE utf8_general_ci;
CREATE USER '${DB_USER}'@'%' IDENTIFIED by '${DB_PASS}';
GRANT ALL PRIVILEGES ON wordpress.* TO '${DB_USER}'@'%';
FLUSH PRIVILEGES;
EOF
        # run init.sql
        /usr/bin/mysqld --user=mysql --bootstrap < /tmp/create_db.sql
        rm -f /tmp/create_db.sql
fi
