#!/bin/bash

# This script builds and installs the Gawk package as part of the Linux From Scratch (LFS) process.
# It follows the instructions from https://www.linuxfromscratch.org/lfs/view/stable/chapter06/gawk.html
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

GAWK_VERSION=5.3.1
GAWK_TAR=$LFS/sources/gawk-$GAWK_VERSION.tar.xz
GAWK_DIR=$LFS/sources/gawk-$GAWK_VERSION

echo "Verifying presence of gawk-$GAWK_VERSION tarball..."
if [ -f "$GAWK_TAR" ]; then
    echo "Found $GAWK_TAR"
else
    echo "Error: Tarball $GAWK_TAR does not exist."
    exit 1
fi

if [ ! -d "$GAWK_DIR" ]; then
    echo "Extracting gawk-$GAWK_VERSION tarball..."
    tar -xf "$GAWK_TAR" -C "$LFS/sources"
else
    echo "gawk-$GAWK_VERSION directory already exists. Skipping extraction."
fi

echo "Changing to source directory: $GAWK_DIR"
cd "$GAWK_DIR"

echo "Applying sed to Makefile.in..."
sed -i 's/extras//' Makefile.in

echo "Creating build directory..."
mkdir -p build

echo "Changing to build directory..."
cd build

echo "Running configure for gawk..."
../configure \
    --prefix=/usr \
    --host=$LFS_TGT \
    --build=$(../build-aux/config.guess)

echo "Compiling the package..."
make

echo "Installing the package..."
make DESTDIR=$LFS install

echo "Gawk installation complete."

