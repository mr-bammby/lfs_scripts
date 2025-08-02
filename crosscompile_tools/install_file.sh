#!/bin/bash

# This script builds and installs the File package as part of the Linux From Scratch (LFS) process.
# It follows the instructions from https://www.linuxfromscratch.org/lfs/view/stable/chapter06/file.html
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

FILE_VERSION=5.46
FILE_TAR=$LFS/sources/file-$FILE_VERSION.tar.gz
FILE_DIR=$LFS/sources/file-$FILE_VERSION

echo "Verifying presence of file-$FILE_VERSION tarball..."
if [ -f "$FILE_TAR" ]; then
    echo "Found $FILE_TAR"
else
    echo "Error: Tarball $FILE_TAR does not exist."
    exit 1
fi

if [ ! -d "$FILE_DIR" ]; then
    echo "Extracting file-$FILE_VERSION tarball..."
    tar -xf "$FILE_TAR" -C "$LFS/sources"
else
    echo "file-$FILE_VERSION directory already exists. Skipping extraction."
fi

echo "Changing to source directory: $FILE_DIR"
cd "$FILE_DIR"

echo "Creating build directory..."
mkdir -p build
pushd build
echo "Running configure with disabled features..."
../configure \
    --disable-bzlib \
    --disable-libseccomp \
    --disable-xzlib \
    --disable-zlib
echo "Compiling file..."
make
popd

echo "Running main configure..."
./configure \
    --prefix=/usr \
    --host=$LFS_TGT \
    --build=$(./config.guess)

echo "Compiling the package..."
make FILE_COMPILE=$(pwd)/build/src/file

echo "Installing the package..."
make DESTDIR=$LFS install

echo "Removing libmagic.la..."
rm -v $LFS/usr/lib/libmagic.la

echo "File installation complete."
