#auditlinuxsystem

Script for Inventory All Configurations on Linux servers/hosts (for Bacula Bare-Metal Recovery)

Unfortunately, many of the steps one must take before and immediately after a disaster are very operating system-dependent. This script is needed to inventory your system(hardware and software configuration) and help of creating new bacula backup job. When disaster strikes, you must have a plan, and you must have prepared in advance, otherwise, the work of recovering your system and your files will be considerably greater.

Installation is very simple:

Please use for ALL action root account!

# cd /etc/bacula/scripts   &&   git clone https://github.com/MykolaPerehinets/auditlinuxsystem.git
# ./audit_linux_system.sh

Verified on Centos, Ubuntu...

