#!/bin/bash
set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
NC='\033[0m'

echo -e "${BLUE}[WordPress] Iniciando configuración...${NC}"

# Comprobar variables de entorno necesarias
if [ -z "$MYSQL_DATABASE" ] || [ -z "$MYSQL_USER" ] || [ -z "$MYSQL_PASSWORD" ] || [ -z "$WP_ADMIN_USER" ] || [ -z "$WP_ADMIN_PASSWORD" ] || [ -z "$WP_ADMIN_EMAIL" ] || [ -z "$WP_URL" ] || [ -z "$WP_TITLE" ] || [ -z "$WP_USER" ] || [ -z "$WP_USER_EMAIL" ] || [ -z "$WP_USER_PASSWORD" ]; then
    echo "Error: Faltan variables de entorno necesarias."
    exit 1
fi

# Esperar a que MariaDB esté listo
echo -e "${BLUE}[WordPress] Esperando a que MariaDB esté disponible...${NC}"
until mysql -h mariadb -u"${MYSQL_USER}" -p"${MYSQL_PASSWORD}" -e "SELECT 1" &>/dev/null; do
    echo -e "${YELLOW}[WordPress] MariaDB no está listo aún... esperando${NC}"
    sleep 3
done
echo -e "${GREEN}[WordPress] MariaDB está listo${NC}"

cd /var/www/html

# Instalar WordPress si no está instalado
if [ ! -f wp-config.php ]; then
    echo -e "${BLUE}[WordPress] Descargando WordPress...${NC}"
    wp core download --allow-root
    echo -e "${BLUE}[WordPress] Creando wp-config.php...${NC}"
    wp config create \
        --dbname="${MYSQL_DATABASE}" \
        --dbuser="${MYSQL_USER}" \
        --dbpass="${MYSQL_PASSWORD}" \
        --dbhost=mariadb \
        --allow-root
    echo -e "${BLUE}[WordPress] Instalando WordPress...${NC}"
    wp core install \
        --url="${WP_URL}" \
        --title="${WP_TITLE}" \
        --admin_user="${WP_ADMIN_USER}" \
        --admin_password="${WP_ADMIN_PASSWORD}" \
        --admin_email="${WP_ADMIN_EMAIL}" \
        --allow-root
    echo -e "${BLUE}[WordPress] Creando segundo usuario...${NC}"
    wp user create \
        "${WP_USER}" \
        "${WP_USER_EMAIL}" \
        --role=editor \
        --user_pass="${WP_USER_PASSWORD}" \
        --allow-root
    echo -e "${GREEN}[WordPress] WordPress instalado correctamente${NC}"
else
    echo -e "${GREEN}[WordPress] WordPress ya está instalado${NC}"
fi

chown -R www-data:www-data /var/www/html

echo -e "${GREEN}[WordPress] Iniciando PHP-FPM...${NC}"

exec /usr/sbin/php-fpm8.2 -F
