#!/bin/bash

# Script to enter the chroot environment as per LFS 12.3 Chapter 7.4
# Purpose: This script enters the chroot environment to isolate the build process to the LFS filesystem,
# setting up a minimal environment with temporary tools for building the final system.

# Define and export LFS variable
# Explanation: LFS is the mount point for the LFS system. We set it to /mnt/lfs, the standard location
# as per the LFS guide, and export it to ensure it is available in subprocesses like su -c.
export LFS=/mnt/lfs

# Ensure the script is run as user lfs initially
# Explanation: The LFS guide assumes the user is 'lfs' for most steps in Chapter 7. This check ensures
# the script is executed in the correct user context.
if [ "$(whoami)" != "lfs" ]; then
    echo "This script must be run as user lfs initially."
    exit 1
fi

# Ensure LFS variable is set and directory exists
# Explanation: We verify that the LFS variable is defined and points to an existing directory to
# prevent errors when entering the chroot environment with a non-existent root directory.
if [ -z "$LFS" ] || [ ! -d "$LFS" ]; then
    echo "LFS variable is not set or directory does not exist. Please set LFS correctly."
    exit 1
fi

# Prompt user for root password and switch to root user
# Explanation: The chroot command requires root privileges to change the root directory of the process.
# The su -c command executes the chroot command as root, prompting for the root password to authenticate.
echo "This script requires root privileges to enter the chroot environment."
echo "Please enter the root password when prompted."
su -c "
    export PATH=$PATH:/sbin:/usr/sbin
    # Enter the chroot environment
    # Explanation: The chroot command isolates the environment to $LFS, using /usr/bin/env -i to clear
    # all variables, then sets HOME, TERM, PS1, PATH, MAKEFLAGS, and TESTSUITEFLAGS. The /bin/bash
    # --login command starts a new login shell in the chroot environment.
    chroot \"$LFS\" /usr/bin/env -i \
        HOME=/root \
        TERM=\"$TERM\" \
        PS1='(lfs chroot) \u:\w\$ ' \
        PATH=/usr/bin:/usr/sbin \
        MAKEFLAGS=\"-j$(nproc)\" \
        TESTSUITEFLAGS=\"-j$(nproc)\" \
        /bin/bash --login
"

# Check if the su command was successful
# Explanation: If the su command fails (e.g., due to an incorrect root password), we notify the user
# and exit to prevent proceeding with an invalid chroot setup.
if [ $? -ne 0 ]; then
    echo "Failed to execute root commands. Please check the root password and try again."
    exit 1
fi

# Note: The script remains in the chroot environment
# Explanation: After the su -c command completes, the chroot command keeps the user in the chroot
# environment as the lfs user (via the Bash shell), as required by the LFS guide and the user's request.
# Subsequent commands should be run in the chroot environment.
echo "Entered the chroot environment successfully."
echo "You are now in the chroot environment as the lfs user."
echo "Note: The prompt may show 'I have no name!' until /etc/passwd is created in the next step."

