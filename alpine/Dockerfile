FROM alpine:3.15.4
LABEL com.iximiuz-project="docker-to-linux"
RUN apk update
RUN apk add openrc linux-virt busybox-initscripts
RUN echo "root:root" | chpasswd

