#!/bin/sh
# Thanks to https://git-tails.immerda.ch/tails/tree/config/chroot_local-hooks

set -x
set -e
set -u

# Post-process /etc/shadow by setting the sp_lstchg field to the number of days
# since SOURCE_DATE_EPOCH instead of 1st Jan 1970. (#12339)
# XXX:Buster: drop this if https://bugs.debian.org/857803 is fixed.

cat << EOF | chroot $WD/chroot
cut -d: -f1 /etc/shadow | \
  xargs -L1 \
    chage --lastday \
      "$(($(date --utc --date "@${SOURCE_DATE_EPOCH}" "+%s") / 86400))"
EOF
# END
