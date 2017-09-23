#!/bin/bash
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
#
set -x
set -e
set -u

DATE=20171011 #`date +%Y%m%d` # Current date or selected date
export SOURCE_DATE_EPOCH="$(date --utc --date="$DATE" +%s)" # defined by reproducible-builds.org.
export SOURCE_DATE_YYYYMMDD="$(date --utc --date="$DATE" +%Y%m%d)"

ROOT_UID=0	# Only users with $UID 0 have root privileges
WD=RRZKSKCLOS-$DATE	# Working directory to create the ISO for Reproducible Root Key Signing Key Ceremony Live Operating System
arch=amd64 # Target architecture
dist=stable # Distribution
mirror=http://ftp.us.debian.org/debian/

# Confirmation
echo "Warning this can be dangerous. It will use chroot command to remove packages, changes configurations, etc. \
So, if something is going wrong can change from your host system rather than from the Live CD image. \
You need to be root and execute under your own responsibility"
read -p "Are you sure to continue [y/N]? " -n 1 -r
echo    # Move to a new line
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    [[ "$0" = "$BASH_SOURCE" ]] && exit 1 || return 1 # handle exits from shell or function but don't exit interactive shell
fi

# Run as root
if [ "$UID" -ne "$ROOT_UID" ]
then
  echo "Must be root to run this script."
  exit 1
fi

# Checking squashfs-tools
command -v mksquashfs >/dev/null 2>&1 || { echo >&2 "Please install (with XZ support) the last squashfs-tools"; exit 1; }

# Checking xorriso
command -v xorriso >/dev/null 2>&1 || { echo >&2 "Please install xorriso"; exit 1; }

# Checking debootstrap
command -v debootstrap >/dev/null 2>&1 || { echo >&2 "Please install debootstrap"; exit 1; }


# Creating a working directory
mkdir $WD

# Setting uo the base Debian environment
debootstrap \
    --arch=$arch \
    --variant=minbase \
    $dist $WD/chroot \
    $mirror

# Chroot to the new Debian environment
cat << EOF | chroot $WD/chroot
echo "RRZKSKCLOS" > /etc/hostname
passwd -d root
apt-get update
apt-get install --no-install-recommends --yes \
    linux-image-amd64 live-boot systemd-sysv \
    syslinux syslinux-common isolinux
apt-get install --no-install-recommends --yes \
    iproute2 ifupdown pciutils usbutils dosfstools syslinux eject exfat-utils \
    vim links2 xpdf cups cups-bsd enscript libbsd-dev tree openssl less iputils-ping \
    xserver-xorg-core xserver-xorg xfce4 xfce4-terminal xfce4-panel lightdm system-config-printer xterm
apt-get --yes --purge autoremove
apt-get --yes clean
EOF

echo "Setting network"
cat > $WD/chroot/etc/hosts << EOF
127.0.0.1       localhost RRZKSKCLOS
192.168.0.2     hsm
EOF

cat > $WD/chroot/etc/network/interfaces.d/kc-network << EOF
auto lo
iface lo inet loopback

auto eth0
iface eth0 inet static
  address 192.168.0.1
  netmask 255.255.255.0
  network 192.168.0.0
  broadcast 192.168.0.255
  gateway 192.168.0.254

auto eth1
iface eth1 inet static
  address 192.168.0.3
  netmask 255.255.255.0
  network 192.168.0.0
  broadcast 192.168.0.255
  gateway 192.168.0.254
EOF

# AEP Software
# Check install -p, --preserve-timestamps
echo "Instaling AEP Software"
install -m 755 -d $WD/chroot/opt/Keyper
install -m 755 -d $WD/chroot/opt/Keyper/bin
install -m 755 -d $WD/chroot/opt/Keyper/PKCS11Provider
install -m 755 -d $WD/chroot/opt/Keyper/docs
install -p -m 555 ./opt/Keyper/bin/*              $WD/chroot/opt/Keyper/bin
install -p -m 444 ./opt/Keyper/PKCS11Provider/*   $WD/chroot/opt/Keyper/PKCS11Provider
install -p -m 444 ./opt/Keyper/docs/*             $WD/chroot/opt/Keyper/docs

# ICANN Software & Scripts
echo "Instaling ICANN Software and Scripts"
install -m 755 -d $WD/chroot/opt/icann
install -m 755 -d $WD/chroot/opt/icann/bin
install -m 755 -d $WD/chroot/opt/icann/dist
install -p -m 555 ./opt/icann/bin/*   $WD/chroot/opt/icann/bin
install -p -m 555 ./opt/icann/dist/*  $WD/chroot/opt/icann/dist

# DNSSEC Configurations Files
echo "Instaling DNSSEC Configurations Files"
install -m 755 -d $WD/chroot/opt/dnssec
install -p -m 444 ./opt/dnssec/*    $WD/chroot/opt/dnssec

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

# HSMFD

# Creating boot directories
mkdir -p $WD/image/live
mkdir -p $WD/image/isolinux

# Compressing the chroot environment into a squashfs
mksquashfs $WD/chroot/ $WD/image/live/filesystem.squashfs -noappend -comp xz

# Setting permissions for squashfs.img
chmod 644 $WD/image/live/filesystem.squashfs

# Coping bootloader
cp -p $WD/chroot/boot/* $WD/image/live/

# Creating the isolinux bootloader
cat > $WD/image/isolinux/isolinux.cfg << EOF
UI menu.c32

prompt 0
menu title RRZKSKCLOS

timeout 1

label RRZKSKCLOS Live 4.9.0-3-amd64
menu label ^RRZKSKCLOS Live 4.9.0-3-amd64
menu default
kernel /live/vmlinuz-4.9.0-3-amd64
append initrd=/live/initrd.img-4.9.0-3-amd64 boot=live locales=en_US.UTF-8 net.ifnames=0 timezone=Etc/UTC live-media=removable nopersistence selinux=0 STATICIP=frommedia modprobe.blacklist=pcspkr

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

## Creating the iso
echo "Creating the iso"
xorriso -outdev $WD.iso -volid $WD \
 -map $WD/image/ / -chmod 0755 / -- -boot_image isolinux dir=/isolinux \
 -boot_image isolinux system_area=$WD/chroot/usr/lib/ISOLINUX/isohdpfx.bin \
 -boot_image isolinux partition_entry=gpt_basdat

## Carefully removing working directory
#rm -rf $WD

# END
