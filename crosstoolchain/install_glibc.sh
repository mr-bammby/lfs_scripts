#!/bin/bash
# Script to build and install glibc as per LFS Chapter 5

export LFS=/mnt/lfs
export LFS_TGT=x86_64-lfs-linux-gnu

#!/bin/bash
# Script to build and install glibc as per LFS Chapter 5

# Check if LFS environment variable is set
if [ -z "$LFS" ]; then
    echo "Error: LFS environment variable is not set."
    exit 1
fi

# Check if LFS_TGT environment variable is set
if [ -z "$LFS_TGT" ]; then
    echo "Error: LFS_TGT environment variable is not set."
    exit 1
fi

# Check if the script is running as root
if [ $(id -u) -eq 0 ]; then
    echo "Error: This script should not be run as root."
    exit 1
fi

set -e

# Unpack glibc tarball
echo "Uncompressing tar file"
tar -xf $LFS/sources/glibc-2.41.tar.xz -C $LFS/sources/

# Set glibc source directory
GLIBC_SRC=$LFS/sources/glibc-2.41

# Create symbolic links for LSB compliance
echo "Creating symbolc link"
case $(uname -m) in
    i?86)   ln -sfv ld-linux.so.2 $LFS/lib/ld-lsb.so.3
            ;;
    x86_64) ln -sfv ../lib/ld-linux-x86-64.so.2 $LFS/lib64
            ln -sfv ../lib/ld-linux-x86-64.so.2 $LFS/lib64/ld-lsb-x86-64.so.3
            ;;
    *)      echo "Unsupported architecture: $(uname -m)"
            exit 1
            ;;
esac

# Apply patch for FHS compliance
echo "Patching..."
patch -Np1 -i $LFS/sources/glibc-2.41-fhs-1.patch -d $GLIBC_SRC

# Create build directory
mkdir -pv $GLIBC_SRC/build

# Set rootsbindir for installation paths
echo "rootsbindir=/usr/sbin" > $GLIBC_SRC/build/configparms

cd $GLIBC_SRC/build 

# Configure glibc
echo "Configuring..."
../configure \
    --prefix=/usr \
    --host=$LFS_TGT \
    --build=$($GLIBC_SRC/scripts/config.guess) \
    --enable-kernel=5.4 \
    --with-headers=$LFS/usr/include \
    --disable-nscd \
    libc_cv_slibdir=/usr/lib

# Compile glibc
echo "Building..."
make

# Install glibc to $LFS
echo "Insatlling..."
make DESTDIR=$LFS install

cd -

# Fix ldd script for chroot environment
sed '/RTLDLIST=/s@/usr@@g' -i $LFS/usr/bin/ldd

echo "Glibc installed successfully"

echo 'int main(){}' | $LFS_TGT-gcc -xc -
readelf -l a.out | grep ld-linux

rm -v a.out
