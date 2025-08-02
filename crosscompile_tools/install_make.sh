#!/bin/bash

# This script builds and installs the Make package as part of the Linux From Scratch (LFS) process.
# It follows the instructions from https://www.linuxfromscratch.org/lfs/view/12.3/chapter06/make.html
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

MAKE_VERSION=4.4.1
MAKE_TAR=$LFS/sources/make-$MAKE_VERSION.tar.gz
MAKE_DIR=$LFS/sources/make-$MAKE_VERSION

echo "Verifying presence of make-$MAKE_VERSION tarball..."
if [ -f "$MAKE_TAR" ]; then
    echo "Found $MAKE_TAR"
else
    echo "Error: Tarball $MAKE_TAR does not exist."
    exit 1
fi

if [ ! -d "$MAKE_DIR" ]; then
    echo "Extracting make-$MAKE_VERSION tarball..."
    tar -xf "$MAKE_TAR" -C "$LFS/sources"
else
    echo "make-$MAKE_VERSION directory already exists. Skipping extraction."
fi

echo "Changing to source directory: $MAKE_DIR"
cd "$MAKE_DIR"

echo "Creating build directory..."
mkdir -p build

echo "Changing to build directory..."
cd build

echo "Running configure for make..."
../configure \
    --prefix=/usr \
    --without-guile \
    --host=$LFS_TGT \
    --build=$(../build-aux/config.guess)

echo "Compiling the package..."
make

echo "Installing the package..."
make DESTDIR=$LFS install

echo "Make installation complete."
