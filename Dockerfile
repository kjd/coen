FROM debian:9.4-slim

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && apt-get install --no-install-recommends --yes \ 
    liblzo2-2 xorriso debootstrap \
    locales && \
    sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/g' /etc/locale.gen && \
    locale-gen en_US.UTF-8

ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

RUN dpkg-reconfigure locales 

COPY create-iso.sh .
COPY variables.sh .
COPY SHA256SUMS .
COPY tools/ /tools/

RUN sha256sum -c SHA256SUMS

RUN dpkg -i /tools/squashfs-tools_4.3-3.0tails4_amd64.deb && \ 
    dpkg -i /tools/debuerreotype_0.7-1_all.deb
    
CMD ["/create-iso.sh"]
