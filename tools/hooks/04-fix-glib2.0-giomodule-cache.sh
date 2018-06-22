#!/bin/sh

set -x
set -e
set -u

# giomodule.cache not reproducible
# Reference https://labs.riseup.net/code/issues/13441
# Usign dpkg from tails

pkg1="libglib2.0-0_2.50.3-2.0tails1_amd64.deb"
shapkg1="c667290a6de8171a4fbe7660d92923bce06d73aac099aa9b28ccb9618862f891  -"

for pkg in "${pkg1} ${shapkg1}"
do
	set -- $pkg # parses variable "pkg" $1 name and $2 hash and $3 "-"
	cp $PACKAGE/$1 $WD/chroot/tmp
	echo "Calculating SHA-256 HASH of the $1"
	hash=$(sha256sum < "$WD/chroot/tmp/$1")
		if [ "$hash" != "$2  $3" ]
		then
			echo "ERROR: SHA-256 hashes mismatched"
			exit 1
		fi
	debuerreotype-chroot $WD/chroot dpkg -i /tmp/$1
	rm -f $WD/chroot/tmp/$1
done

# END
