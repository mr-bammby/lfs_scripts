install_bison_temp.txt

#!/bin/bash

# Script to install temporary Bison package inside chroot as per LFS 12.3 Chapter 7.8
# Purpose: This script compiles and installs the Bison parser generator needed for building other
# packages in the LFS system. Run as root in the chroot environment.

# Ensure the script is run as root
# Explanation: Compilation and installation require root privileges in the chroot environment.
if [ "$(id -u)" != "0" ]; then
    echo "This script must be run as root in the chroot environment."
    exit 1
fi

# Assume the script is run from the extracted Bison source directory (e.g., /sources/bison-3.8.2)
# If not, change to the source directory before running.

# Prepare Bison for compilation
# Explanation: The --prefix=/usr option sets the installation directory to /usr, and
# --docdir=/usr/share/doc/bison-3.8.2 specifies a versioned directory for documentation.
./configure --prefix=/usr \
            --docdir=/usr/share/doc/bison-3.8.2

# Compile the package
# Explanation: Builds the Bison package, preparing the parser generator for installation.
make

# Install the package
# Explanation: Installs the Bison executable and documentation to /usr/bin and /usr/share/doc/bison-3.8.2.
make install

echo "Temporary Bison package has been installed successfully in the chroot environment."

