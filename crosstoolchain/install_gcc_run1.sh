#!/bin/bash
export LFS=/mnt/lfs
export LFS_TGT=x86_64-lfs-linux-gnu
export PATH=/mnt/lfs/tools/bin:$PATH

# Script to build gcc Pass 1 for LFS as per Chapter 5.3
# Builds from sources in $LFS/sources with build directory inside untarred source

# Enable debug mode if needed (uncomment to trace execution)
# set -x

# Ensure the script is running in Bash
if [ -z "$BASH_VERSION" ]; then
  echo "Error: This script must be run with Bash, not sh or another shell."
  exit 1
fi

# Check if LFS variable is set
if [ -z "$LFS" ]; then
  echo "Error: LFS variable is not set. Please set it before running the script."
  exit 1
fi

# Check if LFS_TGT is set
if [ -z "$LFS_TGT" ]; then
  echo "Error: LFS_TGT variable is not set. Please set it (e.g., x86_64-lfs-linux-gnu)."
  exit 1
fi

# Function to build gcc Pass 1
build_gcc_pass1() {
  local archive="gcc-14.2.0.tar.xz"
  local src_dir=${archive%.tar.*}
  local build_dir="$LFS/sources/$src_dir/build"

  echo "Building $src_dir (Pass 1)..."

  # Check if source archive exists
  if [ ! -f "$LFS/sources/$archive" ]; then
    echo "Error: Source archive $archive not found in $LFS/sources"
    return 1
  fi

  # Check for dependency archives
  for dep in mpfr-4.2.1.tar.xz gmp-6.3.0.tar.xz mpc-1.3.1.tar.gz; do
    if [ ! -f "$LFS/sources/$dep" ]; then
      echo "Error: Dependency archive $dep not found in $LFS/sources"
      return 1
    fi
  done

  # Extract gcc archive if not already extracted
  if [ ! -d "$LFS/sources/$src_dir" ]; then
    tar -xf "$LFS/sources/$archive" -C "$LFS/sources" || {
      echo "Failed to extract $archive"
      return 1
    }
  fi

  # Extract and rename dependency archives inside gcc source directory
  cd "$LFS/sources/$src_dir" || {
    echo "Failed to change to $LFS/sources/$src_dir"
    return 1
  }
  tar -xf "$LFS/sources/mpfr-4.2.1.tar.xz" && mv -v mpfr-4.2.1 mpfr || {
    echo "Failed to extract or rename mpfr-4.2.1"
    return 1
  }
  tar -xf "$LFS/sources/gmp-6.3.0.tar.xz" && mv -v gmp-6.3.0 gmp || {
    echo "Failed to extract or rename gmp-6.3.0"
    return 1
  }
  tar -xf "$LFS/sources/mpc-1.3.1.tar.gz" && mv -v mpc-1.3.1 mpc || {
    echo "Failed to extract or rename mpc-1.3.1"
    return 1
  }

  # Create build directory inside untarred source
  mkdir -p "$build_dir" || {
    echo "Failed to create build directory $build_dir"
    return 1
  }

  # Change to build directory
  cd "$build_dir" || {
    echo "Failed to change to $build_dir"
    return 1
  }

  # Run configure with options from LFS Chapter 5.3
  ../configure \
    --target=$LFS_TGT         \
    --prefix=$LFS/tools       \
    --with-glibc-version=2.41 \
    --with-sysroot=$LFS       \
    --with-newlib             \
    --without-headers         \
    --enable-default-pie      \
    --enable-default-ssp      \
    --disable-nls             \
    --disable-shared          \
    --disable-multilib        \
    --disable-threads         \
    --disable-libatomic       \
    --disable-libgomp         \
    --disable-libquadmath     \
    --disable-libssp          \
    --disable-libvtv          \
    --disable-libstdcxx       \
    --enable-languages=c,c++ || {
    echo "Configure failed for $src_dir"
    return 1
  }

  # Compile
  make || {
    echo "Make failed for $src_dir"
    return 1
  }

  # Install
  make install || {
    echo "Make install failed for $src_dir"
    return 1
  }

  cd ..
  cat gcc/limitx.h gcc/glimits.h gcc/limity.h > \
  `dirname $($LFS_TGT-gcc -print-libgcc-file-name)`/include/limits.h

  echo "Finished building $src_dir (Pass 1)"
}

# Execute the build
build_gcc_pass1

echo "GCC Pass 1 build completed."

# Note:
# - Ensure archive names match versions in $LFS/sources (gcc-14.2.0.tar.xz, mpfr-4.2.1.tar.xz, gmp-6.3.0.tar.xz, mpc-1.3.1.tar.gz).
# - Set LFS_TGT before running (e.g., export LFS_TGT=x86_64-lfs-linux-gnu).
# - Build directory is created as $LFS/sources/gcc-14.2.0/build.
# - This script follows https://www.linuxfromscratch.org/lfs/view/stable/chapter05/gcc-pass1.html.
# - To debug, uncomment 'set -x' at the top to trace execution.

