#!/bin/bash

# This script builds and installs the Binutils package (Pass 2) as part of the Linux From Scratch (LFS) process.
# It follows the instructions from https://www.linuxfromscratch.org/lfs/view/12.3/chapter06/binutils-pass2.html
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

BINUTILS_VERSION=2.44
BINUTILS_TAR=$LFS/sources/binutils-$BINUTILS_VERSION.tar.xz
BINUTILS_DIR=$LFS/sources/binutils-$BINUTILS_VERSION

echo "Verifying presence of binutils-$BINUTILS_VERSION tarball..."
if [ -f "$BINUTILS_TAR" ]; then
    echo "Found $BINUTILS_TAR"
else
    echo "Error: Tarball $BINUTILS_TAR does not exist."
    exit 1
fi

if [ ! -d "$BINUTILS_DIR" ]; then
    echo "Extracting binutils-$BINUTILS_VERSION tarball..."
    tar -xf "$BINUTILS_TAR" -C "$LFS/sources"
else
    echo "binutils-$BINUTILS_VERSION directory already exists. Skipping extraction."
fi

echo "Changing to source directory: $BINUTILS_DIR"
cd "$BINUTILS_DIR"

echo "Applying sed to ltmain.sh..."
sed '6031s/$add_dir//' -i ltmain.sh

echo "Removing existing build directory if it exists..."
rm -rf build

echo "Creating build directory..."
mkdir -p build

echo "Changing to build directory..."
cd build

echo "Removing old configuration files..."
rm -f config.cache config.status

echo "Running configure for binutils..."
../configure \
    --prefix=/usr \
    --build=$(../config.guess) \
    --host=$LFS_TGT \
    --disable-nls \
    --enable-shared \
    --enable-gprofng=no \
    --disable-werror \
    --enable-64-bit-bfd \
    --enable-new-dtags \
    --enable-default-hash-style=gnu

echo "Compiling the package..."
make

echo "Installing the package..."
make DESTDIR=$LFS install

echo "Removing unnecessary static libraries and libtool archives..."
rm -v $LFS/usr/lib/lib{bfd,ctf,ctf-nobfd,opcodes,sframe}.{a,la}

echo "Binutils Pass 2 installation complete."
