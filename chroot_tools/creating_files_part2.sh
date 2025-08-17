# Initialize log files and set permissions
# Explanation: Log files (btmp, lastlog, faillog, wtmp) are created (or touched if existing) and
# configured with appropriate group (utmp) and permissions to support login/logout tracking and failed
# attempt logging, overriding any existing permissions.
touch /var/log/{btmp,lastlog,faillog,wtmp}
chgrp -v utmp /var/log/lastlog
chmod -v 664 /var/log/lastlog
chmod -v 600 /var/log/btmp

echo "Essential files and symlinks have been created successfully in the chroot environment part2."
