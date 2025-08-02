#!/bin/bash

# This script builds and installs the M4 package as part of the Linux From Scratch (LFS) process.
# It follows the instructions from https://www.linuxfromscratch.org/lfs/view/stable/chapter06/m4.html
# Before running this script, ensure that the LFS and LFS_TGT environment variables are set.

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

M4_VERSION=1.4.19
M4_TAR=$LFS/sources/m4-$M4_VERSION.tar.xz
M4_DIR=$LFS/sources/m4-$M4_VERSION

echo "Verifying presence of m4-$M4_VERSION tarball..."
if [ ! -f "$M4_TAR" ]; then
    echo "Error: Tarball $M4_TAR does not exist."
    exit 1
fi

if [ ! -d "$M4_DIR" ]; then
    echo "Extracting m4-$M4_VERSION tarball..."
    tar -xf "$M4_TAR" -C "$LFS/sources"
else
    echo "m4-$M4_VERSION directory already exists. Skipping extraction."
fi

echo "Changing to source directory: $M4_DIR"
cd "$M4_DIR"

echo "Creating build directory..."
mkdir -p build

echo "Changing to build directory..."
cd build

echo "Running configure..."
../configure \
    --prefix=/usr \
    --host=$LFS_TGT \
    --build=$(../build-aux/config.guess)

echo "Compiling the package..."
make

echo "Installing the package..."
make DESTDIR=$LFS install

echo "M4 installation complete."

