#!/usr/bin/env bash
set -e

apt install -y nginx

rm -f /etc/nginx/sites-enabled/default

mkdir -p /var/www

IFS=' ' read -r -a APP_LIST <<< "$APPS"

NGINX_CONF="/etc/nginx/sites-available/apps.conf"

echo "Gerando configuração no Nginx"

cat <<EOF > "$NGINX_CONF"
server {
	listen 80;
	server_name _;
}

EOF

PORT=8081

for app in "${APP_LIST[@]}"; do
	mkdir -p /var/www/$app
	chown -R www-data:www-data /var/www/$app

	cat <<EOF >> "$NGINX_CONF"
		location /$app/ {
			alias /var/www/$app/;
			index index.html
			try_files \$uri \$uri =404;
		}

		location /api/$app/ {
			proxy_pass http://127.0.0.1:${PORT}/;
			proxy_set_header Host \$host;
			proxy_set_header X-Real_IP \$remote_addr;
			proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
		}

EOF

PORT=$((PORT + 1))

done

echo "}" >> "$NGINX_CONF"

ln -sf "$NGINX_CONF" /etc/nginx/sites-enabled/apps.conf

nginx -t
systemctl reload nginx
