#!/bin/sh
# Thanks to https://git-tails.immerda.ch/tails/tree/config/chroot_local-hooks

set -x
set -e
set -u

echo "Truncating log files"
for file in $(find $WD/chroot/var/log/ -type f); do
	: > "${file}"
done

# END
