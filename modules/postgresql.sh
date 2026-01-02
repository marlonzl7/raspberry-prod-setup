#!/usr/bin/env bash
set -e

apt install -y postgresql postgresql-contrib

IFS=' ' read -r -a APP_LIST <<< "$APPS"

for app in "${APP_LIST[@]}"; do

	runuser -u postgres psql <<EOF
DO \$\$
BEGIN
  IF NOT EXISTS (
    SELECT FROM pg_roles WHERE rolname = '${app}_user'
  ) THEN
    CREATE USER ${app}_user PASSWORD 'change_me';
  END IF;
END
\$\$;
EOF

	runuser -u postgres psql <<EOF
SELECT 'CREATE DATABASE ${app}_db OWNER ${app}_user'
WHERE NOT EXISTS (
  SELECT FROM pg_database WHERE datname = '${app}_db'
)\gexec
EOF

done

sed -i "s/^#listen_addresses.*/listen_addresses = 'localhost'/" \
	/etc/postgresql/*/main/postgresql.conf

systemctl restart postgresql
