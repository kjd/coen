#!/bin/sh
# Reference https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=872729
# GTK immodules.cache it not reproducible
# Using gtk packages from tails that fixed this

set -x # This option causes a bash script to print each command before executing it.
set -e # This option cause a bash script to exit immediately when a command fails.
set -u # This option causes a bash script to treat unset variables as an error and exit immediately.

pkg1="libgtk2.0-common_2.24.31-2.0tails1_all.deb"
shapkg1="0862890d70bafeb6b4a7a1c1da05c90569e0147522d6526fad6d146d6335b79f  -"

pkg2="libgtk2.0-0_2.24.31-2.0tails1_amd64.deb"
shapkg2="a0ae2652c5ca8461752f17ab22aa385c588481351b7b4aeb199a3d23d6479c34  -"

pkg3="gir1.2-gtk-3.0_3.22.11-1.0tails1_amd64.deb"
shapkg3="01db265c90f351367c73cd7ecedeca2f490374579320c5240feecdc70040917e  -"

pkg4="gtk-update-icon-cache_3.22.11-1.0tails1_amd64.deb"
shapkg4="4e49e6161a93424700ced09d0225574d3f6dd406ba9f9e14c36a50e870faab16  -"

pkg5="libgtk-3-common_3.22.11-1.0tails1_all.deb"
shapkg5="605e3c77857d9c55932c7f497f56c70d46af65af59600e5507f42aea3832a848  -"

pkg6="libgtk-3-0_3.22.11-1.0tails1_amd64.deb"
shapkg6="a8946b779ccf305da8dadefa9d7d9402ccfe756246dd70a251e4375076a83648  -"

for pkg in "${pkg1} ${shapkg1}" "${pkg2} ${shapkg2}" "${pkg3} ${shapkg3}" "${pkg4} ${shapkg4}" "${pkg5} ${shapkg5}" "${pkg6} ${shapkg6}"
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
