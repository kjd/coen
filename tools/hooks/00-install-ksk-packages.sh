#!/bin/sh
# Installs KSK software and XFCE customisation from Debian packages

set -x # This option causes a bash script to print each command before executing it
set -e # This option cause a bash script to exit immediately when a command fails
set -u # This option causes a bash script to treat unset variables as an error and exit immediately

pkg1="ksk-tools-0.1.0coen_amd64.deb"
shapkg1="93e954744ec11e1d6837a792e26cc93b88f0735f7184337c4e65babca65503ab  -"

pkg2="ksk-xfce-custom-0.1.0coen_amd64.deb"
shapkg2="2080347093bc714b92d2f02e9c19e51ca23804776c2b52958c25630330b25f1d  -"

for pkg in "${pkg1} ${shapkg1}" "${pkg2} ${shapkg2}"
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
