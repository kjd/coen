#!/bin/sh
# Truncate log files
# Thanks to https://git-tails.immerda.ch/tails/tree/config/chroot_local-hooks

set -x # This option causes a bash script to print each command before executing it
set -e # This option cause a bash script to exit immediately when a command fails
set -u # This option causes a bash script to treat unset variables as an error and exit immediately

echo "Truncating log files"
for file in $(find $WD/chroot/var/log/ -type f); do
	: > "${file}"
done

# END
