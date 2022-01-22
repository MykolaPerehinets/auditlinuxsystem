#!/bin/bash
## This program is free software: you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation, either version 3 of the License, or
## (at your option) any later version.
##
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this file. If not, see <http://www.gnu.org/licenses/>.
##
#
# Script installation:
#echo "cd /etc/bacula/scripts && git clone https://github.com/MykolaPerehinets/auditlinuxsystem.git"
#
# Script function:
# Audit and Inventory All Configurations files/Services on Linux servers/hosts (for Bacula Bare-Metal Recovery)
#
# Script requirements 1:
#yum update && yum install bacula-client vim parted pciutils yum-plugin-security yum-plugin-verify yum-plugin-changelog lsusb lshw usbutils lsscsi pigz mlocate time glances tuned redhat-lsb-core etckeeper firewalld mailx policycoreutils-python policycoreutils-newrole policycoreutils-restorecond setools-console lsof iotop htop tree mutt psacct hdparm 
#
# Script requirements 2:
# for initial setup the etckeeper, please run next command from root user
#cd /etc
#sudo etckeeper init
#sudo etckeeper commit "Initial import"
#git config --global user.name "root"
#git config --global user.email root@localhost.localdomain
#
# Additional requirements and enhancement:
# for initial setup the bacula scripts, please run next command from root user
#cd /etc/bacula/scripts
#setenforce 0
#tail -fn 0 /var/log/audit/audit.log | grep bacula > /etc/bacula/bacula-audit.log
#
# * (run a simple backup job that has a pre-script)
#
#chcon system_u:object_r:bacula_exec_t:s0 /etc/bacula/scripts
#semanage fcontext -a -t bacula_exec_t "/etc/bacula/scripts(/.*)?"
#restorecon -R -v /etc/bacula/scripts
#        restorecon reset /etc/bacula/scripts/audit_linux_system.sh context unconfined_u:object_r:bacula_etc_t:s0->unconfined_u:object_r:bacula_exec_t:s0
#        restorecon reset /etc/bacula/scripts/make_dumpall_pgsql.sh context unconfined_u:object_r:bacula_etc_t:s0->unconfined_u:object_r:bacula_exec_t:s0
#        restorecon reset /etc/bacula/scripts/verify_dumpall_pgsql.sh context unconfined_u:object_r:bacula_etc_t:s0->unconfined_u:object_r:bacula_exec_t:s0
#        restorecon reset /etc/bacula/scripts/delete_dumpall_pgsql.sh context unconfined_u:object_r:bacula_etc_t:s0->unconfined_u:object_r:bacula_exec_t:s0
#        restorecon reset /etc/bacula/scripts/recovery_dumpall_pgsql.sh context unconfined_u:object_r:bacula_etc_t:s0->unconfined_u:object_r:bacula_exec_t:s0
#ls -lZ /etc/bacula/scripts
#cd /etc/bacula
#cat /etc/bacula/bacula-audit.log | audit2allow -M bacula_policy
#audit2allow -a
#audit2allow -a -M bacula_policy
# ...
# TEST REVIEW: bacula_policy.te
# INSTALL POLISY:
#semodule -i bacula_policy.pp
# TEST: run another backup job, ensure you get no more AVC DENIED messages in /var/log/audit/audit.log
# ...
# TEST REVIEW: bacula_policy.te
# INSTALL POLISY:
#semodule -i bacula_policy.pp
# TEST: run another backup job, ensure you get no more AVC DENIED messages in /var/log/audit/audit.log
# ...
# TEST REVIEW: bacula_policy.te
# INSTALL POLISY:
#semodule -i bacula_policy.pp
# TEST: run another backup job, ensure you get no more AVC DENIED messages in /var/log/audit/audit.log
# ...
# DONE
#setenforce 1
#
#
#
# Script Submitted and Deployment in Production environments by:
# Mykola Perehinets (mperehin)
# Tel: +380 67 772 6910
# Mailto: mykola.perehinets@gmail.com
#
#######################################################################################################################
# Script modified date
Version=22012022
#
#######################################################################################################################
# Exit code status
ERR=0
#
# Basic Script Configuration, deploy needed parameters, variables, mail, etc.
PATH=/sbin:/bin:/usr/sbin:/usr/bin:/usr/local/sbin:/usr/local/bin
#
# DevOps MailGroup
#ADMIN="root@localhost.localdomain"
ADMIN="BaculaBackupOperators@localhost.localdomain"
#
#HOSTNAME=`hostname -s`
HOSTNAME=`hostname`
#
DATE=$(date +%Y-%m-%d_%H:%M)
DATE_START=$(date +%Y-%m-%d_%H:%M)
#
# Stored inventory logs files in this folder
#auditlogdir=/root
#auditlogdir=/var/log
auditlogdir=/etc/bacula/scripts
#auditlogdirR=/OUTPUT
#auditlogdirR=/RESTORE
auditlogdirR=/RECOVERY
#
#######################################################################################################################
# Verifying all needed folders/directories
if [[ ! -e $auditlogdir ]]; then
    mkdir -p $auditlogdir
elif [[ ! -d $auditlogdir ]]; then
    echo "ERROR: $auditlogdir already exists but is not a directory... Please fix..." 1>&2
fi
#
if [[ ! -e $auditlogdirR ]]; then
    mkdir -p $auditlogdirR
elif [[ ! -d $auditlogdirR ]]; then
    echo "ERROR: $auditlogdirR already exists but is not a directory... Please fix..." 1>&2
