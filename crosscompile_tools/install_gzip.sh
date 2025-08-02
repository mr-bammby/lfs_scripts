#!/bin/bash

# This script builds and installs the Gzip package as part of the Linux From Scratch (LFS) process.
# It follows the instructions from https://www.linuxfromscratch.org/lfs/view/12.3/chapter06/gzip.html
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

GZIP_VERSION=1.13
GZIP_TAR=$LFS/sources/gzip-$GZIP_VERSION.tar.xz
GZIP_DIR=$LFS/sources/gzip-$GZIP_VERSION

echo "Verifying presence of gzip-$GZIP_VERSION tarball..."
if [ -f "$GZIP_TAR" ]; then
    echo "Found $GZIP_TAR"
else
    echo "Error: Tarball $GZIP_TAR does not exist."
    exit 1
fi

if [ ! -d "$GZIP_DIR" ]; then
    echo "Extracting gzip-$GZIP_VERSION tarball..."
    tar -xf "$GZIP_TAR" -C "$LFS/sources"
else
    echo "gzip-$GZIP_VERSION directory already exists. Skipping extraction."
fi

echo "Changing to source directory: $GZIP_DIR"
cd "$GZIP_DIR"

echo "Creating build directory..."
mkdir -p build

echo "Changing to build directory..."
cd build

echo "Running configure for gzip..."
../configure \
    --prefix=/usr \
    --host=$LFS_TGT

echo "Compiling the package..."
make

echo "Installing the package..."
make DESTDIR=$LFS install

echo "Gzip installation complete."
