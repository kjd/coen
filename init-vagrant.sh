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
Also, RRZKSKCLOS requires the KVM virtual machine hypervisor to be available, a minimun of 1 GB of free RAM and a maximun of \
5 GB of free storage.
You will execute it under your own responsibility"
read -p "Are you sure to continue [y/N]? " -n 1 -r
echo    # Move to a new line
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    [[ "$0" = "$BASH_SOURCE" ]] && exit 1 || return 1 # handle exits from shell or function but don't exit interactive shell
fi

# Checking vagrant
command -v vagrant >/dev/null 2>&1 || { echo >&2 "Please install vagrant"; exit 1; }

vagrant up

# END
