#!/bin/bash

# This script builds and installs the Findutils package as part of the Linux From Scratch (LFS) process.
# It follows the instructions from https://www.linuxfromscratch.org/lfs/view/stable/chapter06/findutils.html
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

FINDUTILS_VERSION=4.10.0
FINDUTILS_TAR=$LFS/sources/findutils-$FINDUTILS_VERSION.tar.xz
FINDUTILS_DIR=$LFS/sources/findutils-$FINDUTILS_VERSION

echo "Verifying presence of findutils-$FINDUTILS_VERSION tarball..."
if [ -f "$FINDUTILS_TAR" ]; then
    echo "Found $FINDUTILS_TAR"
else
    echo "Error: Tarball $FINDUTILS_TAR does not exist."
    exit 1
fi

if [ ! -d "$FINDUTILS_DIR" ]; then
    echo "Extracting findutils-$FINDUTILS_VERSION tarball..."
    tar -xf "$FINDUTILS_TAR" -C "$LFS/sources"
else
    echo "findutils-$FINDUTILS_VERSION directory already exists. Skipping extraction."
fi

echo "Changing to source directory: $FINDUTILS_DIR"
cd "$FINDUTILS_DIR"

echo "Creating build directory..."
mkdir -p build

echo "Changing to build directory..."
cd build

echo "Running configure for findutils..."
../configure \
    --prefix=/usr \
    --localstatedir=/var/lib/locate \
    --host=$LFS_TGT \
    --build=$(../build-aux/config.guess)

echo "Compiling the package..."
make

echo "Installing the package..."
make DESTDIR=$LFS install

echo "Findutils installation complete."
