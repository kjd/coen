#!/bin/sh
# The file /etc/shadow is not reproducible
# Thanks to https://git-tails.immerda.ch/tails/tree/config/chroot_local-hooks

set -x # This option causes a bash script to print each command before executing it
set -e # This option cause a bash script to exit immediately when a command fails
set -u # This option causes a bash script to treat unset variables as an error and exit immediately

# Post-process /etc/shadow by setting the sp_lstchg field to the number of days
# since SOURCE_DATE_EPOCH instead of 1st Jan 1970. (#12339)
# drop this if https://bugs.debian.org/857803 is fixed.

cat << EOF | chroot $WD/chroot
cut -d: -f1 /etc/shadow | \
  xargs -L1 \
    chage --lastday \
      "$(($(date --utc --date "@${SOURCE_DATE_EPOCH}" "+%s") / 86400))"

cp --preserve=timestamps /etc/shadow /etc/shadow-
EOF
# END
