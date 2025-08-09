#!/bin/bash

export LFS=/mnt/lfs
export LFS_TGT=x86_64-lfs-linux-gnu

# Check for LFS and LFS_TGT environment variables
if [ -z "$LFS" ]; then
    echo "LFS environment variable is not set."
    exit 1
fi

if [ -z "$LFS_TGT" ]; then
    echo "LFS_TGT environment variable is not set."
    exit 1
fi

# Define variables
TARBALL="$LFS/sources/gcc-14.2.0.tar.xz"
GCC_DIR="$LFS/sources/gcc-14.2.0"
BUILD_DIR="$GCC_DIR/build"

# Check if the tarball exists
if [ ! -f "$TARBALL" ]; then
    echo "GCC tarball not found in $LFS/sources."
    exit 1
fi

rm -rf  "GCC_DIR"

# Untar the GCC source if the directory doesn't exist
if [ ! -d "$GCC_DIR" ]; then
    echo "Untarring GCC source..."
    tar -xf "$TARBALL" -C "$LFS/sources"
    if [ $? -ne 0 ]; then
        echo "Failed to untar GCC source."
        exit 1
    fi
fi

# Create the build directory if it doesn't exist
mkdir -p "$BUILD_DIR"

# Change to the build directory
cd "$BUILD_DIR"

# Configure the build according to LFS chapter05/gcc-libstdc++.html
../libstdc++-v3/configure           \
    --host=$LFS_TGT                 \
    --build=$(../config.guess)      \
    --prefix=/usr                   \
    --disable-multilib              \
    --disable-nls                   \
    --disable-libstdcxx-pch         \
    --with-gxx-include-dir=/tools/$LFS_TGT/include/c++/14.2.0

# Build libstdc++
make

# Install libstdc++
make DESTDIR=$LFS install

rm -v $LFS/usr/lib/lib{stdc++{,exp,fs},supc++}.la
