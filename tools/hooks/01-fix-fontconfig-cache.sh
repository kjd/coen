#!/bin/sh

set -x
set -e
set -u

# Reference https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=864082
# fontconfig generates non-reproducible cache files under
# /var/cache/fontconfig.

# Usign fontconfig from tails

FONTSHA256="892a2c0b4f8e4874161165cb253755b3bd695ce238b30c3b8e5447ff269c2740  -"

wget --directory-prefix=$WD/chroot/tmp/  https://deb.tails.boum.org/pool/main/f/fontconfig/fontconfig_2.11.0-6.7.0tails4_amd64.deb

echo "Calculating SHA-256 HASH of the fontconfig"
fonthash=$(sha256sum < "$WD/chroot/tmp/fontconfig_2.11.0-6.7.0tails4_amd64.deb")
echo "SHA-256 HASH: $fonthash"
echo "FONTCON HASH: $FONTSHA256"
if [ "$fonthash" != "$FONTSHA256" ]
then
	echo "ERROR: SHA-256 hashes mismatched, try to download again the fontconfig_2.11.0-6.7.0tails4_amd64.deb"
	exit 1
else
	echo "SHA-256 HASH of the fontconfig_2.11.0-6.7.0tails4_amd64.deb is OK"
fi

debuerreotype-chroot $WD/chroot dpkg -i /tmp/fontconfig_2.11.0-6.7.0tails4_amd64.deb

rm -f $WD/chroot/tmp/fontconfig_2.11.0-6.7.0tails4_amd64.deb

# END
