#!/bin/bash

# Script to create the LFS directory structure inside chroot as per LFS 12.3 Chapter 7.5
# Purpose: This script creates the full directory structure in the LFS file system, sets specific
# permissions for /root, /tmp, and /var/tmp, creates symbolic links for /var/run and /var/lock, and
# ensures /usr/lib64 does not exist, as per the LFS guide. Adapted for execution inside the chroot
# environment (run as root).

# Ensure the script is run as root
# Explanation: All directory creation, permission changes, and symbolic link operations require root
# privileges. In the chroot environment, commands are run as root (UID 0).
if [ "$(id -u)" != "0" ]; then
    echo "This script must be run as root in the chroot environment."
    exit 1
fi

# Remove /usr/lib64 if it exists
# Explanation: The LFS guide warns that /usr/lib64 must not exist, as it can break the LFS or BLFS
# build process. We remove it to ensure compliance.
if [ -d /usr/lib64 ]; then
    rm -rfv /usr/lib64
    echo '/usr/lib64 has been removed.'
else
    echo '/usr/lib64 does not exist, no removal needed.'
fi

# Create root-level directories
# Explanation: These directories (/boot, /home, /mnt, /opt, /srv) are part of the FHS and support
# various system functions (e.g., bootloader files, user data, optional software).
mkdir -pv /{boot,home,mnt,opt,srv}

# Create subdirectories
# Explanation: These subdirectories under /etc, /lib, /media, /usr, /usr/local, and /var are
# required by the FHS to support configuration, firmware, media, binaries, documentation, and system
# data in the LFS system.
mkdir -pv /etc/{opt,sysconfig}
mkdir -pv /lib/firmware
mkdir -pv /media/{floppy,cdrom}
mkdir -pv /usr/{,local/}{include,src}
mkdir -pv /usr/lib/locale
mkdir -pv /usr/local/{bin,lib,sbin}
mkdir -pv /usr/{,local/}share/{color,dict,doc,info,locale,man}
mkdir -pv /usr/{,local/}share/{misc,terminfo,zoneinfo}
mkdir -pv /usr/{,local/}share/man/man{1..8}
mkdir -pv /var/{cache,local,log,mail,opt,spool}
mkdir -pv /var/lib/{color,misc,locate}

# Create symbolic links for /var/run and /var/lock
# Explanation: These links point to /run and /run/lock, ensuring compatibility with software
# expecting traditional /var/run and /var/lock locations while using the modern /run tmpfs.
ln -sfv /run /var/run
ln -sfv /run/lock /var/lock

# Create and set permissions for /root, /tmp, and /var/tmp
# Explanation: /root is set to 0750 to restrict access to the root user. /tmp and /var/tmp are set
# to 1777 (sticky bit) to allow all users to write but only owners to delete files, per FHS.
install -dv -m 0750 /root
install -dv -m 1777 /tmp /var/tmp

echo "LFS directory structure has been created successfully in the chroot environment."
echo "The /usr/lib64 directory has been checked and removed if it existed."
