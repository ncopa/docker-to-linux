FROM debian:bullseye
LABEL com.iximiuz-project="docker-to-linux"
RUN apt-get -y update
RUN apt-get -y install --no-install-recommends \
  linux-image-$(dpkg --print-architecture) \
  systemd-sysv
RUN echo "root:root" | chpasswd

