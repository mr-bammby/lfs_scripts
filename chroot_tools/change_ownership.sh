#!/bin/bash

# Script to change ownership of LFS directories as per LFS 12.3 Chapter 7.2
# Purpose: This script changes the ownership of critical directories in the Linux From Scratch (LFS)
# system from the 'lfs' user to the 'root' user to prevent potential security risks. If left owned
# by 'lfs', a user ID without a corresponding account could later be assigned to a new user, who would
# then have unintended access to these critical system files.

# Define and export LFS variable
# Explanation: LFS is the mount point for the LFS system. We set it to /mnt/lfs, the standard location
# as per the LFS guide, and export it to ensure it is available in subprocesses like su -c.
export LFS=/mnt/lfs

# Ensure the script is run as user lfs initially
# Explanation: The LFS guide specifies that the user should be logged in as 'lfs' before performing
# these steps. This check ensures the script is executed in the correct context.
if [ "$(whoami)" != "lfs" ]; then
    echo "This script must be run as user lfs initially."
    exit 1
fi

# Ensure LFS variable is set and directory exists
# Explanation: We verify that the LFS variable is defined and points to an existing directory to
# prevent errors when executing chown commands on non-existent paths.
if [ -z "$LFS" ] || [ ! -d "$LFS" ]; then
    echo "LFS variable is not set or directory does not exist. Please set LFS correctly."
    exit 1
fi

# Display current ownership of directories before changes
# Explanation: The stat command shows the current owner and group of the directories to be modified,
# allowing the user to verify that they are owned by 'lfs' before proceeding.
echo "Current ownership of LFS directories:"
stat -c "%U:%G %n" $LFS/{usr,lib,var,etc,bin,sbin,tools}
case $(uname -m) in
    x86_64) stat -c "%U:%G %n" $LFS/lib64 ;;
esac

# Prompt user for root password and switch to root user
# Explanation: The chown command requires root privileges because only the root user can change
# ownership of files and directories. The 'su -c' command is used to execute commands as root, and it
# will prompt the user to enter the root password to authenticate.
echo "This script requires root privileges to change ownership of LFS directories."
echo "Please enter the root password when prompted."
su -c "
    # Change ownership of specified directories from lfs to root:root
    # Explanation: The chown command with --from lfs ensures that only files owned by the 'lfs' user
    # are changed to root:root ownership. This targets the /mnt/lfs/{usr,lib,var,etc,bin,sbin,tools}
    # directories as specified in the LFS guide.
    chown --from lfs -R root:root $LFS/{usr,lib,var,etc,bin,sbin,tools}

    # Check architecture and change ownership of lib64 if on x86_64
    # Explanation: On 64-bit systems (x86_64), the /mnt/lfs/lib64 directory may exist and also needs
    # to have its ownership changed to root:root. The case statement checks the system architecture
    # using uname -m and applies the chown command only if necessary.
    case $(uname -m) in
        x86_64) chown --from lfs -R root:root $LFS/lib64 ;;
    esac
"

# Check if the su command was successful
# Explanation: If the su command fails (e.g., due to an incorrect root password), we notify the user
# and exit with an error code to prevent proceeding with incomplete changes.
if [ $? -ne 0 ]; then
    echo "Failed to execute root commands. Please check the root password and try again."
    exit 1
fi

# Display ownership of directories after changes
# Explanation: The stat command is run again to confirm that the ownership of the directories has been
# successfully changed to root:root, providing verification of the script's success.
echo "Ownership of LFS directories after changes:"
stat -c "%U:%G %n" $LFS/{usr,lib,var,etc,bin,sbin,tools}
case $(uname -m) in
    x86_64) stat -c "%U:%G %n" $LFS/lib64 ;;
esac

# Script automatically returns to lfs user after su -c command completes
# Explanation: After the su -c command completes, the script automatically reverts to the 'lfs' user
# context, as required by the LFS guide, to ensure subsequent steps are performed as the 'lfs' user.
echo "Ownership changed successfully for LFS directories."
echo "Returned to lfs user."
