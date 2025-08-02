#!/bin/bash

# This script builds and installs the Coreutils package as part of the Linux From Scratch (LFS) process.
# It follows the instructions from https://www.linuxfromscratch.org/lfs/view/stable/chapter06/coreutils.html
# Before running this script, ensure that the LFS and LFS_TGT environment variables are set.
# For example:
export LFS=/mnt/lfs
export LFS_TGT=x86_64-lfs-linux-gnu

set -e

echo "Checking environment variables..."
if [ -z "$LFS" ]; then
    echo "Error: \$LFS is not set."
    exit 1
fi

if [ -z "$LFS_TGT" ]; then
    echo "Error: \$LFS_TGT is not set."
    exit 1
fi

echo "Checking if $LFS/sources exists..."
if [ ! -d "$LFS/sources" ]; then
    echo "Error: $LFS/sources does not exist."
    exit 1
fi

COREUTILS_VERSION=9.6
COREUTILS_TAR=$LFS/sources/coreutils-$COREUTILS_VERSION.tar.xz
COREUTILS_DIR=$LFS/sources/coreutils-$COREUTILS_VERSION

echo "Verifying presence of coreutils-$COREUTILS_VERSION tarball..."
if [ -f "$COREUTILS_TAR" ]; then
    echo "Found $COREUTILS_TAR"
else
    echo "Error: Tarball $COREUTILS_TAR does not exist."
    exit 1
fi

if [ ! -d "$COREUTILS_DIR" ]; then
    echo "Extracting coreutils-$COREUTILS_VERSION tarball..."
    tar -xf "$COREUTILS_TAR" -C "$LFS/sources"
else
    echo "coreutils-$COREUTILS_VERSION directory already exists. Skipping extraction."
fi

echo "Changing to source directory: $COREUTILS_DIR"
cd "$COREUTILS_DIR"

echo "Creating build directory..."
mkdir -p build

echo "Changing to build directory..."
cd build

echo "Running configure for coreutils..."
../configure \
    --prefix=/usr \
    --host=$LFS_TGT \
    --build=$(../build-aux/config.guess) \
    --enable-install-program=hostname \
    --enable-no-install-program=kill,uptime

echo "Compiling the package..."
make

echo "Installing the package..."
make DESTDIR=$LFS install

echo "Moving binaries to their final locations..."
mv -v $LFS/usr/bin/chroot              $LFS/usr/sbin
mkdir -pv $LFS/usr/share/man/man8
mv -v $LFS/usr/share/man/man1/chroot.1 $LFS/usr/share/man/man8/chroot.8
sed -i 's/"1"/"8"/' $LFS/usr/share/man/man8/chroot.8

echo "Coreutils installation complete."
