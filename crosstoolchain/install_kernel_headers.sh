#!/bin/bash
export LFS=/mnt/lfs

# Script to install Linux kernel headers for linux-6.13.4.tar.xz
# URL: https://www.linuxfromscratch.org/lfs/view/stable/chapter05/linux-headers.html

# Exit on any error
set -e

# Check if LFS environment variable is set
if [ -z "$LFS" ]; then
    echo "Error: LFS environment variable is not set."
    exit 1
fi

# Check if $LFS/sources exists
if [ ! -d "$LFS/sources" ]; then
    echo "Error: $LFS/sources directory does not exist."
    exit 1
fi

# Check if the specific tarball exists
TARBALL="$LFS/sources/linux-6.13.4.tar.xz"
if [ ! -f "$TARBALL" ]; then
    echo "Error: linux-6.13.4.tar.xz not found in $LFS/sources."
    exit 1
fi

# Extract the tarball
echo "Extracting $TARBALL..."
tar -xf "$TARBALL" -C "$LFS/sources"

# Clean the kernel source tree
echo "Running make mrproper..."
make -C "$LFS/sources/linux-6.13.4" mrproper

# Extract the kernel headers
echo "Extracting kernel headers..."
make -C "$LFS/sources/linux-6.13.4" headers

# Remove unwanted files
echo "Removing unwanted files..."
find "$LFS/sources/linux-6.13.4/usr/include" -name '.*' -delete
rm -rf "$LFS/sources/linux-6.13.4/usr/include/Makefile"

# Install the headers to $LFS/usr/include
echo "Copying headers to $LFS/usr/include..."
mkdir "$LFS/usr/include"
cp -rv "$LFS/sources/linux-6.13.4/usr/include/"* "$LFS/usr/include"

# Clean up: remove the kernel source directory
echo "Cleaning up..."
rm -rf "$LFS/sources/linux-6.13.4"

echo "Linux kernel headers installed successfully."
