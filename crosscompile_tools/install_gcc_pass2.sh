#!/bin/bash

# This script builds and installs the GCC package (Pass 2) as part of the Linux From Scratch (LFS) process.
# It follows the instructions from https://www.linuxfromscratch.org/lfs/view/12.3/chapter06/gcc-pass2.html
# Before running this script, ensure that the LFS and LFS_TGT environment variables are set.
# For example:
export LFS=/mnt/lfs
export LFS_TGT=x86_64-lfs-linux-gnu

2set -e

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

echo "Checking for cross-compiler..."
if ! command -v $LFS_TGT-gcc >/dev/null 2>&1; then
    echo "Error: Cross-compiler $LFS_TGT-gcc not found. Ensure GCC Pass 1 and Binutils are correctly installed."
    exit 1
fi
if ! command -v $LFS_TGT-g++ >/dev/null 2>&1; then
    echo "Error: Cross-compiler $LFS_TGT-g++ not found. Ensure GCC Pass 1 and Binutils are correctly installed."
    exit 1
fi

echo "Unsetting optimization flags..."
unset CFLAGS
unset CXXFLAGS
unset LDFLAGS

GCC_VERSION=14.2.0
MPFR_VERSION=4.2.1
GMP_VERSION=6.3.0
MPC_VERSION=1.3.1
GCC_TAR=$LFS/sources/gcc-$GCC_VERSION.tar.xz
MPFR_TAR=$LFS/sources/mpfr-$MPFR_VERSION.tar.xz
GMP_TAR=$LFS/sources/gmp-$GMP_VERSION.tar.xz
MPC_TAR=$LFS/sources/mpc-$MPC_VERSION.tar.gz
GCC_DIR=$LFS/sources/gcc-$GCC_VERSION

echo "Verifying presence of required tarballs..."
for tarball in "$GCC_TAR" "$MPFR_TAR" "$GMP_TAR" "$MPC_TAR"; do
    if [ -f "$tarball" ]; then
        echo "Found $tarball"
    else
        echo "Error: Tarball $tarball does not exist."
        exit 1
    fi
done

echo "Removing existing GCC source directory if it exists..."
rm -rf "$GCC_DIR"

echo "Extracting gcc-$GCC_VERSION tarball..."
tar -xf "$GCC_TAR" -C "$LFS/sources"

echo "Changing to source directory: $GCC_DIR"
cd "$GCC_DIR"

echo "Removing existing GMP, MPFR, and MPC directories if they exist..."
rm -rf gmp mpfr mpc

echo "Extracting and moving GMP, MPFR, and MPC..."
tar -xf "$MPFR_TAR"
mv -v mpfr-$MPFR_VERSION mpfr
tar -xf "$GMP_TAR"
mv -v gmp-$GMP_VERSION gmp
tar -xf "$MPC_TAR"
mv -v mpc-$MPC_VERSION mpc

echo "Applying sed for x86_64 library directory if necessary..."
case $(uname -m) in
  x86_64)
    sed -e '/m64=/s/lib64/lib/' -i.orig gcc/config/i386/t-linux64
  ;;
esac

echo "Applying sed for POSIX threads support..."
sed '/thread_header =/s/@.*@/gthr-posix.h/' -i libgcc/Makefile.in libstdc++-v3/include/Makefile.in

echo "Removing existing build directory if it exists..."
rm -rf build

echo "Creating build directory..."
mkdir -p build

echo "Changing to build directory..."
cd build

echo "Removing old configuration files..."
rm -f config.cache config.status

echo "Running configure for gcc..."
../configure \
    --build=$(../config.guess) \
    --host=$LFS_TGT \
    --target=$LFS_TGT \
    LDFLAGS_FOR_TARGET=-L$PWD/$LFS_TGT/libgcc \
    --prefix=/usr \
    --with-build-sysroot=$LFS \
    --enable-default-pie \
    --enable-default-ssp \
    --disable-nls \
    --disable-multilib \
    --disable-libatomic \
    --disable-libgomp \
    --disable-libquadmath \
    --disable-libsanitizer \
    --disable-libssp \
    --disable-libvtv \
    --enable-languages=c,c++

echo "Compiling the package..."
make

echo "Installing the package..."
make DESTDIR=$LFS install

echo "Creating cc symlink..."
ln -sv gcc $LFS/usr/bin/cc

echo "GCC Pass 2 installation complete."
