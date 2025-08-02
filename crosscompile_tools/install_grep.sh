#!/bin/bash

# This script builds and installs the Grep package as part of the Linux From Scratch (LFS) process.
# It follows the instructions from https://www.linuxfromscratch.org/lfs/view/stable/chapter06/grep.html
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

GREP_VERSION=3.11
GREP_TAR=$LFS/sources/grep-$GREP_VERSION.tar.xz
GREP_DIR=$LFS/sources/grep-$GREP_VERSION

echo "Verifying presence of grep-$GREP_VERSION tarball..."
if [ -f "$GREP_TAR" ]; then
    echo "Found $GREP_TAR"
else
    echo "Error: Tarball $GREP_TAR does not exist."
    exit 1
fi

if [ ! -d "$GREP_DIR" ]; then
    echo "Extracting grep-$GREP_VERSION tarball..."
    tar -xf "$GREP_TAR" -C "$LFS/sources"
else
    echo "grep-$GREP_VERSION directory already exists. Skipping extraction."
fi

echo "Changing to source directory: $GREP_DIR"
cd "$GREP_DIR"

echo "Creating build directory..."
mkdir -p build

echo "Changing to build directory..."
cd build

echo "Running configure for grep..."
../configure \
    --prefix=/usr \
    --host=$LFS_TGT \
    --build=$(../build-aux/config.guess)

echo "Compiling the package..."
make

echo "Installing the package..."
make DESTDIR=$LFS install

echo "Grep installation complete."
