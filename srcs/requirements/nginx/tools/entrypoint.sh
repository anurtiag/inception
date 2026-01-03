#!/bin/bash
set -e


if [ ! -f /etc/nginx/ssl/nginx.crt ] || [ ! -f /etc/nginx/ssl/nginx.key ]; then
	echo "[NGINX] Generando certificados SSL autofirmados..."
	mkdir -p /etc/nginx/ssl
	openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
		-keyout /etc/nginx/ssl/nginx.key \
		-out /etc/nginx/ssl/nginx.crt \
		-subj "/C=ES/ST=Madrid/L=Madrid/O=42/OU=Student/CN=${DOMAIN}"
	chmod 600 /etc/nginx/ssl/nginx.key
	chmod 644 /etc/nginx/ssl/nginx.crt
	echo "[NGINX] Certificados SSL generados."
else
	echo "[NGINX] Certificados SSL ya existen."
fi

exec nginx -g 'daemon off;'
