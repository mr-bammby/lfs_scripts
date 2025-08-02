#!/bin/bash

# This script builds and installs the Tar package as part of the Linux From Scratch (LFS) process.
# It follows the instructions from https://www.linuxfromscratch.org/lfs/view/12.3/chapter06/tar.html
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

TAR_VERSION=1.35
TAR_TAR=$LFS/sources/tar-$TAR_VERSION.tar.xz
TAR_DIR=$LFS/sources/tar-$TAR_VERSION

echo "Verifying presence of tar-$TAR_VERSION tarball..."
if [ -f "$TAR_TAR" ]; then
    echo "Found $TAR_TAR"
else
    echo "Error: Tarball $TAR_TAR does not exist."
    exit 1
fi

if [ ! -d "$TAR_DIR" ]; then
    echo "Extracting tar-$TAR_VERSION tarball..."
    tar -xf "$TAR_TAR" -C "$LFS/sources"
else
    echo "tar-$TAR_VERSION directory already exists. Skipping extraction."
fi

echo "Changing to source directory: $TAR_DIR"
cd "$TAR_DIR"

echo "Creating build directory..."
mkdir -p build

echo "Changing to build directory..."
cd build

echo "Running configure for tar..."
../configure \
    --prefix=/usr \
    --host=$LFS_TGT \
    --build=$(../build-aux/config.guess)

echo "Compiling the package..."
make

echo "Installing the package..."
make DESTDIR=$LFS install

echo "Tar installation complete."
