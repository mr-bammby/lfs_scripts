#!/bin/bash

# Script to prepare virtual kernel file systems as per LFS 12.3 Chapter 7.3
# Purpose: This script creates directories and mounts virtual kernel file systems (/dev, /proc, /sys,
# /run, /dev/shm) in the LFS system to enable communication between userspace applications and the
# kernel in the chroot environment.

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
# prevent errors when creating directories or mounting file systems.
if [ -z "$LFS" ] || [ ! -d "$LFS" ]; then
    echo "LFS variable is not set or directory does not exist. Please set LFS correctly."
    exit 1
fi

# Prompt user for root password and switch to root user
# Explanation: Creating directories and mounting virtual file systems require root privileges because
# these operations modify system-level structures. The su -c command executes these actions as root,
# prompting for the root password to authenticate.
echo "This script requires root privileges to create directories and mount virtual kernel file systems."
echo "Please enter the root password when prompted."
su -c "
    # Create directories for virtual file systems
    # Explanation: These directories (/dev, /proc, /sys, /run) serve as mount points for the virtual
    # kernel file systems required by the LFS system.
    mkdir -pv $LFS/{dev,proc,sys,run}

    # Mount and populate /dev with a bind mount
    # Explanation: A bind mount of the host's /dev to $LFS/dev ensures device nodes are available in
    # the chroot environment. This is the host-agnostic approach, as some host kernels may not support
    # devtmpfs.
    mount -v --bind /dev $LFS/dev

    # Mount remaining virtual kernel file systems
    # Explanation: These mounts provide access to pseudo-terminals (devpts), process information (proc),
    # kernel objects (sysfs), and runtime data (tmpfs). The devpts options ensure proper ownership and
    # permissions for terminal devices.
    mount -vt devpts devpts -o gid=5,mode=0620 $LFS/dev/pts
    mount -vt proc proc $LFS/proc
    mount -vt sysfs sysfs $LFS/sys
    mount -vt tmpfs tmpfs $LFS/run

    # Handle /dev/shm
    # Explanation: If /dev/shm is a symlink (e.g., to /run/shm), create the target directory with
    # 1777 permissions. Otherwise, mount a tmpfs at /dev/shm with security options (nosuid, nodev).
    if [ -h $LFS/dev/shm ]; then
        install -v -d -m 1777 $LFS\$(realpath /dev/shm)
    else
        mount -vt tmpfs -o nosuid,nodev tmpfs $LFS/dev/shm
    fi
"

# Check if the su command was successful
# Explanation: If the su command fails (e.g., due to an incorrect root password), we notify the user
# and exit to prevent proceeding with incomplete mounts.
if [ $? -ne 0 ]; then
    echo "Failed to execute root commands. Please check the root password and try again."
    exit 1
fi

# Script automatically returns to lfs user after su -c command completes
# Explanation: After the su -c command completes, the script reverts to the 'lfs' user context, as
# required by the LFS guide and the user's request, to ensure subsequent steps are performed as 'lfs'.
echo "Virtual kernel file systems have been prepared successfully."
echo "Returned to lfs user."
