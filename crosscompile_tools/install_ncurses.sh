#!/bin/bash

# This script builds and installs the Ncurses package as part of the Linux From Scratch (LFS) process.
# It follows the instructions from https://www.linuxfromscratch.org/lfs/view/stable/chapter06/ncurses.html
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

NCURSES_VERSION=6.5
NCURSES_TAR=$LFS/sources/ncurses-$NCURSES_VERSION.tar.gz
NCURSES_DIR=$LFS/sources/ncurses-$NCURSES_VERSION

echo "Verifying presence of ncurses-$NCURSES_VERSION tarball..."
if [ ! -f "$NCURSES_TAR" ]; then
    echo "Error: Tarball $NCURSES_TAR does not exist."
    exit 1
fi

if [ ! -d "$NCURSES_DIR" ]; then
    echo "Extracting ncurses-$NCURSES_VERSION tarball..."
    tar -xf "$NCURSES_TAR" -C "$LFS/sources"
else
    echo "ncurses-$NCURSES_VERSION directory already exists. Skipping extraction."
fi

echo "Changing to source directory: $NCURSES_DIR"
cd "$NCURSES_DIR"

echo "Creating build directory for tic..."
mkdir build
pushd build
  echo "Running configure for tic with AWK=gawk..."
  ../configure AWK=gawk
  echo "Building tic program..."
  make -C include
  make -C progs tic
popd

echo "Running configure for ncurses with wide-character support..."
./configure \
    --prefix=/usr \
    --host=$LFS_TGT \
    --build=$(./config.guess) \
    --mandir=/usr/share/man \
    --with-manpage-format=normal \
    --with-shared \
    --without-normal \
    --with-cxx-shared \
    --without-debug \
    --without-ada \
    --disable-stripping \
    AWK=gawk

echo "Compiling the package..."
make

echo "Installing the package..."
make DESTDIR=$LFS TIC_PATH=$(pwd)/build/progs/tic install

echo "Creating symbolic link for compatibility..."
ln -sfv ../../lib/libncursesw.so.$NCURSES_VERSION $LFS/usr/lib/libncurses.so

echo "Applying sed to curses.h for XOPEN compatibility..."
sed -e 's/^#if.*XOPEN.*$/#if 1/' \
    -i $LFS/usr/include/curses.h

echo "Ncurses installation complete."
