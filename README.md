# auditlinuxsystem

Script for Inventory Configurations of Linux servers (Bacula Bare-Metal Recovery)

Unfortunately, many of the steps one must take before and immediately after a disaster are very operating system dependent. This script need for inventory your system(hardware config and software config) and help of create new bacula backup job. When disaster strikes, you must have a plan, and you must have prepared in advance otherwise the work of recovering your system and your files will be considerably greater.

yum install bacula-client vim parted pciutils yum-plugin-security yum-plugin-verify yum-plugin-changelog lsusb lshw usbutils lsscsi pigz mlocate time glances tuned redhat-lsb-core etckeeper firewalld mailx policycoreutils-python policycoreutils-newrole policycoreutils-restorecond setools-console lsof iotop htop tree mutt

cd /etc && sudo etckeeper init && sudo etckeeper commit "Initial import"
  
Please verify and add(if need) next line to /etc/postfix/main.cf - "relayhost = [xxx.xxx.xxx.xxx]"
systemctl -l restart postfix.service
systemctl -l status postfix.service
