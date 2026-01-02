#!/bin/bash
set -e



# Cambia bind-address a 0.0.0.0 para permitir conexiones externas
sed -i 's/^bind-address\s*=\s*127.0.0.1/bind-address = 0.0.0.0/' /etc/mysql/mariadb.conf.d/50-server.cnf

# Comprobar variables de entorno obligatorias
if [ -z "$MARIADB_VOLUME_PATH" ] || [ -z "$MYSQL_DATABASE" ] || [ -z "$MYSQL_USER" ] || [ -z "$MYSQL_PASSWORD" ] || [ -z "$MYSQL_ROOT_PASSWORD" ]; then
	echo "Incorrect env variables."
	exit 1
fi



# Inicializa la base de datos si no existe

if [ ! -d "${MARIADB_VOLUME_PATH}/${MYSQL_DATABASE}" ]; then
	echo "[Entrypoint] Ejecutando mariadb-install-db..."
	mariadb-install-db --user=mysql --basedir=/usr --datadir=${MARIADB_VOLUME_PATH}
	echo "[Entrypoint] Base de datos inicializada."
fi

# Arranca el servidor MariaDB en segundo plano
mysqld_safe --datadir=${MARIADB_VOLUME_PATH} &
MYSQL_PID=$!

# Espera a que MariaDB esté listo
echo "[Entrypoint] Esperando a que MariaDB esté listo..."
for i in {1..30}; do
	mariadb-admin ping --silent && break
	sleep 1
done

# Ejecuta el script SQL para crear usuario y privilegios
echo "[Entrypoint] Ejecutando configuración SQL..."
cat <<EOSQL | mariadb -u root
CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE};
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'localhost' IDENTIFIED BY '${MYSQL_PASSWORD}';
GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%';
GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'localhost';
FLUSH PRIVILEGES;
EOSQL
echo "[Entrypoint] Configuración SQL completada."
# Espera a que el proceso de mysqld_safe termine
wait $MYSQL_PID

