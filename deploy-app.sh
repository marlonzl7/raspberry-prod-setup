#!/usr/bin/env bash
set -e

if [ "$EUID" -ne 0 ]; then
	echo "Execute como root: sudo ./deploy-app.sh <app> <jar> [frontend_dir]"
	exit 1
fi

APP_NAME="$1"
JAR_PATH="$2"
FRONTEND_PATH="$3"

if [ -z "$APP_NAME" ] || [ -z "$JAR_PATH" ]; then
	echo "Uso: sudo ./deploy-app.sh <app> <jar> [frontend_dir]"
	exit 1
fi

if [ ! -f "$JAR_PATH" ]; then
	echo "Arquivo JAR não encontrado: $JAR_PATH"
	exit 1
fi

APP_DIR="/opt/apps/$APP_NAME"
FRONTEND_DIR="/var/www/$APP_NAME"

echo "Deploy da aplicação: $APP_NAME"

if ! id "$APP_NAME" &>/dev/null; then
	echo "Usuário $APP_NAME não existe. Execute install.sh antes."
	exit 1
fi

mkdir -p "$APP_DIR"
mkdir -p "$FRONTEND_DIR"

echo "Copiando JAR"
cp "$JAR_PATH" "$APP_DIR/app.jar"

if [ ! -f "$APP_DIR/.env" ]; then
	echo "Criando .env padrão"
	cat <<EOF > "$APP_DIR/.env"
SPRING_PROFILES_ACTIVE=prod
SERVER_PORT=8080
EOF
fi

chown -R "$APP_NAME:$APP_NAME" "$APP_DIR"
chown -R www-data:www-data "$FRONTEND_DIR"

chmod 750 "$APP_DIR"
chmod 640 "$APP_DIR/.env"

if [ -n "$FRONTEND_PATH" ]; then
	if [ ! -d "$FRONTEND_PATH" ]; then
		echo "Diretório de frontend não encontrado"
		exit 1
	fi

	echo "Atualizando frontend"
	rm -rf "$FRONTEND_DIR"/*
	cp -r "$FRONTEND_PATH"/* "$FRONTEND_DIR/"
fi

echo "Reiniciando serviço"
systemctl daemon-reload

if systemctl is-enabled --quiet "java-api@$APP_NAME"; then
	systemctl restart "java-api@$APP_NAME"
else
	systemctl enable "java-api@$APP_NAME"
	systemctl start "java-api@$APP_NAME"
fi

echo "Deploy concluído para $APP_NAME"
