#!/bin/bash

# This script builds and installs the Sed package as part of the Linux From Scratch (LFS) process.
# It follows the instructions from https://www.linuxfromscratch.org/lfs/view/12.3/chapter06/sed.html
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

SED_VERSION=4.9
SED_TAR=$LFS/sources/sed-$SED_VERSION.tar.xz
SED_DIR=$LFS/sources/sed-$SED_VERSION

echo "Verifying presence of sed-$SED_VERSION tarball..."
if [ -f "$SED_TAR" ]; then
    echo "Found $SED_TAR"
else
    echo "Error: Tarball $SED_TAR does not exist."
    exit 1
fi

if [ ! -d "$SED_DIR" ]; then
    echo "Extracting sed-$SED_VERSION tarball..."
    tar -xf "$SED_TAR" -C "$LFS/sources"
else
    echo "sed-$SED_VERSION directory already exists. Skipping extraction."
fi

echo "Changing to source directory: $SED_DIR"
cd "$SED_DIR"

echo "Creating build directory..."
mkdir -p build

echo "Changing to build directory..."
cd build

echo "Running configure for sed..."
../configure \
    --prefix=/usr \
    --host=$LFS_TGT \
    --build=$(../build-aux/config.guess)

echo "Compiling the package..."
make

echo "Installing the package..."
make DESTDIR=$LFS install

echo "Sed installation complete."
