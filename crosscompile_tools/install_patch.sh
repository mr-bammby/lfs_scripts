#!/bin/bash

# This script builds and installs the Patch package as part of the Linux From Scratch (LFS) process.
# It follows the instructions from https://www.linuxfromscratch.org/lfs/view/12.3/chapter06/patch.html
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

PATCH_VERSION=2.7.6
PATCH_TAR=$LFS/sources/patch-$PATCH_VERSION.tar.xz
PATCH_DIR=$LFS/sources/patch-$PATCH_VERSION

echo "Verifying presence of patch-$PATCH_VERSION tarball..."
if [ -f "$PATCH_TAR" ]; then
    echo "Found $PATCH_TAR"
else
    echo "Error: Tarball $PATCH_TAR does not exist."
    exit 1
fi

if [ ! -d "$PATCH_DIR" ]; then
    echo "Extracting patch-$PATCH_VERSION tarball..."
    tar -xf "$PATCH_TAR" -C "$LFS/sources"
else
    echo "patch-$PATCH_VERSION directory already exists. Skipping extraction."
fi

echo "Changing to source directory: $PATCH_DIR"
cd "$PATCH_DIR"

echo "Creating build directory..."
mkdir -p build

echo "Changing to build directory..."
cd build

echo "Running configure for patch..."
../configure \
    --prefix=/usr \
    --host=$LFS_TGT \
    --build=$(../build-aux/config.guess)

echo "Compiling the package..."
make

echo "Installing the package..."
make DESTDIR=$LFS install

echo "Patch installation complete."
