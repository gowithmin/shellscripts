#!/bin/sh
# hyunmin hwang, gowithmin@gmail.com
# 2014.10.22
# collect centos information(local) for rundeck

echo "==Server Information=="
if [ `dmesg | grep VMware | wc -l` -eq 0 ];then
    echo "Physical server"
else
    echo "Virtual server(VMware)"
fi

# Host
Host=`grep HOSTNAME /etc/sysconfig/network | tr "=" " " | awk {'print $2'}`
echo "Server : $Host"

echo "= Hardware ="
# CPU
echo "CPU: `grep processor /proc/cpuinfo | wc -l` cores"
# Mem
echo "MEM: `grep MemTotal /proc/meminfo | awk {'print $2/1024/1024"GB"'}`"
HDDs=(`grep -e "sd[a-z]$" /proc/partitions | awk {'print $4 "," $3/1024/1024"GB"'}`)
for hdd in ${HDDs[@]}
do
    echo "HDD: $hdd"
done

# OS version
echo "= OS Version ="
OS=`cat /etc/redhat-release`
Arch=`uname -m`
case $Arch in
"x86_64")
    Arch="64bit"
    ;;
"i686"|"i386")
    Arch="32bit"
    ;;
*)
    Arch="Arch"
    ;;
esac
echo "$OS $Arch"

echo "= Network: IP ="
# IP
/sbin/ip addr | grep "inet " | awk {'print $2'}

echo "= Network: DNS ="
# DNS
grep -e "^nameserver" /etc/resolv.conf
# Listen
echo "= Network: Listen port ="
echo "Protocol IP Port"
netstat -na | grep "LISTEN" | grep "0.0.0.0:*" | awk '{print $1 " " $4}' | sed 's/\:/ /g'
