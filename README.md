# Ceremony Operating ENvironment (COEN)

COEN is a live operating system consisting of:

- A custom Debian GNU/Linux Live CD
- The Key Management Tools https://github.com/iana-org/dnssec-keytools
- The AEP Keyper PKCS#11 provider
- Assorted utilities.

## Reproducible ISO image to make The Root Zone DNSSEC Key Signing Key Ceremony System more Trustworthy

This **Reproducible** ISO image provide a verifiable process to obtain the same
hash every time at build the ISO image to increase the confidence in the DNSSEC Key
Signing Key (KSK) for the Root Zone.

### What are reproducible builds?

Quoted from https://reproducible-builds.org

> Reproducible builds are a set of software development practices that create a
verifiable path from human readable source code to the binary code used by
computers.
>
> Most aspects of software verification are done on source code, as that is what
humans can reasonably understand. But most of the time, computers require
software to be first built into a long string of numbers to be used. With
reproducible builds, multiple parties can redo this process independently and
ensure they all get exactly the same result. We can thus gain confidence that a
distributed binary code is indeed coming from a given source code.

## Acknowledgments

This project cannot be possible without:
- The Reproducible Builds project: https://reproducible-builds.org/
- Debian as trust anchor:  https://wiki.debian.org/ReproducibleBuilds
- Debuerreotype a reproducible, snapshot-based Debian rootfs builder:  
https://github.com/debuerreotype/debuerreotype
- Tails or The Amnesic Incognito Live System:
https://tails.boum.org/index.en.html

## Requirements for building the ISO image

Building the ISO image requires:

- Docker https://www.docker.com/
> The recommended Docker version is 18.03.

- Disabling SELinux
> SELinux must be completely disabled rather than with **permissive mode** since
the behave is differently.

### Disabling SELinux

If you are running a Red Hat based distribution, including RHEL, CentOS and
Fedora, you will probably have the SELinux security module installed.

To check your SELinux mode, run `sestatus` and check the output.

If you see **enforcing** or **permissive** on *"Current mode"*, SELinux is
enabled and enforcing rules or is enable and log rather than enforce errors.

> **Warning** before proceeding with this. Disabling SELinux also disables the
generation of file contexts so an entire system relabeling is needed afterwards.

To disable SELinux:

- Edit `/etc/sysconfig/selinux` or `/etc/selinux/config` depending of your distro
- Set the `SELINUX` parameter to `disabled`
- For the changes to take effect, you need to **reboot** the machine, since
SELinux is running within the kernel
- Check the status of SELinux using `sestatus` command

## Building the ISO image

Execute the following commands to build the ISO image:

```
git clone https://github.com/andrespavez/coen && \
cd coen && \
make all
```
* If you have a error executing `make all` as a non-root user, try to
execute `sudo make all`.

> This will build a docker image with the proper environment to build the
ISO. Then will run a container executing a bash script to build the ISO and
if the build succeeded it will copy the resulting ISO into the host directory.
>
> You can execute `make` command to see more options.

## Send us some feedback

### If the build failed

Please send us the error that is displayed in your terminal window.

### If the build succeeded and the checksums match (i.e. reproduction succeeded).

Congrats for successfully reproducing the ISO image!

You can compute the SHA-256 checksum of the resulting ISO image by yourself:

```
sha256sum coen-0.3.0-amd64.iso
```
or
```
shasum -a 256 coen-0.3.0-amd64.iso
```

Then, comparing it with the following checksum:

```
52ab766f63016081057cd2c856f724f77d71f9e424193fe56e6a52fcb4271a9e  coen-0.3.0-amd64.iso
```

Also, you can verify the following signed message containing the checksum below:

- keyID = C7D68CF8
- Fingerprint = EC21 1197 7A47 2E31 9B29  2316 755A 6C09 C7D6 8CF8

```
-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA256

52ab766f63016081057cd2c856f724f77d71f9e424193fe56e6a52fcb4271a9e  coen-0.3.0-amd64.iso
-----BEGIN PGP SIGNATURE-----

iHUEARYIAB0WIQRlSHxnJVvpY6DVpgWPFn76oiPglQUCWyrCMgAKCRCPFn76oiPg
lUYMAP4t8rMaZRRj0FcWjsfNUM+AXS7whkSnafNmHdGyAcl/EAD/QGq+8O66bXxt
qOpJ8WEcVitR1hj/xHzwg/MZJ+NkLAc=
=z4iK
-----END PGP SIGNATURE-----
```

- And please send us an email.

### If the build succeeded and the checksums differ (i.e. reproduction failed).

Please help us to improve it. Install `diffoscope` https://diffoscope.org/

Then, download the image from
https://github.com/andrespavez/coen/releases/tag/v0.3.0-20180311
and compare it with your image executing the following command:

```
diffoscope \
  --text diffoscope.txt \
  --html diffoscope.html \
  path/to/public/coen-0.3.0-amd64.iso \
  path/to/your/coen-0.3.0-amd64.iso && \
bzip2 diffoscope.*
```
Please send us an email attaching one or both files.
