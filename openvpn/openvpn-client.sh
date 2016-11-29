#!/bin/bash
cd /etc/openvpn/easy-ras/2.0
#input enter
./build-key client

cd client
cp /etc/openvpn/easy-rsa/2.0/keys/ca.crt ./
cp /etc/openvpn/easy-rsa/2.0/keys/client.crt ./
cp /etc/openvpn/easy-rsa/2.0/keys/client.key ./

tar czf /var/www/myvpncfg.tgz ./*
cp openvpn-2.2.2-install.exe /var/www/

echo "1. Download http://ServerIP/openvpn-2.2.2-install.exe and install"
echo "2. Cert user, please download http://ServerIP/myvpncfg.tgz to windows openvpn install dir..."
echo "3. Password user, ecec /etc/openvpn/aduser first, user/pass authenticates by PAM/Mysql saslauthd"
echo "4. The 'test:123456' can be test now."

echo "*** Enjoy OpenVPN! ***"
