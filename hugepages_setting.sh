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
# Configuring HugePages for Oracle on Linux server (x86-64)
# Linux bash script to compute values for the recommended HugePages/HugeTLB configuration
# https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/6/html/performance_tuning_guide/s-memory-transhuge
# https://kevinclosson.net/2010/09/28/configuring-linux-hugepages-for-oracle-database-is-just-too-difficult-part-i/
# https://oracle-base.com/articles/linux/configuring-huge-pages-for-oracle-on-linux-64
# https://www.cnblogs.com/zhangshengdong/p/11889148.html
# Please use for this action root account!
#
# Note: This script does calculation for all shared memory
# segments available when the script is run, no matter it
# is an Oracle RDBMS shared memory segment or not.
#
#
# Script Submitted and Deployment in Production environments by:
# Mykola Perehinets (mperehin)
# Tel: +380 67 772 6910
# Mailto: mykola.perehinets@gmail.com
#
#######################################################################################################################
# Script modified date
Version=27012022
#
#######################################################################################################################
#
# Basic Script Configuration, deploy needed parameters, variables, etc.
PATH=/sbin:/bin:/usr/sbin:/usr/bin:/usr/local/sbin:/usr/local/bin
#
#HOSTNAME=`hostname -s`
HOSTNAME=`hostname`
#
DATE=$(date +%Y-%m-%d_%H:%M)
#DATE_START=$(date +%Y-%m-%d_%H:%M)
#
#######################################################################################################################
# Run script
echo "WARNING: Please verify Script Version on your server HOST: $HOSTNAME"
echo "OK... Verify your system has been STARTING... Script Version in this server #$Version... "
echo "####################################################################################"
#
# Check for the kernel version
KERN=`uname -r | awk -F. '{ printf("%d.%d\n",$1,$2); }'`
#
# Find out the HugePage size
HPG_SZ=`grep Hugepagesize /proc/meminfo | awk {'print $2'}`
#
# Start from 1 pages to be on the safe side and guarantee 1 free HugePage
NUM_PG=1
#
# Cumulative number of pages required to handle the running shared memory segments
for SEG_BYTES in `ipcs -m | awk {'print $5'} | grep "[0-9][0-9]*"`
do
   MIN_PG=`echo "$SEG_BYTES/($HPG_SZ*1024)" | bc -q`
   if [ $MIN_PG -gt 0 ]; then
      NUM_PG=`echo "$NUM_PG+$MIN_PG+1" | bc -q`
   fi
done
#
# Finish with results (recommended setting)
case $KERN in
   '2.4') HUGETLB_POOL=`echo "$NUM_PG*$HPG_SZ/1024" | bc -q`;
          echo "> Recommended setting: vm.hugetlb_pool = $HUGETLB_POOL" ;;
   '2.6' | '3.8' | '3.10' | '4.1' | '4.14' ) echo "> Recommended setting: vm.nr_hugepages = $NUM_PG" ;;
    *) echo "Unrecognized kernel version $KERN. Exiting." ;;
esac
#
echo "####################################################################################"
echo ""
#
# End of script

