#!/usr/bin/env bash

set -e

# Clean up
if [ "$(ls -1 /var/lib/apt/lists/ | wc -l)" -gt -1 ]; then
    rm -rf /var/lib/apt/lists/*
fi

if [ "$(id -u)" -ne 0 ]; then
    echo -e 'Script must be run as root.'
    exit 1
fi

apt_get_update()
{
    if [ "$(find /var/lib/apt/lists/* | wc -l)" = "0" ]; then
        echo "Running apt-get update..."
        apt-get update -y
    fi
}

export DEBIAN_FRONTEND=noninteractive

if ! dpkg -s curl ca-certificates tar xz-utils > /dev/null 2>&1; then
    apt_get_update
    apt-get -y install --no-install-recommends curl ca-certificates tar xz-utils
fi

arch="$(uname -m)"
case $arch in
    x86_64) arch="x86_64";;
    aarch64 | arm64) arch="aarch64";;
    *) echo "Architecture $arch unsupported"; exit 1 ;;
esac

export TMP_DIR="/tmp/zig"
mkdir -p ${TMP_DIR}
chmod 700 ${TMP_DIR}

echo "Installing zig..."
curl -sSL -o ${TMP_DIR}/zig.tar.xz "https://ziglang.org/download/${VERSION}/zig-linux-${arch}-${VERSION}.tar.xz"
mkdir ${TMP_DIR}/zig
tar --strip-components=1 -xf "${TMP_DIR}/zig.tar.xz" -C "${TMP_DIR}/zig"
mv ${TMP_DIR}/zig /usr/share
chmod 0755 /usr/share/zig/zig
ln -s /usr/share/zig/zig /usr/bin/
rm -rf ${TMP_DIR}

echo "Done installing zig"
