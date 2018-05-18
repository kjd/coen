#!/bin/bash

set -x
set -e
set -u

release=0.2.0 # release number for coen
DATE=20180311 #`date +%Y%m%d` # Selected date for version packages
dist=stretch # Debian Distribution
arch=amd64 # Target architecture
SHASUM="88019425466f940e7b677b160b5b937dc2f4afbe0967331a34b761801801e7a5  -"
export SOURCE_DATE_EPOCH="$(date --utc --date="$DATE" +%s)" # defined by reproducible-builds.org
export WD=/opt/coen-${release}	# Working directory to create the ISO
ISONAME=${WD}-${arch}.iso # Final name of the ISO image
CONF=/vagrant/configs # Configurations Files
TOOL=/vagrant/tools # Tools
HOOKS=/vagrant/tools/hooks # Hooks

# Creating a working directory
mkdir -p $WD

# Setting up the base Debian environment
debuerreotype-init $WD/chroot $dist $DATE --arch=$arch

# Chroot to the new Debian environment
debuerreotype-chroot $WD/chroot passwd -d root
debuerreotype-apt-get $WD/chroot update
debuerreotype-chroot $WD/chroot DEBIAN_FRONTEND=noninteractive apt-get -o Acquire::Check-Valid-Until=false install \
    --no-install-recommends --yes \
    linux-image-amd64 live-boot systemd-sysv \
    syslinux syslinux-common isolinux
debuerreotype-chroot $WD/chroot DEBIAN_FRONTEND=noninteractive apt-get -o Acquire::Check-Valid-Until=false install \
    --no-install-recommends --yes \
    iproute2 ifupdown pciutils usbutils dosfstools eject exfat-utils \
    vim links2 xpdf cups cups-bsd enscript libbsd-dev tree openssl less iputils-ping \
    xserver-xorg-core xserver-xorg xfce4 xfce4-terminal xfce4-panel lightdm system-config-printer \
    xterm gvfs thunar-volman xfce4-power-manager
debuerreotype-apt-get $WD/chroot --yes --purge autoremove
debuerreotype-apt-get $WD/chroot --yes clean

# Applying hooks
for fixes in $HOOKS/*
do
  $fixes
done

echo "Setting network"
echo "coen" > $WD/chroot/etc/hostname

cat > $WD/chroot/etc/hosts << EOF
127.0.0.1       localhost coen
192.168.0.2     hsm
EOF

cat > $WD/chroot/etc/network/interfaces.d/coen-network << EOF
auto lo
iface lo inet loopback

auto eth0
iface eth0 inet static
  address 192.168.0.1
  netmask 255.255.255.0
EOF

# AEP Software
# Check install -p, --preserve-timestamps
echo "Instaling AEP Software"
install -m 755 -d $WD/chroot/opt/Keyper
install -m 755 -d $WD/chroot/opt/Keyper/bin
install -m 755 -d $WD/chroot/opt/Keyper/PKCS11Provider
install -m 755 -d $WD/chroot/opt/Keyper/docs
install -p -m 555 $CONF/Keyper/bin/*              $WD/chroot/opt/Keyper/bin
install -p -m 444 $CONF/Keyper/PKCS11Provider/*   $WD/chroot/opt/Keyper/PKCS11Provider
install -p -m 444 $CONF/Keyper/docs/*             $WD/chroot/opt/Keyper/docs

# ICANN Software & Scripts
echo "Instaling ICANN Software and Scripts"
install -m 755 -d $WD/chroot/opt/icann
install -m 755 -d $WD/chroot/opt/icann/bin
install -m 755 -d $WD/chroot/opt/icann/dist
install -p -m 555 $CONF/icann/bin/*   $WD/chroot/opt/icann/bin
install -p -m 555 $CONF/icann/dist/*  $WD/chroot/opt/icann/dist

# DNSSEC Configurations Files
echo "Instaling DNSSEC Configurations Files"
install -m 755 -d $WD/chroot/opt/dnssec
install -p -m 444 $CONF/dnssec/*    $WD/chroot/opt/dnssec

# Profile in .bashrc to work with xfce terminal
echo "export PATH=:/opt/icann/bin:/opt/Keyper/bin:\$PATH" >> $WD/chroot/root/.bashrc
# ls with color
sed -i -r -e '9s/^#//' \
          -e '10s/^#//' \
          -e '11s/^#//' \
    $WD/chroot/root/.bashrc

# Configure autologin
for NUMBER in $(seq 1 6)
		do
      mkdir -p $WD/chroot/etc/systemd/system/getty@tty${NUMBER}.service.d

cat > $WD/chroot/etc/systemd/system/getty@tty${NUMBER}.service.d/live-config_autologin.conf << EOF
[Service]
Type=idle
ExecStart=
ExecStart=-/sbin/agetty --autologin root --noclear %I \$TERM
TTYVTDisallocate=no
EOF
done

# XFCE
echo "XFCE root auto login"
sed -i -r -e "s|^#.*autologin-user=.*\$|autologin-user=root|" \
          -e "s|^#.*autologin-user-timeout=.*\$|autologin-user-timeout=0|" \
    $WD/chroot/etc/lightdm/lightdm.conf

sed -i --regexp-extended \
    '11s/.*/#&/' \
    $WD/chroot/etc/pam.d/lightdm-autologin

