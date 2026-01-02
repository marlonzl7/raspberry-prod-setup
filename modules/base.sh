#!/usr/bin/env bash
set -e

apt update
apt upgrade -y

apt install -y \
	curl \
	wget \
	git \
	unzip \
	ca-certificates \
	gnupg \
	lsb-release \
	software-properties-common \
	build-essential
