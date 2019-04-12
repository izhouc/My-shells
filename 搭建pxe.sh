#!/bin/bash
yum -y install dhcp
echo '#
# DHCP Server Configuration file.
#   see /usr/share/doc/dhcp*/dhcpd.conf.example
#   see dhcpd.conf(5) man page
#
# dhcpd.conf

subnet 192.168.4.0 netmask 255.255.255.0 {
  range 192.168.4.10  192.168.4.30;
  option domain-name-servers 8.8.8.8;
  option routers 192.168.4.254;
  default-lease-time 600;
  max-lease-time 7200;
  next-server 192.168.4.77;
  filename "pxelinux.0";
}
' >  /etc/dhcp/dhcpd.conf

yum -y install tftp-server
systemctl restart tftp
systemctl enable tftp

yum -y install syslinux
cp /usr/share/syslinux/pxelinux.0  /var/lib/tftpboot/
mkdir /dvd
echo "/dev/cdrom  /dvd  iso9660  defaults 0  0" >>  /etc/fstab
mount -a
cd  /dvd/isolinux
cp splash.png  vmlinuz  vesamenu.c32  initrd.img  /var/lib/tftpboot/
mkdir  /var/lib/tftpboot/pxelinux.cfg
cp isolinux.cfg  /var/lib/tftpboot/pxelinux.cfg/default
chmod u=rwx /var/lib/tftpboot/pxelinux.cfg/default
echo "default vesamenu.c32
timeout 600

display boot.msg

# Clear the screen when exiting the menu, instead of leaving the menu displayed.
# For vesamenu, this means the graphical background is still displayed without
# the menu itself for as long as the screen remains in graphics mode.
menu clear
menu background splash.png
menu title Red Hat Enterprise Linux 7.4
menu vshift 8
menu rows 18
menu margin 8
#menu hidden
menu helpmsgrow 15
menu tabmsgrow 13

# Border Area
menu color border * #00000000 #00000000 none

# Selected item
menu color sel 0 #ffffffff #00000000 none

# Title bar
menu color title 0 #ff7ba3d0 #00000000 none

# Press [Tab] message
menu color tabmsg 0 #ff3a6496 #00000000 none

# Unselected menu item
menu color unsel 0 #84b8ffff #00000000 none

# Selected hotkey
menu color hotsel 0 #84b8ffff #00000000 none

# Unselected hotkey
menu color hotkey 0 #ffffffff #00000000 none

# Help text
menu color help 0 #ffffffff #00000000 none

# A scrollbar of some type? Not sure.
menu color scrollbar 0 #ffffffff #ff355594 none

# Timeout msg
menu color timeout 0 #ffffffff #00000000 none
menu color timeout_msg 0 #ffffffff #00000000 none

# Command prompt text
menu color cmdmark 0 #84b8ffff #00000000 none
menu color cmdline 0 #ffffffff #00000000 none

# Do not display the actual menu unless the user presses a key. All that is displayed is a timeout message.

menu tabmsg Press Tab for full configuration options on menu items.

menu separator # insert an empty line
menu separator # insert an empty line

label linux
  menu label ^Install Red Hat Enterprise Linux 7.4
  menu default
  kernel vmlinuz
  append initrd=initrd.img ks=http://192.168.4.77/ks.cfg
" >  /var/lib/tftpboot/pxelinux.cfg/default

yum -y install httpd
mkdir  /var/www/html/rhel7
mount /dev/cdrom  /var/www/html/rhel7
systemctl restart httpd
systemctl enable httpd


echo '#platform=x86, AMD64, 或 Intel EM64T
#version=DEVEL
# Install OS instead of upgrade
install
# Keyboard layouts
keyboard "us"
# Root password
rootpw --iscrypted $1$NWFwo3VZ$oudXkhPunlfPQRQByeE9p1
# Use network installation
url --url="http://192.168.4.77/rhel7"
# System language
lang zh_CN
# Firewall configuration
firewall --disabled
# System authorization information
auth  --useshadow  --passalgo=sha512
# Use text mode install
text
firstboot --disable
# SELinux configuration
selinux --disabled

# Network information
network  --bootproto=dhcp --device=eth0
# Reboot after installation
reboot
# System timezone
timezone Asia/Shanghai
# System bootloader configuration
bootloader --location=mbr
# Clear the Master Boot Record
zerombr
# Partition clearing information
clearpart --all --initlabel
# Disk partitioning information
part / --fstype="xfs" --grow --size=1

%post --interpreter=/bin/bash
useradd zhouc
echo 1 | passwd --stdin zhouc


rm -rf /etc/yum.repos.d/*.repo
echo "[development]
name=rh
baseurl=ftp://192.168.4.254/rhel7
enabled=1
gpgcheck=0" > /etc/yum.repos.d/rhel7.repo
%end

%packages
@base

%end' >  /var/www/html/ks.cfg

systemctl restart dhcpd  tftp  httpd  
systemctl enable  dhcpd  tftp  httpd  
