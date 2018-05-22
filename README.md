# Ceremony Operating ENvironment (COEN)

COEN is a live operating system consisting of:

- A custom Debian GNU/Linux Live CD,
- The Key Management Tools https://github.com/iana-org/dnssec-keytools,
- The AEP Keyper PKCS#11 provider, and
- Assorted utilities.

## Reproducible ISO to make The Root Zone DNSSEC Key Signing Key Ceremony System more Trustworthy

This **Reproducible** ISO image provide a verifiable process to obtain the same hash every time at build the ISO to increase the confidence in the DNSSEC Key Signing Key (KSK) for the Root Zone.

### What are reproducible builds?

Quoted from https://reproducible-builds.org

> Reproducible builds are a set of software development practices that create a verifiable path from human readable source code to the binary code used by computers.

> Most aspects of software verification are done on source code, as that is what humans can reasonably understand. But most of the time, computers require software to be first built into a long string of numbers to be used. With reproducible builds, multiple parties can redo this process independently and ensure they all get exactly the same result. We can thus gain confidence that a distributed binary code is indeed coming from a given source code.

## Acknowledgments

This project cannot be possible without:
- The Reproducible Builds project: https://reproducible-builds.org/,
- Debian as trust anchor:  https://wiki.debian.org/ReproducibleBuilds,
- Debuerreotype a reproducible, snapshot-based Debian rootfs builder:  https://github.com/debuerreotype/debuerreotype, and
- Tails or The Amnesic Incognito Live System: https://tails.boum.org/index.en.html

## Requirements for Build the ISO Image

Building the ISO image requires:

- The KVM virtual machine hypervisor. If is not available the build process will be slower.

- A minimum of 1 GB of free RAM,

- At least 5 GB of free storage,

## Setup the build environment

The build environment requires `qemu`,  `libvirt`,  `vagrant` and `vagrant-libvirt`. You need to make sure your have all the build dependencies installed and it will depends or your GNU/Linux distro. Below and overview based on Debian and Fedora distros.

###  Debian Stretch and Buster/Sid

Install the following dependencies:

```
sudo apt-get update && \
sudo apt-get install \
    git \
    libvirt-daemon-system \
    dnsmasq-base \
    ebtables \
    qemu-system-x86 \
    qemu-utils \
    nfs-kernel-server \
    vagrant \
    vagrant-libvirt && \
sudo systemctl restart libvirtd
```

#### Building as a non-root user

Skip this section if you intend to build as root.

- Make sure that the user can run command as root with sudo.

- Add the user to the relevant groups:

  ```
  for group in kvm libvirt libvirt-qemu; \
  do sudo adduser "$(whoami)" "$group"; \
  done && \
  newgrp
  ```

### Fedora 25 and Up

Install the following dependencies:

```
sudo dnf install \
    git \
    vagrant-libvirt \
    nfs-utils \
    qemu-system-x86 \
    libvirt-client && \
sudo systemctl enable libvirtd && \
sudo systemctl enable nfs-server && \
sudo firewall-cmd --permanent --add-service=nfs && \
sudo firewall-cmd --permanent --add-service=rpc-bind && \
sudo firewall-cmd --permanent --add-service=mountd && \
sudo firewall-cmd --reload && \
sudo systemctl start libvirtd  && \
sudo systemctl start nfs-server
```

#### Building as a non-root user

Skip this section if you intend to build as root.

- Make sure that the user can run command as root with sudo.

- Add the user to the relevant groups:

  ```
   sudo gpasswd -a ${USER} libvirt && \
   newgrp libvirt && \
   sudo getent group vagrant >/dev/null || sudo groupadd -r vagrant && \
   sudo gpasswd -a ${USER} vagrant && \
   newgrp vagrant
   ```

## Build the ISO image

Execute the following commands to build the ISO image:

```
git clone https://github.com/andrespavez/coen && \
cd coen
```

### Building with KVM

Skip this section if you intend to build without KVM.

Execute the following commands:

```
./init-vagrant.sh
```
> Read the warning message and type **Y** if you want to continue with the build process.

### Building without KVM

Execute the following command:

```
./init-vagrant.sh --force-qemu
```
> Read the warning message and type **Y** if you want to continue with the build process.

## Troubleshooting

### Fails on "Waiting for domain to get an IP address..."

There is a trick using `qemu` instead of `kvm` to avoid this error. Execute the following command:

```
vagrant destroy && \
./init-vagrant.sh --force-qemu
```

### Fails on "mount.nfs: requested NFS version or transport protocol is not supported..." or "mount.nfs: an incorrect mount option was specified..."

Using TCP instead of UDP for NFSv4 can avoid this error. Execute the following command:

```
vagrant destroy && \
./init-vagrant.sh --force-nfs-tcp
```

### Fails on "mesg: ttyname failed: Inappropriate ioctl for device..."

Probably you are using an old `vagrant` version. Try to execute the commands with `sudo` even with the root user.

### Had an Error and Wants to Try Again...

If you have an unexpected error and you want to try again:
Execute first `vagrant destroy` then `./init-vagrant.sh`

## Send us feedback!

### If the build failed

Please send us the error that show in your terminal session or create an issue.

### If the build succeeded and the checksums match (i.e. reproduction succeeded).

Congrats for successfully reproducing the ISO!

You can compute the SHA-256 checksum of the resulting ISO image by yourself:

```
sha256sum coen-0.2.0-amd64.iso
```

And compare it with:

```
d5964222d18e651447e1595a541506f39dccedd27e1d379998de0efec5ee027a  coen-0.2.0-amd64.iso
```

Also you can verify the following signed message containing the checksum below:

- keyID = C7D68CF8
- Fingerprint = EC21 1197 7A47 2E31 9B29  2316 755A 6C09 C7D6 8CF8

```
-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA256

d5964222d18e651447e1595a541506f39dccedd27e1d379998de0efec5ee027a  coen-0.2.0-amd64.iso
-----BEGIN PGP SIGNATURE-----

iHUEARYIAB0WIQRlSHxnJVvpY6DVpgWPFn76oiPglQUCWwMv0wAKCRCPFn76oiPg
lWAaAP9OIwNRiObIh05hSvWwdoEKK+zcXAPiLTIZFNmd5DDB6wD+Or1qgJWgL17+
IAeCHm4yl280x/RYJ5T4f1SXT2n4yAQ=
=JDXa
-----END PGP SIGNATURE-----
```

- And please send us an email.

### If the build succeeded and the checksums differ (i.e. reproduction failed).

Please help us to improve it. Install `diffoscope` https://diffoscope.org/

#### Debian

```
sudo apt-get install diffoscope
```

#### Fedora

```
sudo dnf install diffoscope
```

And then download the image from
https://drive.google.com/drive/folders/1YZZ4QVFRa8-V3lW-0s_UHnhhTguM2kH3?usp=sharing
 and compare it with yours image:

```
diffoscope \
  --text diffoscope.txt \
  --html diffoscope.html \
  path/to/public/coen-0.2.0-amd64.iso \
  path/to/your/coen-0.2.0-amd64.iso && \
bzip2 diffoscope.*
```
Please send us an email attaching one or both files if there are small or create an issue.
