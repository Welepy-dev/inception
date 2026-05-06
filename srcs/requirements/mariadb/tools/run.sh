#!/bin/bash

set -e

export DB_PASSWORD="$(<"/run/secrets/db_password")"
export DB_ROOT_PASSWORD="$(<"/run/secrets/db_root_password")"

chown -R mysql:mysql /var/lib/mysql
mkdir -p /run/mysqld
chown -R mysql:mysql /run/mysqld

envsubst < /init.sql > /tmp/expanded.sql && mv /tmp/expanded.sql /init.sql

exec mariadbd --init_file=/init.sql --user=mysql --bind-address=0.0.0.0


