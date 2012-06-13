#!/bin/bash

#
# Usage:
# ./alternative_prepare_chroot.sh /new_chroot_dir repository_URL repository_alias
#

# Configuration
CHROOT=$1
URL=$2
ALIAS=$3

BASIC_RPMS="util-linux coreutils zypper suse-build-key"
FINAL_RPMS="suseRegister suse-build-key util-linux yast2-trans-en_US"
OPTIONAL_RPMS="openssl-certs"
RPM_DB_DIR="/var/lib/rpm/"
PACKAGES_LIST="/zypper-packages-to-install"
COPY_FILES="/etc/resolv.conf /etc/hosts /etc/localtime"

# Configure the repository
echo "Creating chroot directory in ${CHROOT}"
mkdir -pv ${CHROOT}
zypper --root=${CHROOT} --gpg-auto-import-keys ar --refresh ${URL} ${ALIAS}
zypper --root=${CHROOT} --non-interactive --gpg-auto-import-keys ref

echo "Linking special directories"
# Link important special dirs
for DIR in proc sys; do
  mkdir -pv ${CHROOT}/${DIR}
  mount --bind /${DIR} ${CHROOT}/${DIR}
done

# Creating special devices
mkdir -pv ${CHROOT}/dev
mknod ${CHROOT}/dev/mem  c 1 1
mknod ${CHROOT}/dev/kmem c 1 2
mknod ${CHROOT}/dev/null c 1 3
mknod ${CHROOT}/dev/port c 1 4
mknod ${CHROOT}/dev/zero c 1 5
mknod ${CHROOT}/dev/full c 1 7
mknod ${CHROOT}/dev/random c 1 8
mknod ${CHROOT}/dev/urandom c 1 9
mknod ${CHROOT}/dev/tty  c 5 0

# Prepare the chroot with basic setup
zypper --non-interactive --root=${CHROOT} install --auto-agree-with-licenses --no-recommends ${BASIC_RPMS}

# Adjust network config
for FILE in ${COPY_FILES}; do
  echo ${FILE}
  rm -rf ${CHROOT}${FILE}
  ln ${FILE} ${CHROOT}${FILE}
done

# Destroy the current RPM database (probably different RPM version than on the target system)
echo "Rebuilding RPM database on the target system"
rm -rf ${CHROOT}/${RPM_DB_DIR}/*
chroot ${CHROOT} rpm --rebuilddb

# Remove and add the install repository again (locally, by older zypper)
zypper --root=${CHROOT} rr ${ALIAS}
chroot ${CHROOT} zypper --gpg-auto-import-keys ar --refresh ${URL} ${ALIAS}
chroot ${CHROOT} zypper --non-interactive --gpg-auto-import-keys refresh --force --services

# Install the rest of packages
chroot ${CHROOT} zypper --non-interactive install --auto-agree-with-licenses --force ${FINAL_RPMS}
chroot ${CHROOT} zypper --non-interactive install --auto-agree-with-licenses --force ${OPTIONAL_RPMS}

chroot ${CHROOT} c_rehash > /dev/null

echo "Done"
