!#/bin/bash

# change timezone to china
cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
hwclock

#set forward firstly
chmod +x vpn-iptable.sh
./vpn-iptable.sh $1

# create start program while booting
cat >/etc/rc.local<<EOF
#!/bin/bash 
iptables-restore < /etc/iptables.rules
service openvpn restart
/etc/init.d/pptpd restart
service ipsec restart
xl2tpd&
EOF
chmod +x /etc/rc.local


echo -e "Install PPTP..."
cd pptp
chmod +x pptp-client.sh
./pptp-client.sh $1
echo -e "Install PPTP OK"

echo -e "Install L2TP..."
cd ..
cd l2tp
chmod +x l2tp.sh
./l2tp.sh $1
echo -e "Install L2TP..."

echo -e "SSL VPN need manual setup first, break in 20s!"
sleep 20

echo -e "Install SSLVPN..."
cd ../openvpn
chmod +x openvpn-server.sh
./openvpn-server.sh $1
echo -e "Install SSLVPN OK"


