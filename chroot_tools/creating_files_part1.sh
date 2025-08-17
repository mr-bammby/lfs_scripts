#!/bin/bash

# Script to create essential files and symlinks inside chroot as per LFS 12.3 Chapter 7.6
# Purpose: This script creates the /etc/mtab symlink, /etc/hosts, /etc/passwd, /etc/group, a tester
# user account, and log files in the LFS system to support system functionality, user management, and
# logging in the chroot environment. It ensures new files override any pre-existing files with the same
# names. Adapted for execution inside the chroot environment (run as root).

# Ensure the script is run as root
# Explanation: Creating files, symlinks, directories, and setting permissions require root privileges.
# In the chroot environment, commands are run as root (UID 0).
if [ "$(id -u)" != "0" ]; then
    echo "This script must be run as root in the chroot environment."
    exit 1
fi

# Create /etc/mtab symlink
# Explanation: The /etc/mtab symlink points to /proc/self/mounts, satisfying utilities that expect
# /etc/mtab. The -f flag ensures any existing symlink is overwritten.
ln -sfv /proc/self/mounts /etc/mtab

# Create /etc/hosts file
# Explanation: The /etc/hosts file provides hostname resolution for localhost and the current
# hostname, required for test suites and Perl's configuration. The > operator overwrites any existing file.
cat > /etc/hosts << EOF
127.0.0.1  localhost $(hostname)
::1        localhost
EOF

# Create /etc/passwd file
# Explanation: The /etc/passwd file defines user accounts (root, bin, daemon, etc.) and their
# properties, enabling login functionality and name resolution. The > operator overwrites any existing file.
cat > /etc/passwd << "EOF"
root:x:0:0:root:/root:/bin/bash
bin:x:1:1:bin:/dev/null:/usr/bin/false
daemon:x:6:6:Daemon User:/dev/null:/usr/bin/false
messagebus:x:18:18:D-Bus Message Daemon User:/run/dbus:/usr/bin/false
uuidd:x:80:80:UUID Generation Daemon User:/dev/null:/usr/bin/false
nobody:x:65534:65534:Unprivileged User:/dev/null:/usr/bin/false
EOF

# Create /etc/group file
# Explanation: The /etc/group file defines groups (root, bin, tty, etc.) required for Udev
# configuration, test suites, and system operations. The > operator overwrites any existing file.
cat > /etc/group << "EOF"
root:x:0:
bin:x:1:daemon
sys:x:2:
kmem:x:3:
tape:x:4:
tty:x:5:
daemon:x:6:
floppy:x:7:
disk:x:8:
lp:x:9:
dialout:x:10:
audio:x:11:
video:x:12:
utmp:x:13:
cdrom:x:15:
adm:x:16:
messagebus:x:18:
input:x:24:
mail:x:34:
kvm:x:61:
uuidd:x:80:
wheel:x:97:
users:x:999:
nogroup:x:65534:
EOF

# Remove existing tester user entries to avoid duplicates
# Explanation: Before adding the tester user, any existing tester entries are removed from /etc/passwd
# and /etc/group to ensure clean addition and avoid duplicates.
sed -i '/^tester:/d' /etc/passwd
sed -i '/^tester:/d' /etc/group

# Add tester user for Chapter 8 tests
# Explanation: The tester user (UID/GID 101) is added to /etc/passwd and /etc/group, and its home
# directory is created with correct ownership, overwriting any existing ownership.
echo "tester:x:101:101::/home/tester:/bin/bash" >> /etc/passwd
echo "tester:x:101:" >> /etc/group
install -o tester -d /home/tester

echo "Essential files and symlinks have been created successfully in the chroot environment. Part 1" 

# Start a new shell to use /etc/passwd and /etc/group
# Explanation: A new login shell is started to ensure name resolution works with the newly created
# /etc/passwd and /etc/group files, resolving the 'I have no name!' prompt.
exec /usr/bin/bash --login

# Initialize log files and set permissions
# Explanation: Log files (btmp, lastlog, faillog, wtmp) are created (or touched if existing) and
# configured with appropriate group (utmp) and permissions to support login/logout tracking and failed
# attempt logging, overriding any existing permissions.
touch /var/log/{btmp,lastlog,faillog,wtmp}
chgrp -v utmp /var/log/lastlog
chmod -v 664 /var/log/lastlog
chmod -v 600 /var/log/btmp

echo "Essential files and symlinks have been created successfully in the chroot environment."
