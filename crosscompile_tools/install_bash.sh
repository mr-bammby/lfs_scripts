#!/bin/bash

# This script builds and installs the Bash package as part of the Linux From Scratch (LFS) process.
# It follows the instructions from https://www.linuxfromscratch.org/lfs/view/stable/chapter06/bash.html
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

BASH_VERSION=5.2.37
BASH_TAR=$LFS/sources/bash-$BASH_VERSION.tar.gz
BASH_DIR=$LFS/sources/bash-$BASH_VERSION

echo "Verifying presence of bash-$BASH_VERSION tarball..."
if [ -f "$BASH_TAR" ]; then
    echo "Found $BASH_TAR"
else
    echo "Error: Tarball $BASH_TAR does not exist."
    exit 1
fi

if [ ! -d "$BASH_DIR" ]; then
    echo "Extracting bash-$BASH_VERSION tarball..."
    tar -xf "$BASH_TAR" -C "$LFS/sources"
else
    echo "bash-$BASH_VERSION directory already exists. Skipping extraction."
fi

echo "Changing to source directory: $BASH_DIR"
cd "$BASH_DIR"

echo "Running configure for bash..."
./configure \
    --prefix=/usr \
    --host=$LFS_TGT \
    --without-bash-malloc

echo "Compiling the package..."
make

echo "Installing the package..."
make DESTDIR=$LFS install

echo "Creating symbolic link for sh..."
ln -sfv bash $LFS/bin/sh

echo "Bash installation complete."

