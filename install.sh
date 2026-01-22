#!/usr/bin/env bash
set -e

if [ "$EUID" -ne 0 ]; then
	echo "Execute como root: sudo ./install.sh"
	exit 1
fi

if [ ! -f .env ]; then
	echo ".env não encontrado. Copie de .env.template"
	exit 1
fi

source .env

export SERVER_USER JAVA_VERSION APPS POSTGRES_LISTEN

modules=(
	base.sh
	security.sh
	java.sh
	system.sh
	apps-users.sh
	postgresql.sh
	nginx.sh
)

for module in "${modules[@]}"; do
	echo "Executando $module"
	bash "modules/$module"
done

echo "Setup concluído"
