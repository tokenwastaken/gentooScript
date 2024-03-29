#!/bin/bash

echo '###Creating Partitions...'
parted /dev/sda << END
mklabel gpt
unit mib
mkpart primary 1 3
name 1 grub
set 1 bios_grub on
mkpart primary 3 131
name 2 boot
set 2 boot on
mkpart primary 131 643
name 3 swap
mkpart primary 643 -1
name 4 rootfs
quit
;
END

echo '###Creating filesystems...###'
mkfs.ext2 /dev/sda2
mkfs.ext4 /dev/sda4

echo '###Mounting partitions...'

mount /dev/sda4 /mnt/gentoo
mkswap /dev/sda3
swapon /dev/sda3
chmod 1777 /var/tmp

echo '###Stage3...'
cd /mnt/gentoo 
sleep 1s
wget http://distfiles.gentoo.org/releases/amd64/autobuilds/20190814T214502Z/stage3-amd64-20190814T214502Z.tar.xz
sleep 2s
echo '### Extracting Tarball...'
cd /mnt/gentoo
tar xpvf stage3-*.tar.xz --xattrs-include='*.*' --numeric-owner
sleep 5s
cd /mnt/gentoo
sleep 2s
echo MAKEOPTS='"-j4"' >> etc/portage/make.conf #change the '4' depending on how many processors you are using.
sleep 2s

cp --dereference /etc/resolv.conf /mnt/gentoo/etc/
sleep 2s
echo '### Mounting necessities for chrooting...'

mount --types proc /proc /mnt/gentoo/proc
sleep 2s
mount --rbind /sys /mnt/gentoo/sys
sleep 2s
mount --make-rslave /mnt/gentoo/sys
sleep 2s
mount --rbind /dev /mnt/gentoo/dev
sleep 2s
mount --make-rslave /mnt/gentoo/dev
sleep 2s
echo '### Chrooting into the new environment...'
chroot /mnt/gentoo /bin/bash << END
sleep 2s
source /etc/profile
sleep 1s
#!/bin/bash
sleep 2s 
export PS1="(chroot) ${PS1}"
sleep 2s
mount /dev/sda2 /boot
sleep 2s
emerge-webrsync
eselect profile set 1
sleep 3s
echo '###Emerging new world...'
emerge --verbose --update --deep --newuse @world
sleep 3s
echo "###Setting timezone..."
echo "Europe/Istanbul" > /etc/timezone #change this depending on your time zone
sleep 1s
emerge --config sys-libs/timezone-data
sleep 1s
echo '###Updating environment...'
env-update && source /etc/profile && export PS1="(chroot) ${PS1}"
sleep 3s
echo '###Emerging kernel...'
emerge sys-kernel/gentoo-sources
ls -l /usr/src/linux
echo '### emerging genkernel...'
 echo "sys-apps/util-linux static-libs" >> /etc/portage/package.use/genkernel
 sleep 1s
 
 echo "*/*   *" >> /etc/portage/package.license

emerge --autounmask-write y sys-kernel/genkernel


sleep 2s
echo /dev/sda2   /boot        ext2    defaults,noatime     0 2 >> /etc/fstab
echo /dev/sda3   none         swap    sw                   0 0 >> /etc/fstab
echo /dev/sda4   /            ext4    noatime              0 1 >> /etc/fstab
echo /dev/cdrom  /mnt/cdrom   auto    noauto,user          0 0 >> /etc/fstab
echo '### Running genkernel...'
sleep 1s 
genkernel all

echo '### Setting hostname...'
echo hostname="isken" > /etc/conf.d/hostname #your own hostname
sleep 1s
sed 's/127.0.0.1/127.0.0.1       isken isken/' /etc/hosts  # this adds your hostname for the loopback IP.
sleep 1s
sed -i 's/\\O//g' /etc/issue
sleep 1s
echo "root:asdfg123" | chpasswd #your own password

echo '###Emerging system logger...'
emerge app-admin/sysklogd
rc-update add sysklogd default

echo '###emerging DHCP...'
emerge  net-misc/dhcpcd

echo '###Installing GRUB2...'
emerge --verbose sys-boot/grub:2
grub-install /dev/sda
grub-mkconfig -o /boot/grub/grub.cfg
exit
END
cd

echo '###Unmounting root FS...'
umount -l /mnt/gentoo/dev{/shm,/pts,}
umount -R /mnt/gentoo
reboot
