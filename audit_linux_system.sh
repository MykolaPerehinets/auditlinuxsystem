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
# Installation:
#
# echo "cd /etc/bacula/scripts && git clone https://github.com/MykolaPerehinets/auditlinuxsystem.git"
#
# Script function: Audit Linux systems/services for correct backup process
#
# Script requirements:
# # yum install bacula-client vim parted pciutils yum-plugin-security yum-plugin-verify yum-plugin-changelog lsusb lshw usbutils lsscsi pigz mlocate time glances tuned redhat-lsb-core etckeeper firewalld mailx policycoreutils-python policycoreutils-newrole policycoreutils-restorecond setools-console lsof iotop htop tree mutt
#
# Addditional requirements: for initial etckeeper run next command from root
# # cd /etc
# # sudo etckeeper init
# # sudo etckeeper commit "Initial import"
# # git config --global user.name "root"
# # git config --global user.email root@"HOSTNAME"."DOMAIN"                                                                                                                                                                      "
# #
# Addditional requirements: for initial bacula scripts run next command from root
# # cd /etc/bacula/scripts
# # setenforce 0
# # tail -fn 0 /var/log/audit/audit.log | grep bacula > /etc/bacula/bacula-audit.log
# # * (run a backup job that has a pre-script)
# # chcon system_u:object_r:bacula_exec_t:s0 /etc/bacula/scripts
# # semanage fcontext -a -t bacula_exec_t "/etc/bacula/scripts(/.*)?"
# # restorecon -R -v /etc/bacula/scripts
#        restorecon reset /etc/bacula/scripts/audit_linux_system.sh context unconfined_u:object_r:bacula_etc_t:s0->unconfined_u:object_r:bacula_exec_t:s0
#        restorecon reset /etc/bacula/scripts/make_dumpall_pgsql.sh context unconfined_u:object_r:bacula_etc_t:s0->unconfined_u:object_r:bacula_exec_t:s0
#        restorecon reset /etc/bacula/scripts/verify_dumpall_pgsql.sh context unconfined_u:object_r:bacula_etc_t:s0->unconfined_u:object_r:bacula_exec_t:s0
#        restorecon reset /etc/bacula/scripts/delete_dumpall_pgsql.sh context unconfined_u:object_r:bacula_etc_t:s0->unconfined_u:object_r:bacula_exec_t:s0
#        restorecon reset /etc/bacula/scripts/recovery_dumpall_pgsql.sh context unconfined_u:object_r:bacula_etc_t:s0->unconfined_u:object_r:bacula_exec_t:s0
# # ls -lZ /etc/bacula/scripts
# # cd /etc/bacula
# # cat /etc/bacula/bacula-audit.log | audit2allow -M bacula_policy
# # audit2allow -a
# # audit2allow -a -M bacula_policy
# # ...
# # REVIEW: bacula_policy.te
# # INSTALL POLISY:
# # semodule -i bacula_policy.pp
# # TEST: run another backup job, ensure you get no more AVC DENIED messages in /var/log/audit/audit.log
# # ...
# # REVIEW: bacula_policy.te
# # INSTALL POLISY:
# # semodule -i bacula_policy.pp
# # TEST: run another backup job, ensure you get no more AVC DENIED messages in /var/log/audit/audit.log
# # ...
# # REVIEW: bacula_policy.te
# # INSTALL POLISY:
# # semodule -i bacula_policy.pp
# # TEST: run another backup job, ensure you get no more AVC DENIED messages in /var/log/audit/audit.log
# # ...
# # DONE
# # setenforce 1
#
# Script Submitted and Deployment in production environments by:
# Mykola Perehinets (mperehin)
# Tel: +380 67 772 6910
# mailto:mykola.perehinets@gmail.com
#
#######################################################################################################################
# Script modified date
Version=24062017
#
#######################################################################################################################
# Exit code
ERR=0
# Basic script configuration, etc...
PATH=/sbin:/bin:/usr/sbin:/usr/bin:/usr/local/sbin:/usr/local/bin
#
ADMIN="BaculaBackupOperators@localhost.localdomain"
#
#HOSTNAME=`hostname -s`
HOSTNAME=`hostname`
#
DATE=$(date +%Y-%m-%d_%H:%M)
#DATE=$(date +%Y-%m-%d)
#DATE_START=$(date +%H:%M)
#DATE_START=$(date +%Y-%m-%d__%H:%M)
DATE_START=$(date +%Y-%m-%d_%H:%M)
#
# Store inventory log files in this folder
#auditlogdir=/root
#auditlogdir=/var/log
auditlogdir=/etc/bacula/scripts
#
#auditlogdirR=/RESTORE
auditlogdirR=/RECOVERY
#
# Verify folders
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
cd $auditlogdir
echo "WARNING: Please verify Script Version on your server HOST: $HOSTNAME"
echo "OK... Audit your system has been START... Script Version in this server #$Version... "
echo "####################################################################################"
echo "OK... Audit your system has been start at $DATE_START... Script Version #$Version..." > $auditlogdir/server_inventory_$HOSTNAME.log
echo "#################################################################################################################" >> $auditlogdir/server_inventory_$HOSTNAME.log
echo "Inventory audit for server/hostname:" >> $auditlogdir/server_inventory_$HOSTNAME.log
hostname >> $auditlogdir/server_inventory_$HOSTNAME.log
ifconfig | grep inet >> $auditlogdir/server_inventory_$HOSTNAME.log
ifconfig | grep ether >> $auditlogdir/server_inventory_$HOSTNAME.log
echo "" >> $auditlogdir/server_inventory_$HOSTNAME.log
echo "This script was started from user $USER" >> $auditlogdir/server_inventory_$HOSTNAME.log
echo "Your home directory is $HOME" >> $auditlogdir/server_inventory_$HOSTNAME.log
echo "Your mail INBOX is located in $MAIL" >> $auditlogdir/server_inventory_$HOSTNAME.log
echo "#################################################################################################################" >> $auditlogdir/server_inventory_$HOSTNAME.log
echo "" >> $auditlogdir/server_inventory_$HOSTNAME.log
echo "" >> $auditlogdir/server_inventory_$HOSTNAME.log
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
echo "cat /proc/cpuinfo:" >> $auditlogdir/server_inventory_$HOSTNAME.log
cat /proc/cpuinfo >> $auditlogdir/server_inventory_$HOSTNAME.log
echo "-----------------------------------------------------------------------------------------------------------------" >> $auditlogdir/server_inventory_$HOSTNAME.log
echo "cat /proc/meminfo:" >> $auditlogdir/server_inventory_$HOSTNAME.log
cat /proc/meminfo >> $auditlogdir/server_inventory_$HOSTNAME.log
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
echo "netstat -ntulp:" >> $auditlogdir/server_inventory_$HOSTNAME.log
netstat -ntulp >> $auditlogdir/server_inventory_$HOSTNAME.log
echo "-----------------------------------------------------------------------------------------------------------------" >> $auditlogdir/server_inventory_$HOSTNAME.log
echo "lsof -i -n:" >> $auditlogdir/server_inventory_$HOSTNAME.log
lsof -i -n | egrep 'COMMAND|LISTEN|UDP' >> $auditlogdir/server_inventory_$HOSTNAME.log
echo "-----------------------------------------------------------------------------------------------------------------" >> $auditlogdir/server_inventory_$HOSTNAME.log
echo "netstat -ate:" >> $auditlogdir/server_inventory_$HOSTNAME.log
netstat -ate | grep -v LISTEN | grep -v CONNECTED | awk '{print$5}' | sed 's/[0-9]\+$//' | sort | uniq -c >> $auditlogdir/server_inventory_$HOSTNAME.log
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
echo "cat /etc/sysctl.conf:" >> $auditlogdir/server_inventory_$HOSTNAME.log
cat /etc/sysctl.conf >> $auditlogdir/server_inventory_$HOSTNAME.log
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
echo "End of File" >> $auditlogdir/server_inventory_$HOSTNAME.log
#
echo "####################################################################################"
#
# Create and Verify other parameters
/bin/chmod 0644 $auditlogdir/server_inventory_$HOSTNAME.log
echo "Create backup inventory data and store in $auditlogdir/server_inventory_$HOSTNAME.log"
echo "This data file is needed for Disaster Recovery Plan using in Corporate Backup System Bacula!"
#echo "OK... Audit your system has been DONE... Thank you..."
#
# Sending copy of data to Admins MailGroup
msg="This is copy of inventory data on HOST: $HOSTNAME, verify at $DATE_START. This file is needed for recovery procedures... -->"
#echo $msg
#msg_body=`cat $auditlogdir/server_inventory_$HOSTNAME.log | sed "s/'/\n/g` > $auditlogdir/server_inventory_$HOSTNAME.log.win.txt
#cat $auditlogdir/server_inventory_$HOSTNAME.log | sed "s/$/`echo -e \r`/" > $auditlogdir/server_inventory_$HOSTNAME.log.win.txt
#awk '{sub(/$/,"\r");print}' $auditlogdir/server_inventory_$HOSTNAME.log > $auditlogdir/server_inventory_$HOSTNAME.log.win.txt
#sed -e 's/$/\r/' $auditlogdir/server_inventory_$HOSTNAME.log | pigz --best --independent > $auditlogdir/server_inventory_$HOSTNAME.log.win.txt.gz
sed -e 's/$/\r/' $auditlogdir/server_inventory_$HOSTNAME.log > $auditlogdir/server_inventory_$HOSTNAME.log.win.txt
msg_body=`cat $auditlogdir/server_inventory_$HOSTNAME.log.win.txt`
#echo $msg_body
/bin/chmod 0644 $auditlogdir/server_inventory_$HOSTNAME.log.win.txt
/bin/chmod 0644 $auditlogdir/server_inventory_$HOSTNAME.log
cd /
#echo "$msg" | mail -s "WARNING: inventory of HOST: $HOSTNAME -->" -a $auditlogdir/server_inventory_$HOSTNAME.log.win.txt $ADMIN
#echo -n $msg $msg_body | mail -s "WARNING: inventory of HOST: $HOSTNAME -->" $ADMIN
echo -n $msg | mutt -s "WARNING: inventory of HOST: $HOSTNAME -->" -a $auditlogdir/server_inventory_$HOSTNAME.log.win.txt $ADMIN
echo "Sending copy this data file to Admins - MailGroup: $ADMIN "
echo "OK... Very well... Please Start-up next Corporate Bacula Backup System procedures..."
#
# Exit code script status
if [ "${ERR}" == "0" ]; then
exit 0;
else
exit 1;
fi

