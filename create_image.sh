#!/bin/sh

set -e

echo_blue() {
    local font_blue="\033[94m"
    local font_bold="\033[1m"
    local font_end="\033[0m"

    echo -e "\n${font_blue}${font_bold}${1}${font_end}"
}

echo_blue "[Create disk image]"
qemu-img create -f raw /os/${DISTR}.img 1G

LOOPDEVICE=$(losetup -f)
losetup -P ${LOOPDEVICE} /os/${DISTR}.img
trap "echo_blue '[Close ${LOOPDEVICE}]'; losetup -d ${LOOPDEVICE}" EXIT

echo -e "\n[Using ${LOOPDEVICE} loop device]"

echo_blue "[Make partition]"
sfdisk ${LOOPDEVICE} < /os/partition.txt
mdev -s

efipart=${LOOPDEVICE}p1
rootpart=${LOOPDEVICE}p2

echo_blue "\n[Format efi partition with vfat]"
mkfs.vfat -n EFI $efipart
echo_blue "\n[Format root partition with ext4]"
mkfs.ext4 -L ROOTFS $rootpart

echo_blue "[Extract ${DISTR}.tar to partition]"
mkdir -p /os/mnt
mount -t ext4 $rootpart /os/mnt/
tar -C /os/mnt -xf /os/${DISTR}.tar

echo_blue "[Setup grub]"
mkdir -p /os/mnt/boot/efi /os/mnt/boot/grub
cp /os/${DISTR}/grub.cfg /os/mnt/boot/grub/syslinux.cfg
mount -t vfat $efipart /os/mnt/boot/efi

mkdir -p /os/mnt/boot/efi/EFI/boot
grub-mkimage \
	--format=arm64-efi \
	--output=/os/mnt/boot/efi/EFI/boot/bootaa64.efi \
	--compression=xz \
	--prefix="/boot/grub" \
	--config=/os/${DISTR}/grub.cfg \
	all_video disk part_gpt linux normal search search_label efi_gop ext2 gzio

echo_blue "[Unmount]"
umount /os/mnt/boot/efi
umount /os/mnt

echo_blue "[Convert to qcow2]"
qemu-img convert -c /os/${DISTR}.img -O qcow2 /os/${DISTR}.qcow2
