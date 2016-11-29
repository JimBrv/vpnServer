#!/bin/bash

if [ $(id -u) != "0" ]; then
    printf "Error: You must be root to run this tool!\n"
    exit 1
fi
clear
printf "
####################################################
#                                                  #
# This is a Shell-Based tool of l2tp installation  #
# Version: 1.2                                     #
# Author: Zed Lau                                  #
# Website: http://zeddicus.com                     #
# For Ubuntu 32bit and 64bit                       #
#                                                  #
####################################################
"
#vpsip=`ifconfig  | grep 'inet addr:'| grep -v '127.0.0.1' | cut -d: -f2 | awk 'NR==1 { print $1}'`
vpsip=$1

iprange="172.18.8"
echo "Please input IP-Range:"
read -p "(Default Range: 172.18.8):" iprange
if [ "$iprange" = "" ]; then
        iprange="172.18.8"
fi

mypsk="gendovpn"
echo "Please input PSK:"
read -p "(Default PSK: gendovpn):" mypsk
if [ "$mypsk" = "" ]; then
        mypsk="gendovpn"
fi


clear
get_char()
{
SAVEDSTTY=`stty -g`
stty -echo
stty cbreak
dd if=/dev/tty bs=1 count=1 2> /dev/null
stty -raw
stty echo
stty $SAVEDSTTY
}
echo ""
echo "ServerIP:"
echo "$vpsip"
echo ""
echo "Server Local IP:"
echo "$iprange.1"
echo ""
echo "Client Remote IP Range:"
echo "$iprange.2-$iprange.254"
echo ""
echo "PSK:"
echo "$mypsk"
echo ""
echo "Press any key to start..."
char=`get_char`
clear


apt-get -y update
#apt-get -y upgrade
apt-get -y install make gcc libgmp3-dev bison flex libpcap-dev lsof


#Openswan IKE change package
apt-get -y install openswan

rm -rf /etc/ipsec.conf
touch /etc/ipsec.conf
cat >>/etc/ipsec.conf<<EOF
config setup
        nat_traversal=yes
        virtual_private=%v4:172.18.0.0/16
        protostack=netkey


conn L2TP-PSK-NAT
        rightsubnet=vhost:%priv
        also=L2TP-PSK-noNAT

conn L2TP-PSK-noNAT
        authby=secret
        pfs=no
        auto=add
        keyingtries=3
        rekey=no
        type=transport
        left=$vpsip
        leftprotoport=17/1701
        right=%any
        rightprotoport=17/0
        leftnexthop=%defaultroute
        rightnexthop=%defaultroute
        dpddelay=40
        dpdtimeout=130
        dpdaction=clear
EOF

cat >>/etc/ipsec.secrets<<EOF
$vpsip %any: PSK "$mypsk"
EOF

sed -i 's/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/g' /etc/sysctl.conf
sed -i 's/#net.ipv6.conf.all.forwarding=1/net.ipv6.conf.all.forwarding=1/g' /etc/sysctl.conf
sysctl -p

for each in /proc/sys/net/ipv4/conf/*
do
echo 0 > $each/accept_redirects
echo 0 > $each/send_redirects
done

service ipsec restart
ipsec verify



# xl2tpd has no control use rp instead
tar zxvf rp-l2tp-0.4.tar.gz
cd rp-l2tp-0.4
./configure
make
cp handlers/l2tp-control /usr/local/sbin/
cd ..
mkdir /var/run/xl2tpd/
ln -s /usr/local/sbin/l2tp-control /var/run/xl2tpd/l2tp-control


#xl2tpd compile
tar zxvf xl2tpd-1.2.4.tar.gz
cd xl2tpd-1.2.4
make install
cp xl2tpd /usr/sbin/
cd ..
mkdir /etc/xl2tpd
rm -rf /etc/xl2tpd/xl2tpd.conf
touch /etc/xl2tpd/xl2tpd.conf
cat >>/etc/xl2tpd/xl2tpd.conf<<EOF
[global]
ipsec saref = yes
port = 1701
access control = no
debug avp = yes
debug network = yes
debug state = yes
debug tunnel = yes

[lns default]
ip range = 172.18.8.2-172.18.8.254
local ip = 172.18.8.1
require chap = yes
refuse pap = yes
name = l2tpd
pppoptfile = /etc/ppp/options.xl2tpd
ppp debug = no
length bit = yes
require authentication = yes
EOF

rm -rf /etc/ppp/options.xl2tpd
touch /etc/ppp/options.xl2tpd
cat >>/etc/ppp/options.xl2tpd<<EOF
ms-dns 8.8.8.8
ms-dns 8.8.4.4
auth
crtscts
lock
hide-password
debug
name l2tpd
noccp
#idle 1800
mtu 1400
mru 1400
lcp-echo-interval 30
lcp-echo-failure  10
nodefaultroute
proxyarp
plugin radius.so
plugin radattr.so
radius-config-file /usr/local/etc/radiusclient/radiusclient.conf
EOF

service ipsec restart
xl2tpd&