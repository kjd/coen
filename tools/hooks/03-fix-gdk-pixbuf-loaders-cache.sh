#!/bin/sh
# Reference https://labs.riseup.net/code/issues/13442
# gdk-pixbuf's loaders.cache is not reproducible
# Using gdk-pixbuf packages from tails that fixed this

set -x # This option causes a bash script to print each command before executing it
set -e # This option cause a bash script to exit immediately when a command fails
set -u # This option causes a bash script to treat unset variables as an error and exit immediately

pkg1="gir1.2-gdkpixbuf-2.0_2.36.5-2.0tails2_amd64.deb"
shapkg1="b80b447e68ccd4e3ad1ef164e3c0fe4176e434a1e909e92733fba3cc81b644b1  -"

pkg2="libgdk-pixbuf2.0-common_2.36.5-2.0tails2_all.deb"
shapkg2="a6ac75aac58b48178cb8aaddde2951f3d6d939df12d30a35b51d6cda89529c80  -"

pkg3="libgdk-pixbuf2.0-0_2.36.5-2.0tails2_amd64.deb"
shapkg3="bd1c3c133b8960825f7e453c7cd5d8254acfa8bf5c1164c89b2ce55da7e04dda  -"

for pkg in "${pkg1} ${shapkg1}" "${pkg2} ${shapkg2}" "${pkg3} ${shapkg3}"
do
	set -- $pkg # parses variable "pkg" $1 name and $2 hash and $3 "-"
	cp $PACKAGE_DIR/$1 $WD/chroot/tmp
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
