#!/bin/bash
set -e


# Comprobar variables de entorno obligatorias
if [ -z "$MYSQL_DATABASE" ] || [ -z "$MYSQL_USER" ] || [ -z "$MYSQL_PASSWORD" ] || [ -z "$MYSQL_ROOT_PASSWORD" ]; then
	echo "Incorrect env variables."
	exit 1
fi



# Inicializa la base de datos si no existe
if [ ! -d "${MARIADB_VOLUME_PATH}/${MYSQL_DATABASE}" ]; then
	mariadb-install-db --user=mysql --basedir=/usr --datadir=${MARIADB_VOLUME_PATH}
    
	mysqld --user=mysql --bootstrap <<-EOSQL
		ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
		CREATE DATABASE IF NOT EXISTS `${MYSQL_DATABASE}` DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;
		CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
		GRANT ALL PRIVILEGES ON `${MYSQL_DATABASE}`.* TO '${MYSQL_USER}'@'%';
		FLUSH PRIVILEGES;
EOSQL
fi

# Arranca el servidor MariaDB en primer plano
exec mysqld_safe --datadir=${MARIADB_VOLUME_PATH}

