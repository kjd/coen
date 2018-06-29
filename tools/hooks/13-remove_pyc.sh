#!/bin/sh
# Remove Python byte code
# Thanks to https://git-tails.immerda.ch/tails/tree/config/chroot_local-hooks

set -x # This option causes a bash script to print each command before executing it
set -e # This option cause a bash script to exit immediately when a command fails
set -u # This option causes a bash script to treat unset variables as an error and exit immediately

# Python byte code
echo "Removing *.pyc"
find $WD/chroot/usr -type f -name "*.pyc" -delete

# END