# lastlog with autologin doesn't make sense
sed -i '/^[^#].*pam_lastlog\.so/s/^/# /' $WD/chroot/etc/pam.d/login

echo "Custom XFCE"
# xfce panel, unlock, power off, desktop configuration
mkdir -p $WD/chroot/root/.config/xfce4/xfconf/xfce-perchannel-xml
install -p -m 644 $CONF/xfce-perchannel-xml/*  $WD/chroot/root/.config/xfce4/xfconf/xfce-perchannel-xml
# Terminal with 2 tabs
install -p -m 644 $CONF/xfce4-terminal.desktop $WD/chroot/etc/xdg/autostart/
# just in case, anyway it is not installed
rm -f $WD/chroot/etc/xdg/autostart/xscreensaver.desktop

# Managing HSMFD, HSMFD1 and KSRFD
cat > $WD/chroot/etc/udev/rules.d/99-udisks2.rules << EOF
# UDISKS_FILESYSTEM_SHARED
# ==1: mount filesystem to a shared directory (/media/VolumeName)
# ==0: mount filesystem to a private directory (/run/media/USER/VolumeName)
# See udisks(8)
ENV{ID_FS_USAGE}=="filesystem|other|crypto", ENV{UDISKS_FILESYSTEM_SHARED}="1"
EOF

# Creating boot directories
mkdir -p $WD/image/live
mkdir -p $WD/image/isolinux

# Fixing dates to SOURCE_DATE_EPOCH
debuerreotype-fixup $WD/chroot

# Compressing the chroot environment into a squashfs
$TOOL/mksquashfs $WD/chroot/ $WD/image/live/filesystem.squashfs -ef $TOOL/mksquashfs-excludes -noappend -comp xz

# Setting permissions for squashfs.img
chmod 644 $WD/image/live/filesystem.squashfs

# Coping bootloader
cp -p $WD/chroot/boot/vmlinuz-* $WD/image/live/vmlinuz
cp -p $WD/chroot/boot/initrd.img-* $WD/image/live/initrd.img

# Creating the isolinux bootloader
cat > $WD/image/isolinux/isolinux.cfg << EOF
UI menu.c32

prompt 0
menu title coen-${release}

timeout 1

label coen-${release} Live amd64
menu label ^coen-${release} amd64
menu default
kernel /live/vmlinuz
append initrd=/live/initrd.img boot=live locales=en_US.UTF-8 keymap=us language=us net.ifnames=0 timezone=Etc/UTC live-media=removable nopersistence selinux=0 STATICIP=frommedia modprobe.blacklist=pcspkr,hci_uart,btintel,btqca,btbcm,bluetooth,snd_hda_intel,snd_hda_codec_realtek,snd_soc_skl,snd_soc_skl_ipc,snd_soc_sst_ipc,snd_soc_sst_dsp,snd_hda_ext_core,snd_soc_sst_match,snd_soc_core,snd_compress,snd_hda_core,snd_pcm,snd_timer,snd,soundcore

EOF

# Files for ISO booting
cp -p $WD/chroot/usr/lib/ISOLINUX/isolinux.bin $WD/image/isolinux/
cp -p $WD/chroot/usr/lib/ISOLINUX/isohdpfx.bin $WD/image/isolinux/
cp -p $WD/chroot/usr/lib/syslinux/modules/bios/menu.c32 $WD/image/isolinux/
cp -p $WD/chroot/usr/lib/syslinux/modules/bios/hdt.c32 $WD/image/isolinux/
cp -p $WD/chroot/usr/lib/syslinux/modules/bios/ldlinux.c32 $WD/image/isolinux/
cp -p $WD/chroot/usr/lib/syslinux/modules/bios/libutil.c32 $WD/image/isolinux/
cp -p $WD/chroot/usr/lib/syslinux/modules/bios/libmenu.c32 $WD/image/isolinux/
cp -p $WD/chroot/usr/lib/syslinux/modules/bios/libcom32.c32 $WD/image/isolinux/
cp -p $WD/chroot/usr/lib/syslinux/modules/bios/libgpl.c32 $WD/image/isolinux/
cp -p $WD/chroot/usr/share/misc/pci.ids $WD/image/isolinux/

# Fixing main folder timestamps
find "$WD/image" \
	-newermt "@$SOURCE_DATE_EPOCH" \
	-exec touch --no-dereference --date="@$SOURCE_DATE_EPOCH" '{}' +

## Creating the iso
echo "Creating the iso"
xorriso -outdev $ISONAME -volid COEN \
 -map $WD/image/ / -chmod 0755 / -- -boot_image isolinux dir=/isolinux \
 -boot_image isolinux system_area=$WD/chroot/usr/lib/ISOLINUX/isohdpfx.bin \
 -boot_image isolinux partition_entry=gpt_basdat

## Coping the iso to the shared folder
cp $ISONAME /vagrant/

echo "Calculating SHA-256 HASH of the $ISONAME"
newhash=$(sha256sum < "${ISONAME}")
  if [ "$newhash" != "$SHASUM" ]
    then
      echo "ERROR: SHA-256 hashes mismatched reproduction failed :("
      echo "Please send us an email."
  else
      echo "Congrats for successfully reproducing coen-${release} ;)"
      echo "You can compute the SHA-256 checksum of the resulting ISO image by yourself."
      echo "And please send us an email."
  fi

# END