fi
#
#######################################################################################################################
# Run script
cd $auditlogdir
echo "WARNING: Please verify Script Version on your server HOST: $HOSTNAME"
echo "OK... Audit your system has been STARTING... Script Version in this server #$Version... "
echo "####################################################################################"
echo "OK... Audit your system has been starting at $DATE_START... Script Version in this server #$Version..." > $auditlogdir/server_inventory_$HOSTNAME.log
echo "#################################################################################################################" >> $auditlogdir/server_inventory_$HOSTNAME.log
echo "Inventory audit for server/hostname:" >> $auditlogdir/server_inventory_$HOSTNAME.log
#echo "hostname:" >> $auditlogdir/server_inventory_$HOSTNAME.log
hostname >> $auditlogdir/server_inventory_$HOSTNAME.log
echo "" >> $auditlogdir/server_inventory_$HOSTNAME.log
ifconfig | grep inet >> $auditlogdir/server_inventory_$HOSTNAME.log
ifconfig | grep ether >> $auditlogdir/server_inventory_$HOSTNAME.log
echo "" >> $auditlogdir/server_inventory_$HOSTNAME.log
echo "This script was started from user $USER" >> $auditlogdir/server_inventory_$HOSTNAME.log
echo "Your home directory is $HOME" >> $auditlogdir/server_inventory_$HOSTNAME.log
echo "Your mail INBOX is located in $MAIL" >> $auditlogdir/server_inventory_$HOSTNAME.log
echo "#################################################################################################################" >> $auditlogdir/server_inventory_$HOSTNAME.log
#echo "" >> $auditlogdir/server_inventory_$HOSTNAME.log
echo "cat /etc/redhat-release:" >> $auditlogdir/server_inventory_$HOSTNAME.log
cat /etc/redhat-release >> $auditlogdir/server_inventory_$HOSTNAME.log
echo "-----------------------------------------------------------------------------------------------------------------" >> $auditlogdir/server_inventory_$HOSTNAME.log
echo "cat /etc/lsb-release:" >> $auditlogdir/server_inventory_$HOSTNAME.log
cat /etc/lsb-release >> $auditlogdir/server_inventory_$HOSTNAME.log
echo "-----------------------------------------------------------------------------------------------------------------" >> $auditlogdir/server_inventory_$HOSTNAME.log
echo "lsb_release -a:" >> $auditlogdir/server_inventory_$HOSTNAME.log
lsb_release -a >> $auditlogdir/server_inventory_$HOSTNAME.log
echo "-----------------------------------------------------------------------------------------------------------------" >> $auditlogdir/server_inventory_$HOSTNAME.log
echo "cat /boot/grub/device.map:" >> $auditlogdir/server_inventory_$HOSTNAME.log
cat /boot/grub/device.map >> $auditlogdir/server_inventory_$HOSTNAME.log
echo "-----------------------------------------------------------------------------------------------------------------" >> $auditlogdir/server_inventory_$HOSTNAME.log
echo "cat /boot/grub/menu.lst:" >> $auditlogdir/server_inventory_$HOSTNAME.log
cat /boot/grub/menu.lst >> $auditlogdir/server_inventory_$HOSTNAME.log
echo "-----------------------------------------------------------------------------------------------------------------" >> $auditlogdir/server_inventory_$HOSTNAME.log
echo "cat /boot/grub/grub.*:" >> $auditlogdir/server_inventory_$HOSTNAME.log
cat /boot/grub/grub.* >> $auditlogdir/server_inventory_$HOSTNAME.log
echo "-----------------------------------------------------------------------------------------------------------------" >> $auditlogdir/server_inventory_$HOSTNAME.log
echo "cat /boot/grub2/device.map:" >> $auditlogdir/server_inventory_$HOSTNAME.log
cat /boot/grub2/device.map >> $auditlogdir/server_inventory_$HOSTNAME.log
echo "-----------------------------------------------------------------------------------------------------------------" >> $auditlogdir/server_inventory_$HOSTNAME.log
echo "cat /boot/grub2/grubenv:" >> $auditlogdir/server_inventory_$HOSTNAME.log
cat /boot/grub2/grubenv >> $auditlogdir/server_inventory_$HOSTNAME.log
echo ""
echo "-----------------------------------------------------------------------------------------------------------------" >> $auditlogdir/server_inventory_$HOSTNAME.log
echo "cat /boot/grub2/grub.*:" >> $auditlogdir/server_inventory_$HOSTNAME.log
cat /boot/grub2/grub.* >> $auditlogdir/server_inventory_$HOSTNAME.log
echo "-----------------------------------------------------------------------------------------------------------------" >> $auditlogdir/server_inventory_$HOSTNAME.log
echo "uname -a:" >> $auditlogdir/server_inventory_$HOSTNAME.log
uname -a >> $auditlogdir/server_inventory_$HOSTNAME.log
echo "-----------------------------------------------------------------------------------------------------------------" >> $auditlogdir/server_inventory_$HOSTNAME.log
echo "mount -v:" >> $auditlogdir/server_inventory_$HOSTNAME.log
mount -v | grep "^/" | awk '{print "\nPartition identifier: " $1  "\n Mountpoint: "  $3}' >> $auditlogdir/server_inventory_$HOSTNAME.log
echo "-----------------------------------------------------------------------------------------------------------------" >> $auditlogdir/server_inventory_$HOSTNAME.log
echo "mount:" >> $auditlogdir/server_inventory_$HOSTNAME.log
mount >> $auditlogdir/server_inventory_$HOSTNAME.log
echo "-----------------------------------------------------------------------------------------------------------------" >> $auditlogdir/server_inventory_$HOSTNAME.log
echo "cat /etc/fstab:" >> $auditlogdir/server_inventory_$HOSTNAME.log
cat /etc/fstab >> $auditlogdir/server_inventory_$HOSTNAME.log
echo "-----------------------------------------------------------------------------------------------------------------" >> $auditlogdir/server_inventory_$HOSTNAME.log
echo "df -Th:" >> $auditlogdir/server_inventory_$HOSTNAME.log
df -Th >> $auditlogdir/server_inventory_$HOSTNAME.log
echo "-----------------------------------------------------------------------------------------------------------------" >> $auditlogdir/server_inventory_$HOSTNAME.log
echo "lsblk:" >> $auditlogdir/server_inventory_$HOSTNAME.log
lsblk >> $auditlogdir/server_inventory_$HOSTNAME.log
echo "-----------------------------------------------------------------------------------------------------------------" >> $auditlogdir/server_inventory_$HOSTNAME.log
echo "lsblk -f:" >> $auditlogdir/server_inventory_$HOSTNAME.log
lsblk -f >> $auditlogdir/server_inventory_$HOSTNAME.log
echo "-----------------------------------------------------------------------------------------------------------------" >> $auditlogdir/server_inventory_$HOSTNAME.log
echo "fdisk -l:" >> $auditlogdir/server_inventory_$HOSTNAME.log
fdisk -l >> $auditlogdir/server_inventory_$HOSTNAME.log
echo "-----------------------------------------------------------------------------------------------------------------" >> $auditlogdir/server_inventory_$HOSTNAME.log
echo "parted -l:" >> $auditlogdir/server_inventory_$HOSTNAME.log
parted -l >> $auditlogdir/server_inventory_$HOSTNAME.log
echo "-----------------------------------------------------------------------------------------------------------------" >> $auditlogdir/server_inventory_$HOSTNAME.log
echo "blkid:" >> $auditlogdir/server_inventory_$HOSTNAME.log
blkid >> $auditlogdir/server_inventory_$HOSTNAME.log
echo "-----------------------------------------------------------------------------------------------------------------" >> $auditlogdir/server_inventory_$HOSTNAME.log
echo "ls -Rhal /dev/disk/by-*:" >> $auditlogdir/server_inventory_$HOSTNAME.log
ls -Rhal /dev/disk/by-* >> $auditlogdir/server_inventory_$HOSTNAME.log
echo "-----------------------------------------------------------------------------------------------------------------" >> $auditlogdir/server_inventory_$HOSTNAME.log
echo "pvs:" >> $auditlogdir/server_inventory_$HOSTNAME.log
pvs >> $auditlogdir/server_inventory_$HOSTNAME.log
echo "-----------------------------------------------------------------------------------------------------------------" >> $auditlogdir/server_inventory_$HOSTNAME.log
echo "pvdisplay:" >> $auditlogdir/server_inventory_$HOSTNAME.log
pvdisplay >> $auditlogdir/server_inventory_$HOSTNAME.log
echo "-----------------------------------------------------------------------------------------------------------------" >> $auditlogdir/server_inventory_$HOSTNAME.log
echo "vgdisplay:" >> $auditlogdir/server_inventory_$HOSTNAME.log
vgdisplay >> $auditlogdir/server_inventory_$HOSTNAME.log
echo "-----------------------------------------------------------------------------------------------------------------" >> $auditlogdir/server_inventory_$HOSTNAME.log
echo "lvdisplay:" >> $auditlogdir/server_inventory_$HOSTNAME.log
lvdisplay >> $auditlogdir/server_inventory_$HOSTNAME.log
echo "-----------------------------------------------------------------------------------------------------------------" >> $auditlogdir/server_inventory_$HOSTNAME.log
echo "cat /proc/partitions:" >> $auditlogdir/server_inventory_$HOSTNAME.log
cat /proc/partitions >> $auditlogdir/server_inventory_$HOSTNAME.log
echo "-----------------------------------------------------------------------------------------------------------------" >> $auditlogdir/server_inventory_$HOSTNAME.log
echo "hdparm -i /dev/sda:" >> $auditlogdir/server_inventory_$HOSTNAME.log
sudo hdparm -i /dev/sda >> $auditlogdir/server_inventory_$HOSTNAME.log
echo "-----------------------------------------------------------------------------------------------------------------" >> $auditlogdir/server_inventory_$HOSTNAME.log
echo "hdparm -Tt /dev/sda2:" >> $auditlogdir/server_inventory_$HOSTNAME.log
sudo hdparm -Tt /dev/sda2 >> $auditlogdir/server_inventory_$HOSTNAME.log
echo "-----------------------------------------------------------------------------------------------------------------" >> $auditlogdir/server_inventory_$HOSTNAME.log
echo "hdparm -t --direct --offset 256 /dev/sda1:" >> $auditlogdir/server_inventory_$HOSTNAME.log
sudo hdparm -t --direct --offset 256 /dev/sda1 >> $auditlogdir/server_inventory_$HOSTNAME.log
echo "-----------------------------------------------------------------------------------------------------------------" >> $auditlogdir/server_inventory_$HOSTNAME.log
echo "cat /proc/cpuinfo:" >> $auditlogdir/server_inventory_$HOSTNAME.log
cat /proc/cpuinfo >> $auditlogdir/server_inventory_$HOSTNAME.log
echo "-----------------------------------------------------------------------------------------------------------------" >> $auditlogdir/server_inventory_$HOSTNAME.log
echo "cat /proc/meminfo:" >> $auditlogdir/server_inventory_$HOSTNAME.log
cat /proc/meminfo >> $auditlogdir/server_inventory_$HOSTNAME.log
echo "-----------------------------------------------------------------------------------------------------------------" >> $auditlogdir/server_inventory_$HOSTNAME.log
echo "free -h:" >> $auditlogdir/server_inventory_$HOSTNAME.log
free -h >> $auditlogdir/server_inventory_$HOSTNAME.log
echo "-----------------------------------------------------------------------------------------------------------------" >> $auditlogdir/server_inventory_$HOSTNAME.log
echo "cat /proc/sys/kernel/shmmax:" >> $auditlogdir/server_inventory_$HOSTNAME.log
cat /proc/sys/kernel/shmmax >> $auditlogdir/server_inventory_$HOSTNAME.log
echo "-----------------------------------------------------------------------------------------------------------------" >> $auditlogdir/server_inventory_$HOSTNAME.log
echo "sysctl -a | grep shm:" >> $auditlogdir/server_inventory_$HOSTNAME.log
sudo sysctl -a | grep shm >> $auditlogdir/server_inventory_$HOSTNAME.log
echo "-----------------------------------------------------------------------------------------------------------------" >> $auditlogdir/server_inventory_$HOSTNAME.log
echo "cat /proc/devices:" >> $auditlogdir/server_inventory_$HOSTNAME.log
cat /proc/devices >> $auditlogdir/server_inventory_$HOSTNAME.log
echo "-----------------------------------------------------------------------------------------------------------------" >> $auditlogdir/server_inventory_$HOSTNAME.log
echo "cat /proc/swaps:" >> $auditlogdir/server_inventory_$HOSTNAME.log
cat /proc/swaps >> $auditlogdir/server_inventory_$HOSTNAME.log
echo "-----------------------------------------------------------------------------------------------------------------" >> $auditlogdir/server_inventory_$HOSTNAME.log
echo "cat /proc/mdstat:" >> $auditlogdir/server_inventory_$HOSTNAME.log
cat /proc/mdstat >> $auditlogdir/server_inventory_$HOSTNAME.log
echo "-----------------------------------------------------------------------------------------------------------------" >> $auditlogdir/server_inventory_$HOSTNAME.log
echo "lspci:" >> $auditlogdir/server_inventory_$HOSTNAME.log
lspci >> $auditlogdir/server_inventory_$HOSTNAME.log
echo "-----------------------------------------------------------------------------------------------------------------" >> $auditlogdir/server_inventory_$HOSTNAME.log
echo "lsusb:" >> $auditlogdir/server_inventory_$HOSTNAME.log
lsusb >> $auditlogdir/server_inventory_$HOSTNAME.log
echo "-----------------------------------------------------------------------------------------------------------------" >> $auditlogdir/server_inventory_$HOSTNAME.log
echo "lsmod:" >> $auditlogdir/server_inventory_$HOSTNAME.log
lsmod >> $auditlogdir/server_inventory_$HOSTNAME.log
echo "-----------------------------------------------------------------------------------------------------------------" >> $auditlogdir/server_inventory_$HOSTNAME.log
echo "lshw:" >> $auditlogdir/server_inventory_$HOSTNAME.log
lshw >> $auditlogdir/server_inventory_$HOSTNAME.log
echo "-----------------------------------------------------------------------------------------------------------------" >> $auditlogdir/server_inventory_$HOSTNAME.log
echo "lslogins:" >> $auditlogdir/server_inventory_$HOSTNAME.log
lslogins >> $auditlogdir/server_inventory_$HOSTNAME.log
echo "-----------------------------------------------------------------------------------------------------------------" >> $auditlogdir/server_inventory_$HOSTNAME.log
echo "lsinitrd:" >> $auditlogdir/server_inventory_$HOSTNAME.log
lsinitrd >> $auditlogdir/server_inventory_$HOSTNAME.log
echo "-----------------------------------------------------------------------------------------------------------------" >> $auditlogdir/server_inventory_$HOSTNAME.log
echo "chkconfig --list:" >> $auditlogdir/server_inventory_$HOSTNAME.log
chkconfig --list >> $auditlogdir/server_inventory_$HOSTNAME.log
echo "-----------------------------------------------------------------------------------------------------------------" >> $auditlogdir/server_inventory_$HOSTNAME.log
echo "systemctl list-unit-files | grep enabled:" >> $auditlogdir/server_inventory_$HOSTNAME.log
systemctl list-unit-files | grep enabled >> $auditlogdir/server_inventory_$HOSTNAME.log
echo "-----------------------------------------------------------------------------------------------------------------" >> $auditlogdir/server_inventory_$HOSTNAME.log
echo "cat /etc/selinux/config:" >> $auditlogdir/server_inventory_$HOSTNAME.log
cat /etc/selinux/config >> $auditlogdir/server_inventory_$HOSTNAME.log
echo "-----------------------------------------------------------------------------------------------------------------" >> $auditlogdir/server_inventory_$HOSTNAME.log
echo "cat /etc/audit/rules.d/audit.rules:" >> $auditlogdir/server_inventory_$HOSTNAME.log
cat /etc/audit/rules.d/audit.rules >> $auditlogdir/server_inventory_$HOSTNAME.log
echo "-----------------------------------------------------------------------------------------------------------------" >> $auditlogdir/server_inventory_$HOSTNAME.log
echo "multipath -ll -v3:" >> $auditlogdir/server_inventory_$HOSTNAME.log
multipath -ll -v3 >> $auditlogdir/server_inventory_$HOSTNAME.log
echo "-----------------------------------------------------------------------------------------------------------------" >> $auditlogdir/server_inventory_$HOSTNAME.log
echo "cat /etc/iscsi/initiatorname.iscsi:" >> $auditlogdir/server_inventory_$HOSTNAME.log
cat /etc/iscsi/initiatorname.iscsi >> $auditlogdir/server_inventory_$HOSTNAME.log
echo "-----------------------------------------------------------------------------------------------------------------" >> $auditlogdir/server_inventory_$HOSTNAME.log
echo "iscsiadm -m session:" >> $auditlogdir/server_inventory_$HOSTNAME.log
iscsiadm -m session >> $auditlogdir/server_inventory_$HOSTNAME.log
echo "-----------------------------------------------------------------------------------------------------------------" >> $auditlogdir/server_inventory_$HOSTNAME.log
echo "lsscsi -l:" >> $auditlogdir/server_inventory_$HOSTNAME.log
lsscsi -l >> $auditlogdir/server_inventory_$HOSTNAME.log
echo "-----------------------------------------------------------------------------------------------------------------" >> $auditlogdir/server_inventory_$HOSTNAME.log
echo "crontab -l:" >> $auditlogdir/server_inventory_$HOSTNAME.log
crontab -l >> $auditlogdir/server_inventory_$HOSTNAME.log
echo "-----------------------------------------------------------------------------------------------------------------" >> $auditlogdir/server_inventory_$HOSTNAME.log
echo "netstat -tulp:" >> $auditlogdir/server_inventory_$HOSTNAME.log
netstat -tulp >> $auditlogdir/server_inventory_$HOSTNAME.log
echo "-----------------------------------------------------------------------------------------------------------------" >> $auditlogdir/server_inventory_$HOSTNAME.log
echo "netstat -at:" >> $auditlogdir/server_inventory_$HOSTNAME.log
netstat -at >> $auditlogdir/server_inventory_$HOSTNAME.log
echo "-----------------------------------------------------------------------------------------------------------------" >> $auditlogdir/server_inventory_$HOSTNAME.log
echo "netstat -au:" >> $auditlogdir/server_inventory_$HOSTNAME.log
netstat -au >> $auditlogdir/server_inventory_$HOSTNAME.log
echo "-----------------------------------------------------------------------------------------------------------------" >> $auditlogdir/server_inventory_$HOSTNAME.log
echo "netstat -ntulp:" >> $auditlogdir/server_inventory_$HOSTNAME.log
netstat -ntulp >> $auditlogdir/server_inventory_$HOSTNAME.log
echo "-----------------------------------------------------------------------------------------------------------------" >> $auditlogdir/server_inventory_$HOSTNAME.log
echo "netstat -rn:" >> $auditlogdir/server_inventory_$HOSTNAME.log
netstat -rn >> $auditlogdir/server_inventory_$HOSTNAME.log
echo "-----------------------------------------------------------------------------------------------------------------" >> $auditlogdir/server_inventory_$HOSTNAME.log
echo "netstat -lnptux:" >> $auditlogdir/server_inventory_$HOSTNAME.log
netstat -lnptux >> $auditlogdir/server_inventory_$HOSTNAME.log
echo "-----------------------------------------------------------------------------------------------------------------" >> $auditlogdir/server_inventory_$HOSTNAME.log
echo "netstat -s:" >> $auditlogdir/server_inventory_$HOSTNAME.log
netstat -s >> $auditlogdir/server_inventory_$HOSTNAME.log
echo "-----------------------------------------------------------------------------------------------------------------" >> $auditlogdir/server_inventory_$HOSTNAME.log
echo "netstat -ate:" >> $auditlogdir/server_inventory_$HOSTNAME.log
netstat -ate | grep -v LISTEN | grep -v CONNECTED | awk '{print$5}' | sed 's/[0-9]\+$//' | sort | uniq -c >> $auditlogdir/server_inventory_$HOSTNAME.log
echo "-----------------------------------------------------------------------------------------------------------------" >> $auditlogdir/server_inventory_$HOSTNAME.log
echo "ss -ntulp:" >> $auditlogdir/server_inventory_$HOSTNAME.log
ss -ntulp >> $auditlogdir/server_inventory_$HOSTNAME.log
echo "-----------------------------------------------------------------------------------------------------------------" >> $auditlogdir/server_inventory_$HOSTNAME.log
echo "lsof -i -n:" >> $auditlogdir/server_inventory_$HOSTNAME.log
lsof -i -n | egrep 'COMMAND|LISTEN|UDP' >> $auditlogdir/server_inventory_$HOSTNAME.log
echo "-----------------------------------------------------------------------------------------------------------------" >> $auditlogdir/server_inventory_$HOSTNAME.log
echo "lsof:" >> $auditlogdir/server_inventory_$HOSTNAME.log
sudo lsof >> $auditlogdir/server_inventory_$HOSTNAME.log
echo "-----------------------------------------------------------------------------------------------------------------" >> $auditlogdir/server_inventory_$HOSTNAME.log
echo "iptables --list:" >> $auditlogdir/server_inventory_$HOSTNAME.log
iptables --list >> $auditlogdir/server_inventory_$HOSTNAME.log
echo "-----------------------------------------------------------------------------------------------------------------" >> $auditlogdir/server_inventory_$HOSTNAME.log
echo "ip6tables --list:" >> $auditlogdir/server_inventory_$HOSTNAME.log
ip6tables --list >> $auditlogdir/server_inventory_$HOSTNAME.log
echo "-----------------------------------------------------------------------------------------------------------------" >> $auditlogdir/server_inventory_$HOSTNAME.log
echo "firewall-cmd --list-all-zones:" >> $auditlogdir/server_inventory_$HOSTNAME.log
firewall-cmd --list-all-zones >> $auditlogdir/server_inventory_$HOSTNAME.log
echo "-----------------------------------------------------------------------------------------------------------------" >> $auditlogdir/server_inventory_$HOSTNAME.log
echo "ifconfig:" >> $auditlogdir/server_inventory_$HOSTNAME.log
ifconfig >> $auditlogdir/server_inventory_$HOSTNAME.log
echo "-----------------------------------------------------------------------------------------------------------------" >> $auditlogdir/server_inventory_$HOSTNAME.log
echo "route:" >> $auditlogdir/server_inventory_$HOSTNAME.log
route >> $auditlogdir/server_inventory_$HOSTNAME.log
echo "-----------------------------------------------------------------------------------------------------------------" >> $auditlogdir/server_inventory_$HOSTNAME.log
echo "cat /etc/resolv.conf:" >> $auditlogdir/server_inventory_$HOSTNAME.log
cat /etc/resolv.conf >> $auditlogdir/server_inventory_$HOSTNAME.log
echo "-----------------------------------------------------------------------------------------------------------------" >> $auditlogdir/server_inventory_$HOSTNAME.log
echo "cat /etc/hosts:" >> $auditlogdir/server_inventory_$HOSTNAME.log
cat /etc/hosts >> $auditlogdir/server_inventory_$HOSTNAME.log
echo "-----------------------------------------------------------------------------------------------------------------" >> $auditlogdir/server_inventory_$HOSTNAME.log
echo "ls -l /etc/sysctl.d/:" >> $auditlogdir/server_inventory_$HOSTNAME.log
ls -l /etc/sysctl.d/ >> $auditlogdir/server_inventory_$HOSTNAME.log
echo "-----------------------------------------------------------------------------------------------------------------" >> $auditlogdir/server_inventory_$HOSTNAME.log
echo "cat /etc/sysctl.conf:" >> $auditlogdir/server_inventory_$HOSTNAME.log
cat /etc/sysctl.conf >> $auditlogdir/server_inventory_$HOSTNAME.log
echo "-----------------------------------------------------------------------------------------------------------------" >> $auditlogdir/server_inventory_$HOSTNAME.log
echo "sysctl -p:" >> $auditlogdir/server_inventory_$HOSTNAME.log
sudo sysctl -p >> $auditlogdir/server_inventory_$HOSTNAME.log
echo "-----------------------------------------------------------------------------------------------------------------" >> $auditlogdir/server_inventory_$HOSTNAME.log
echo "sysctl -a:" >> $auditlogdir/server_inventory_$HOSTNAME.log
sudo sysctl -a >> $auditlogdir/server_inventory_$HOSTNAME.log
echo "-----------------------------------------------------------------------------------------------------------------" >> $auditlogdir/server_inventory_$HOSTNAME.log
echo "cat /etc/rc.local:" >> $auditlogdir/server_inventory_$HOSTNAME.log
cat /etc/rc.local >> $auditlogdir/server_inventory_$HOSTNAME.log
echo "-----------------------------------------------------------------------------------------------------------------" >> $auditlogdir/server_inventory_$HOSTNAME.log
echo "cat /etc/rsyslog.conf:" >> $auditlogdir/server_inventory_$HOSTNAME.log
cat /etc/rsyslog.conf >> $auditlogdir/server_inventory_$HOSTNAME.log
echo "-----------------------------------------------------------------------------------------------------------------" >> $auditlogdir/server_inventory_$HOSTNAME.log
echo "cat /var/log/yum.log:" >> $auditlogdir/server_inventory_$HOSTNAME.log
cat /var/log/yum.log >> $auditlogdir/server_inventory_$HOSTNAME.log
echo "-----------------------------------------------------------------------------------------------------------------" >> $auditlogdir/server_inventory_$HOSTNAME.log
echo "cat /var/log/dnf.log:" >> $auditlogdir/server_inventory_$HOSTNAME.log
cat /var/log/dnf.log >> $auditlogdir/server_inventory_$HOSTNAME.log
echo "-----------------------------------------------------------------------------------------------------------------" >> $auditlogdir/server_inventory_$HOSTNAME.log
echo "cat /etc/sysctl.ktune:" >> $auditlogdir/server_inventory_$HOSTNAME.log
cat /etc/sysctl.ktune >> $auditlogdir/server_inventory_$HOSTNAME.log
echo "-----------------------------------------------------------------------------------------------------------------" >> $auditlogdir/server_inventory_$HOSTNAME.log
echo "tuned-adm active:" >> $auditlogdir/server_inventory_$HOSTNAME.log
tuned-adm active >> $auditlogdir/server_inventory_$HOSTNAME.log
echo "-----------------------------------------------------------------------------------------------------------------" >> $auditlogdir/server_inventory_$HOSTNAME.log
echo "java -version:" >> $auditlogdir/server_inventory_$HOSTNAME.log
java -version >> $auditlogdir/server_inventory_$HOSTNAME.log
echo "-----------------------------------------------------------------------------------------------------------------" >> $auditlogdir/server_inventory_$HOSTNAME.log
echo "javac -version:" >> $auditlogdir/server_inventory_$HOSTNAME.log
javac -version >> $auditlogdir/server_inventory_$HOSTNAME.log
echo "-----------------------------------------------------------------------------------------------------------------" >> $auditlogdir/server_inventory_$HOSTNAME.log
echo "cat /root/.ssh/authorized_keys:" >> $auditlogdir/server_inventory_$HOSTNAME.log
cat /root/.ssh/authorized_keys >> $auditlogdir/server_inventory_$HOSTNAME.log
echo "-----------------------------------------------------------------------------------------------------------------" >> $auditlogdir/server_inventory_$HOSTNAME.log
echo "cat /etc/ssh/sshd_config:" >> $auditlogdir/server_inventory_$HOSTNAME.log
cat /etc/ssh/sshd_config >> $auditlogdir/server_inventory_$HOSTNAME.log
echo "-----------------------------------------------------------------------------------------------------------------" >> $auditlogdir/server_inventory_$HOSTNAME.log
echo "cat /etc/ssh/ssh_config:" >> $auditlogdir/server_inventory_$HOSTNAME.log
cat /etc/ssh/ssh_config >> $auditlogdir/server_inventory_$HOSTNAME.log
echo "-----------------------------------------------------------------------------------------------------------------" >> $auditlogdir/server_inventory_$HOSTNAME.log
echo "ac -p:" >> $auditlogdir/server_inventory_$HOSTNAME.log
ac -p >> $auditlogdir/server_inventory_$HOSTNAME.log
echo "-----------------------------------------------------------------------------------------------------------------" >> $auditlogdir/server_inventory_$HOSTNAME.log
echo "ac -d -y:" >> $auditlogdir/server_inventory_$HOSTNAME.log
ac -d -y >> $auditlogdir/server_inventory_$HOSTNAME.log
echo "-----------------------------------------------------------------------------------------------------------------" >> $auditlogdir/server_inventory_$HOSTNAME.log
echo "sa --print-users:" >> $auditlogdir/server_inventory_$HOSTNAME.log
sudo sa --print-users >> $auditlogdir/server_inventory_$HOSTNAME.log
echo "-----------------------------------------------------------------------------------------------------------------" >> $auditlogdir/server_inventory_$HOSTNAME.log
echo "egrep -v '.*:\*|:\!' /etc/shadow:" >> $auditlogdir/server_inventory_$HOSTNAME.log
egrep -v '.*:\*|:\!' /etc/shadow | awk -F: '{print $1}' >> $auditlogdir/server_inventory_$HOSTNAME.log
echo "-----------------------------------------------------------------------------------------------------------------" >> $auditlogdir/server_inventory_$HOSTNAME.log
echo "grep -v ':x:' /etc/passwd:" >> $auditlogdir/server_inventory_$HOSTNAME.log
grep -v ':x:' /etc/passwd >> $auditlogdir/server_inventory_$HOSTNAME.log
echo "-----------------------------------------------------------------------------------------------------------------" >> $auditlogdir/server_inventory_$HOSTNAME.log
echo "lastb:" >> $auditlogdir/server_inventory_$HOSTNAME.log
lastb >> $auditlogdir/server_inventory_$HOSTNAME.log
echo "-----------------------------------------------------------------------------------------------------------------" >> $auditlogdir/server_inventory_$HOSTNAME.log
echo "cat /etc/xinetd.d/check-mk-agent:" >> $auditlogdir/server_inventory_$HOSTNAME.log
cat /etc/xinetd.d/check-mk-agent >> $auditlogdir/server_inventory_$HOSTNAME.log
echo "-----------------------------------------------------------------------------------------------------------------" >> $auditlogdir/server_inventory_$HOSTNAME.log
echo "cat /etc/bacula/bacula-fd.conf:" >> $auditlogdir/server_inventory_$HOSTNAME.log
cat /etc/bacula/bacula-fd.conf >> $auditlogdir/server_inventory_$HOSTNAME.log
echo "-----------------------------------------------------------------------------------------------------------------" >> $auditlogdir/server_inventory_$HOSTNAME.log
echo "cat /etc/bacula/bconsole.conf:" >> $auditlogdir/server_inventory_$HOSTNAME.log
cat /etc/bacula/bconsole.conf >> $auditlogdir/server_inventory_$HOSTNAME.log
echo "-----------------------------------------------------------------------------------------------------------------" >> $auditlogdir/server_inventory_$HOSTNAME.log
echo "ls -l /etc/bacula/scripts/:" >> $auditlogdir/server_inventory_$HOSTNAME.log
ls -l /etc/bacula/scripts/ >> $auditlogdir/server_inventory_$HOSTNAME.log
echo "-----------------------------------------------------------------------------------------------------------------" >> $auditlogdir/server_inventory_$HOSTNAME.log
echo "ls -lZ /etc/bacula/scripts/:" >> $auditlogdir/server_inventory_$HOSTNAME.log
ls -lZ /etc/bacula/scripts >> $auditlogdir/server_inventory_$HOSTNAME.log
echo "-----------------------------------------------------------------------------------------------------------------" >> $auditlogdir/server_inventory_$HOSTNAME.log
echo "ls -l /etc/yum.repos.d/:" >> $auditlogdir/server_inventory_$HOSTNAME.log
ls -l /etc/yum.repos.d/ >> $auditlogdir/server_inventory_$HOSTNAME.log
echo "-----------------------------------------------------------------------------------------------------------------" >> $auditlogdir/server_inventory_$HOSTNAME.log
echo "ls -l /:" >> $auditlogdir/server_inventory_$HOSTNAME.log
ls -l / >> $auditlogdir/server_inventory_$HOSTNAME.log
echo "-----------------------------------------------------------------------------------------------------------------" >> $auditlogdir/server_inventory_$HOSTNAME.log
echo "ls -l /var/log/:" >> $auditlogdir/server_inventory_$HOSTNAME.log
ls -l /var/log/ >> $auditlogdir/server_inventory_$HOSTNAME.log
echo "-----------------------------------------------------------------------------------------------------------------" >> $auditlogdir/server_inventory_$HOSTNAME.log
echo "tail -n 1000 /var/log/messages:" >> $auditlogdir/server_inventory_$HOSTNAME.log
tail -n 1000 /var/log/messages >> $auditlogdir/server_inventory_$HOSTNAME.log
echo "-----------------------------------------------------------------------------------------------------------------" >> $auditlogdir/server_inventory_$HOSTNAME.log
echo "tail -n 500 /var/log/kern.log:" >> $auditlogdir/server_inventory_$HOSTNAME.log
tail -n 500 /var/log/kern.log >> $auditlogdir/server_inventory_$HOSTNAME.log
echo "-----------------------------------------------------------------------------------------------------------------" >> $auditlogdir/server_inventory_$HOSTNAME.log
echo "tail -n 500 /var/log/auth.log:" >> $auditlogdir/server_inventory_$HOSTNAME.log
tail -n 500 /var/log/auth.log >> $auditlogdir/server_inventory_$HOSTNAME.log
echo "-----------------------------------------------------------------------------------------------------------------" >> $auditlogdir/server_inventory_$HOSTNAME.log
echo "w:" >> $auditlogdir/server_inventory_$HOSTNAME.log
w >> $auditlogdir/server_inventory_$HOSTNAME.log
echo "-----------------------------------------------------------------------------------------------------------------" >> $auditlogdir/server_inventory_$HOSTNAME.log
echo "who:" >> $auditlogdir/server_inventory_$HOSTNAME.log
who >> $auditlogdir/server_inventory_$HOSTNAME.log
echo "-----------------------------------------------------------------------------------------------------------------" >> $auditlogdir/server_inventory_$HOSTNAME.log
echo "" >> $auditlogdir/server_inventory_$HOSTNAME.log
echo "hostname:" >> $auditlogdir/server_inventory_$HOSTNAME.log
hostname  >> $auditlogdir/server_inventory_$HOSTNAME.log
echo "-----------------------------------------------------------------------------------------------------------------" >> $auditlogdir/server_inventory_$HOSTNAME.log
echo "uptime:" >> $auditlogdir/server_inventory_$HOSTNAME.log
uptime >> $auditlogdir/server_inventory_$HOSTNAME.log
echo "-----------------------------------------------------------------------------------------------------------------" >> $auditlogdir/server_inventory_$HOSTNAME.log
echo "etckeeper daily commit:" >> $auditlogdir/server_inventory_$HOSTNAME.log
etckeeper commit "Update information about all files and configurations in /etc folder. State at $DATE" >> $auditlogdir/server_inventory_$HOSTNAME.log
sleep 5
echo "-----------------------------------------------------------------------------------------------------------------" >> $auditlogdir/server_inventory_$HOSTNAME.log
#echo "" >> $auditlogdir/server_inventory_$HOSTNAME.log
echo "End of File" >> $auditlogdir/server_inventory_$HOSTNAME.log
echo "#################################################################################################################" >> $auditlogdir/server_inventory_$HOSTNAME.log
#echo "" >> $auditlogdir/server_inventory_$HOSTNAME.log
#
echo "####################################################################################"
#
# Create and verify other parameters
/bin/chmod 0644 $auditlogdir/server_inventory_$HOSTNAME.log
echo "Creating the backup inventory data and storing it in a $auditlogdir/server_inventory_$HOSTNAME.log"
echo "This audit/data file is needed for the Disaster Recovery Plan using in Corporate Backup System Bacula!"
#
# Sending copy of audit/data to DevOps MailGroup
msg="This is copy of inventory data from HOST: $HOSTNAME, verify at $DATE_START. This audit/data file is needed for bare metal recovery procedures... -->"
#echo $msg
#sed -e 's/$/\r/' $auditlogdir/server_inventory_$HOSTNAME.log | pigz --best --independent > $auditlogdir/server_inventory_$HOSTNAME.log.win.txt.gz
sed -e 's/$/\r/' $auditlogdir/server_inventory_$HOSTNAME.log > $auditlogdir/server_inventory_$HOSTNAME.log.win.txt
#msg_body=`cat $auditlogdir/server_inventory_$HOSTNAME.log | sed "s/'/\n/g` > $auditlogdir/server_inventory_$HOSTNAME.log.win.txt
msg_body=`cat $auditlogdir/server_inventory_$HOSTNAME.log.win.txt`
#echo $msg_body
/bin/chmod 0644 $auditlogdir/server_inventory_$HOSTNAME.log.win.txt
/bin/chmod 0644 $auditlogdir/server_inventory_$HOSTNAME.log
cd /
#echo "$msg" | mail -s "WARNING: inventory of HOST: $HOSTNAME -->" -a $auditlogdir/server_inventory_$HOSTNAME.log.win.txt $ADMIN
#echo -n $msg $msg_body | mail -s "WARNING: inventory of HOST: $HOSTNAME -->" $ADMIN
echo -n $msg | mutt -s "WARNING: inventory of HOST: $HOSTNAME -->" -a $auditlogdir/server_inventory_$HOSTNAME.log.win.txt $ADMIN
echo "Sending copy of this audit/data file to DevOps MailGroup: $ADMIN "
echo "OK... Very well... Please start up the next Corporate Bacula Backup System procedures..."
#
# Rial exit code status
if [ "${ERR}" == "0" ]; then
exit 0;
else
exit 1;
fi
#
#echo "OK... Audit your system has been DONE... Thank you..."

