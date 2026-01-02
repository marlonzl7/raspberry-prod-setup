#!/usr/bin/env bash
set -e

IFS=' ' read -r -a APP_LIST <<< "$APPS"

for app in "${APP_LIST[@]}"; do
	if ! id "$app" &>/dev/null; then
		useradd \
			--system \
			--home /opt/apps/$app \
			--shell /usr/sbin/nologin \
			"$app"
	fi

	mkdir -p /opt/apps/$app
	chown -R $app:$app /opt/apps/$app
done
