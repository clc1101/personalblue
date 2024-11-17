#!/bin/bash

set -ouex pipefail

RELEASE="$(rpm -E %fedora)"

systemctl enable podman.socket

KERNEL_SUFFIX=""
QUALIFIED_KERNEL="$(rpm -qa | grep -P 'kernel-(|'"$KERNEL_SUFFIX"'-)(\d+\.\d+\.\d+)' | sed -E 's/kernel-(|'"$KERNEL_SUFFIX"'-)//')"
/usr/libexec/rpm-ostree/wrapped/dracut --no-hostonly --kver "$QUALIFIED_KERNEL" --reproducible -v --add ostree -f "/lib/modules/$QUALIFIED_KERNEL/initramfs.img"
chmod 0600 /lib/modules/$QUALIFIED_KERNEL/initramfs.img

ARCH="$(rpm -E '%_arch')"
KERNEL="$(rpm -q "${KERNEL_NAME}" --queryformat '%{VERSION}-%{RELEASE}.%{ARCH}')"
RELEASE="$(rpm -E '%fedora')"

cp /tmp/ublue-os-akmods-addons/rpmbuild/SOURCES/negativo17-fedora-multimedia.repo /etc/yum.repos.d/

### BUILD xpadneo (succeed or fail-fast with debug output)
dnf install -y \
    akmod-xpadneo-*.fc${RELEASE}.${ARCH}
akmods --force --kernels "${KERNEL}" --kmod xpadneo
modinfo /usr/lib/modules/${KERNEL}/extra/xpadneo/hid-xpadneo.ko.xz > /dev/null \
|| (find /var/cache/akmods/xpadneo/ -name \*.log -print -exec cat {} \; && exit 1)
