#!/bin/bash

# This script builds and installs the Diffutils package as part of the Linux From Scratch (LFS) process.
# It follows the instructions from https://www.linuxfromscratch.org/lfs/view/stable/chapter06/diffutils.html
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

DIFFUTILS_VERSION=3.11
DIFFUTILS_TAR=$LFS/sources/diffutils-$DIFFUTILS_VERSION.tar.xz
DIFFUTILS_DIR=$LFS/sources/diffutils-$DIFFUTILS_VERSION

echo "Verifying presence of diffutils-$DIFFUTILS_VERSION tarball..."
if [ -f "$DIFFUTILS_TAR" ]; then
    echo "Found $DIFFUTILS_TAR"
else
    echo "Error: Tarball $DIFFUTILS_TAR does not exist."
    exit 1
fi

if [ ! -d "$DIFFUTILS_DIR" ]; then
    echo "Extracting diffutils-$DIFFUTILS_VERSION tarball..."
    tar -xf "$DIFFUTILS_TAR" -C "$LFS/sources"
else
    echo "diffutils-$DIFFUTILS_VERSION directory already exists. Skipping extraction."
fi

echo "Changing to source directory: $DIFFUTILS_DIR"
cd "$DIFFUTILS_DIR"

echo "Creating build directory..."
mkdir -p build

echo "Changing to build directory..."
cd build

echo "Running configure for diffutils..."
../configure \
    --prefix=/usr \
    --host=$LFS_TGT \
    --build=$(../build-aux/config.guess)

echo "Compiling the package..."
make

echo "Installing the package..."
make DESTDIR=$LFS install

echo "Diffutils installation complete."
