#!/bin/sh
# Reference https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=864082
# fontconfig generates non-reproducible cache files under
# /var/cache/fontconfig
# Using fontconfig packages from tails that fixed this

set -x # This option causes a bash script to print each command before executing it
set -e # This option cause a bash script to exit immediately when a command fails
set -u # This option causes a bash script to treat unset variables as an error and exit immediately

fontconf="fontconfig-config_2.11.0-6.7.0tails4_all.deb"
FONTCONFSHA256="390fdc4c915aeed379196335e672d6a9af6677e6d675093f8855c85953aae246  -"

libfontconf1="libfontconfig1_2.11.0-6.7.0tails4_amd64.deb"
LIBFONTCONF1SHA256="933adbbead4fd8ced095b5f43fd82b092298aaf95436d8b051b2ee9a4abee917  -"

font="fontconfig_2.11.0-6.7.0tails4_amd64.deb"
FONTSHA256="892a2c0b4f8e4874161165cb253755b3bd695ce238b30c3b8e5447ff269c2740  -"

for pkg in "${fontconf} ${FONTCONFSHA256}" "${libfontconf1} ${LIBFONTCONF1SHA256}" "${font} ${FONTSHA256}"
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
