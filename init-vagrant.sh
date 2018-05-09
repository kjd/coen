#!/bin/bash
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
#
set -x
set -e
set -u

# Confirmation
echo "Warning this can be dangerous. It will use chroot command to remove packages, changes configurations, etc. \
So, if something is going wrong can change from your host system rather than from the Live CD image. \
You will execute it under your own responsibility."
read -p "Are you sure to continue [y/N]? " -n 1 -r
echo    # Move to a new line
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    [[ "$0" = "$BASH_SOURCE" ]] && exit 1 || return 1 # handle exits from shell or function but don't exit interactive shell
fi

# Checking vagrant
command -v vagrant >/dev/null 2>&1 || { echo >&2 "Please install vagrant"; exit 1; }

cat > Vagrantfile << EOF
# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "debian/stretch64"
  config.vm.box_version = "9.1.0"
  config.vm.provider "libvirt"

#  config.vm.synced_folder ".", "/vagrant", nfs: true, nfs_version: 4, nfs_udp: false

  config.vm.provider "libvirt" do |libvirt|
    libvirt.memory = "1024"
#    libvirt.driver = "qemu"
  end

  config.vm.provision "shell", inline: <<-SHELL
    echo "deb http://ftp.us.debian.org/debian/ sid main" >> /etc/apt/sources.list
    apt-get update
    DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends --yes -t stretch\
    liblzo2-2 xorriso debootstrap
    DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends --yes -t sid\
    debuerreotype
    /vagrant/create-iso.sh
  SHELL
end

EOF

usage ()
	{
	echo "Usage:$0 [OPTION]"
	echo "The Vagrantfile for vagrant up"
	echo " -h, --help      Show this message"
	echo " --force-qemu    Force use QEMU instead of KVM"
	echo " --force-nfs-tcp Force use TCP instead of UDP for NFSv4"
	}

# No arguments
if [ "$#" -eq 0 ] ;
  then
    # Init vagrant
    vagrant up
    exit 0
fi

while [ "${1-}" != "" ]
  do
    case $1 in
      -h | --help )
        usage
        exit 1
      ;;
      --force-qemu )
        sed -i '/qemu/s/^#//' Vagrantfile
      ;;
      --force-nfs-tcp )
        sed -i '/nfs_udp/s/^#//' Vagrantfile
      ;;
      * )
        echo "$0: unrecognized option $1"
        echo "Try $0 --help for more information."
		    exit 1
      ;;
    esac
    shift
  done

# Init vagrant
vagrant up
exit 0
# END
