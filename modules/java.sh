#!/usr/bin/env bash
set -e

apt install -y "openjdk-${JAVA_VERSION}-jdk-headless"

JAVA_PATH=$(readlink -f /usr/bin/java | sed "s:/bin/java::")

echo "export JAVA_HOME=${JAVA_PATH}" > /etc/profile.d/java.sh
echo "export PATH=\$PATH:\$JAVA_HOME/bin" >> /etc/profile.d/java.sh
