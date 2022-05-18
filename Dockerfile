FROM alpine:3.15
LABEL com.iximiuz-project="docker-to-linux"
RUN apk add --no-cache grub-efi sfdisk qemu-img e2fsprogs dosfstools

