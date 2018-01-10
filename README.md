# RRZKSKCLOS
Reproducible Root Zone Key Signing Key Ceremony Live Operating System

The Root Zone Key Signing Key Ceremony Live Operating System is a binary distribution consisting of:

- A custom Debian GNU/Linux Live CD,
- The Key Management Tools https://github.com/iana-org/dnssec-keytools,
- The AEP Keyper PKCS#11 provider, and
- Assorted utilities.

## Reproducible to make The Root Zone Key Signing Key Ceremony Live Operating System more Trustworthy

The idea behind this project is create a **Reproducible** ISO image to provide a verifiable process to increase
confidence in the DNSSEC Key Signing Key (KSK) for the Root Zone.

### What are reproducible builds?

Quoted from https://reproducible-builds.org

> Reproducible builds are a set of software development practices that create a verifiable path from human readable source code to the binary code used by computers.

> Most aspects of software verification are done on source code, as that is what humans can reasonably understand. But most of the time, computers require software to be first built into a long string of numbers to be used. With reproducible builds, multiple parties can redo this process independently and ensure they all get exactly the same result. We can thus gain confidence that a distributed binary code is indeed coming from a given source code.

## Acknowledgments

This project cannot be possible without:
- The Reproducible Builds project: https://reproducible-builds.org/,
- Debian as trust anchor:  https://wiki.debian.org/ReproducibleBuilds,
- Debuerreotype a reproducible, snapshot-based Debian rootfs builder:  https://github.com/debuerreotype/debuerreotype, and
- Tails: https://tails.boum.org/index.en.html

## Requirements for Build a RRZKSKCLOS ISO Image

Building RRZKSKCLOS requires:

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
    nfs-utils && \
sudo systemctl enable libvirtd && \
sudo systemctl enable nfs-server && \
sudo firewall-cmd --permanent --add-service=nfs && \
sudo firewall-cmd --permanent --add-service=rpc-bind && \
sudo firewall-cmd --permanent --add-service=mountd && \
sudo firewall-cmd --reload && \
sudo service libvirtd start && \
sudo service nfs-server start
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

## Build a RRZKSKCLOS ISO image

Execute the following commands to build the RRZKSKCLOS ISO image:

```
git clone https://github.com/andrespavez/RRZKSKCLOS && \
cd RRZKSKCLOS
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

### Fails on “Waiting for domain to get an IP address. . . ”

There is a trick using `qemu` instead of `kvm` to avoid this error. Execute the following command:

```
./init-vagrant.sh --force-qemu
```
> Read the warning message and type **Y** if you want to continue with the build process.

### Fails on Mount NFS

Using TCP instead of UDP for NFSv4 can avoid this error. Execute the following command:

```
./init-vagrant.sh --force-nfs-tcp
```
> Read the warning message and type **Y** if you want to continue with the build process.

## Send me feedback!

### If the build failed

Send me the error that show in your terminal session

### If the build succeeded and the checksums match (i.e. reproduction succeeded).

Congrats for successfully reproducing RRZKSKCLOS!

You can compute the SHA-256 checksum of the resulting ISO image by your self:

```
sha256sum RRZKSKCLOS-0.1.0-20171210.iso
```

And compare it with:

```
dbb24d5c46e6e526088c8223871e9e97fe1c8307b6be6409c22e739bc63948ff  RRZKSKCLOS-0.1.0-20171210.iso
```

Also you can verify the following signed message containing the checksum below:

- keyID = C7D68CF8
- Fingerprint = EC21 1197 7A47 2E31 9B29  2316 755A 6C09 C7D6 8CF8

```
-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA256

dbb24d5c46e6e526088c8223871e9e97fe1c8307b6be6409c22e739bc63948ff  RRZKSKCLOS-0.1.0-20171210.iso
-----BEGIN PGP SIGNATURE-----

iHUEARYIAB0WIQRlSHxnJVvpY6DVpgWPFn76oiPglQUCWlVTmwAKCRCPFn76oiPg
lbLRAP9GDq9qqLNQy3yG3A4tqvVB37R0jSyeEZWmhxiJlU5YoQEArUD3XixuOh5a
A1Ngd21pb1/JC0CUPGp7NhiZm4NN/wc=
=H7HG
-----END PGP SIGNATURE-----
```

- And please send me an email.

### If the build succeeded and the checksums differ (i.e. reproduction failed).

Please help me to improve RRZKSKCLOS. Install `diffoscope` https://diffoscope.org/

#### Debian

```
sudo apt-get install diffoscope
```

#### Fedora

```
sudo dnf install diffoscope
```

And then download the RRZKSKCLOS image from https://drive.google.com/drive/folders/1Q50G_OmFWEEk2OKlXVbEkAc9Gxn-mL9E?usp=sharing and compare it with yours image:

```
diffoscope \
  --text diffoscope.txt \
  --html diffoscope.html \
  path/to/public/RRZKSKCLOS-0.1.0-20171210.iso \
  path/to/your/RRZKSKCLOS-0.1.0-20171210.iso && \
bzip2 diffoscope.*
```
Please send an email attaching one or both files if there are small.
