#!/bin/bash

export LFS=/mnt/lfs
export LFS_TGT=x86_64-lfs-linux-gnu

#!/bin/bash


# Script to build binutils Pass 1 for LFS as per Chapter 5.2
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


# Function to build binutils Pass 1
build_binutils_pass1() {
  local archive="binutils-2.44.tar.xz"  # As specified in LFS stable version
  local src_dir=${archive%.tar.*}  # Extract source directory name (binutils-2.43.1)
  local build_dir="$LFS/sources/$src_dir/build"


  echo "Building $src_dir (Pass 1)..."


  # Check if source archive exists
  if [ ! -f "$LFS/sources/$archive" ]; then
    echo "Error: Source archive $archive not found in $LFS/sources"
    return 1
  fi


  # Extract archive if not already extracted
  if [ ! -d "$LFS/sources/$src_dir" ]; then
    tar -xf "$LFS/sources/$archive" -C "$LFS/sources" || {
      echo "Failed to extract $archive"
      return 1
    }
  fi


  # Create build directory inside untarred source (near line 32)
  mkdir -p "$build_dir" || {
    echo "Failed to create build directory $build_dir"
    return 1
  }


  # Change to build directory
  cd "$build_dir" || {
    echo "Failed to change to $build_dir"
    return 1
  }


  # Run configure with options from LFS Chapter 5.2
  ../configure \
    --prefix=$LFS/tools \
    --with-sysroot=$LFS \
    --target=$LFS_TGT \
    --disable-nls \
    --enable-gprofng=no \
    --disable-werror \
    --enable-new-dtags  \
    --enable-default-hash-style=gnu || {
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


  # Create symlink for 64-bit systems (as per LFS instructions)
  case $(uname -m) in
    x86_64)
      mkdir -pv $LFS/tools/lib && ln -sv lib $LFS/tools/lib64 || {
        echo "Failed to create lib64 symlink"
        return 1
      }
      ;;
  esac


  echo "Finished building $src_dir (Pass 1)"
}


# Execute the build
build_binutils_pass1


echo "Binutils Pass 1 build completed."


# Note:
# - Ensure the archive name matches the version in $LFS/sources (binutils-2.43.1.tar.xz for LFS stable).
# - Set LFS_TGT before running (e.g., export LFS_TGT=x86_64-lfs-linux-gnu).
# - Build directory is created as $LFS/sources/binutils-2.43.1/build.
# - This script follows https://www.linuxfromscratch.org/lfs/view/stable/chapter05/binutils-pass1.html.
# - To debug, uncomment 'set -x' at the top to trace execution.

