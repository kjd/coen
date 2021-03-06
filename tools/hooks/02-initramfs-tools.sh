#!/bin/sh
# Reference https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=845034
# mkinitramfs generates not reproducible ramdisk images
# Using initramfs-tools packages from tails that fixed this

set -x # This option causes a bash script to print each command before executing it
set -e # This option cause a bash script to exit immediately when a command fails
set -u # This option causes a bash script to treat unset variables as an error and exit immediately

initcore="initramfs-tools-core_0.130.0tails1_all.deb"
INITTOOLCORESHA256="db1d9dcd6d0c9587136c5a65419ee9eaa7a8a20c163dd2718cd826056a893819  -"

init="initramfs-tools_0.130.0tails1_all.deb"
INITTOOLSHA256="36c39407b505015a80e666726018edad37211d594b862238475d59d3de4e0da9  -"

for pkg in "${initcore} ${INITTOOLCORESHA256}" "${init} ${INITTOOLSHA256}"
do
	set -- $pkg # parses variable "pkg" $1 name and $2 hash and $3 "-"
	cp $PACKAGE_DIR/$1 $WD/chroot/tmp/
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
