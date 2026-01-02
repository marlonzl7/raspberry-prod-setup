#!/usr/bin/env bash
set -e

apt install -y \
	ufw \
	fail2ban \
	openssh-server

ufw default deny incoming
ufw default allow outgoing

ufw allow ssh
ufw allow 80
ufw allow 443

ufw --force enable

sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config
systemctl reload ssh
