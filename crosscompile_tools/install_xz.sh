#!/bin/bash

# This script builds and installs the Xz package as part of the Linux From Scratch (LFS) process.
# It follows the instructions from https://www.linuxfromscratch.org/lfs/view/12.3/chapter06/xz.html
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

XZ_VERSION=5.6.4
XZ_TAR=$LFS/sources/xz-$XZ_VERSION.tar.xz
XZ_DIR=$LFS/sources/xz-$XZ_VERSION

echo "Verifying presence of xz-$XZ_VERSION tarball..."
if [ -f "$XZ_TAR" ]; then
    echo "Found $XZ_TAR"
else
    echo "Error: Tarball $XZ_TAR does not exist."
    exit 1
fi

if [ ! -d "$XZ_DIR" ]; then
    echo "Extracting xz-$XZ_VERSION tarball..."
    tar -xf "$XZ_TAR" -C "$LFS/sources"
else
    echo "xz-$XZ_VERSION directory already exists. Skipping extraction."
fi

echo "Changing to source directory: $XZ_DIR"
cd "$XZ_DIR"

echo "Creating build directory..."
mkdir -p build

echo "Changing to build directory..."
cd build

echo "Running configure for xz..."
../configure \
    --prefix=/usr \
    --host=$LFS_TGT \
    --build=$(../build-aux/config.guess) \
    --disable-static \
    --docdir=/usr/share/doc/xz-$XZ_VERSION

echo "Compiling the package..."
make

echo "Installing the package..."
make DESTDIR=$LFS install

echo "Removing liblzma.la..."
rm -v $LFS/usr/lib/liblzma.la

echo "Xz installation complete."
