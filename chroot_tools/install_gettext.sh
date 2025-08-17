#!/bin/bash

# Script to install temporary Gettext tools inside chroot as per LFS 12.3 Chapter 7.7
# Purpose: This script extracts the Gettext-0.24 source tarball, compiles, and installs three Gettext
# programs (msgfmt, msgmerge, xgettext) needed for Native Language Support during the LFS build process.
# It builds in a separate build directory inside the source directory and uses cd for navigation.
# Run as root in the chroot environment.

# Ensure the script is run as root
# Explanation: Compilation and installation require root privileges in the chroot environment.
if [ "$(id -u)" != "0" ]; then
    echo "This script must be run as root in the chroot environment."
    exit 1
fi

# Store the current working directory to return later
# Explanation: Save the current directory to restore it after operations to maintain user context.
ORIGINAL_DIR=$(pwd)

# Define source directory and tarball
# Explanation: The /sources directory is the standard location for LFS source tarballs.
SOURCES_DIR="/sources"
TARBALL="gettext-0.24.tar.xz"
GETTEXT_DIR="gettext-0.24"
BUILD_DIR="build"

# Ensure the tarball exists
# Explanation: Check if the Gettext tarball exists in /sources to prevent errors during extraction.
if [ ! -f "$SOURCES_DIR/$TARBALL" ]; then
    echo "Error: Gettext tarball $TARBALL not found in $SOURCES_DIR."
    echo "Please download gettext-0.24.tar.xz and place it in /sources."
    exit 1
fi

# Change to the sources directory
# Explanation: Navigate to /sources to perform extraction and ensure a clean working environment.
cd "$SOURCES_DIR" || { echo "Failed to change to $SOURCES_DIR"; exit 1; }

# Remove any existing Gettext directory to avoid conflicts
# Explanation: Ensure a clean extraction by removing any previous Gettext source directory.
if [ -d "$GETTEXT_DIR" ]; then
    rm -rf "$GETTEXT_DIR"
    echo "Removed existing $GETTEXT_DIR directory."
fi

# Extract the Gettext tarball
# Explanation: Untar the Gettext-0.24 source tarball to prepare for compilation.
tar -xvf "$TARBALL" || { echo "Failed to extract $TARBALL"; exit 1; }
echo "Extracted $TARBALL successfully."

# Change to the Gettext source directory
# Explanation: Navigate to the extracted directory to create the build directory and run commands.
cd "$GETTEXT_DIR" || { echo "Failed to change to $GETTEXT_DIR"; exit 1; }

# Create the build directory
# Explanation: Create a build directory inside the source directory for out-of-source compilation.
mkdir -p "$BUILD_DIR" || { echo "Failed to create $BUILD_DIR"; exit 1; }
echo "Created build directory $BUILD_DIR."

# Change to the build directory
# Explanation: Navigate to the build directory to run configure and make.
cd "$BUILD_DIR" || { echo "Failed to change to $BUILD_DIR"; exit 1; }

# Prepare Gettext for compilation
# Explanation: Run configure from the build directory, pointing to the parent source directory,
# with --disable-shared to prevent building unnecessary shared libraries.
../configure --disable-shared || { echo "Failed to configure Gettext"; exit 1; }

# Compile the package
# Explanation: Build the Gettext tools in the build directory; only required programs will be installed.
make || { echo "Failed to compile Gettext"; exit 1; }

# Install the msgfmt, msgmerge, and xgettext programs
# Explanation: Copy the three essential programs from the source directory to /usr/bin.
cp -v ../gettext-tools/src/{msgfmt,msgmerge,xgettext} /usr/bin || { echo "Failed to install Gettext tools"; exit 1; }

# Return to the original working directory
# Explanation: Restore the original working directory to maintain user context.
cd "$ORIGINAL_DIR" || { echo "Failed to return to $ORIGINAL_DIR"; exit 1; }

echo "Temporary Gettext tools have been installed successfully in the chroot environment."

