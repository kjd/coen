#!/bin/sh
# Thanks to https://git-tails.immerda.ch/tails/tree/config/chroot_local-hooks

set -x
set -e
set -u

# Python byte code
echo "Removing *.pyc"
find /usr -type f -name "*.pyc" -delete

# END
