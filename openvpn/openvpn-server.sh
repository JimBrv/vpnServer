#!/bin/bash
apt-get -y install mysql-client openvpn udev lzop iptables libpam-mysql
cp -r /usr/share/doc/openvpn/examples/easy-rsa/ /etc/openvpn
cp etc-openvpn-easy-2.0-whichopensslcnf /etc/openvpn/easy-rsa/2.0/whichopensslcnf
cp etc-pamd-openvpn /etc/pam.d/openvpn
cp etc-openvpn-connect /etc/openvpn/connect
cp etc-openvpn-disconnect /etc/openvpn/disconnect
cp etc-crondaily-openvpn /etc/cron.daily/openvpn
cp etc-cronmonthly-openvpn /etc/cron.monthly/openvpn
cp etc-openvpn-adduser     /etc/openvpn/adduser
cp /usr/lib/openvpn/openvpn-auth-pam.so /etc/openvpn/

# Make connect/disconnect works
chmod +x /etc/openvpn/connect /etc/openvpn/disconnect 

mkdir -p /etc/openvpn/easy-rsa/2.0/keys
cp ca.tgz /etc/openvpn/easy-rsa/2.0/keys/
cd /etc/openvpn/easy-rsa/2.0/keys/
tar zxf ca.tgz

cd /etc/openvpn/easy-rsa/2.0

######
# Use the same ca.crt, server.crt for all openvpn nodes
#
######
#source vars
#./clean-all

#input enter all 
#./build-ca

#input enter...
#./build-key-server server

#input enter again...
#./build-key client
source ./vars
./build-dh


############# Generate config #################

cat >>/etc/openvpn/udp-450.conf<<EOF
local $1
port  450
proto udp
dev tun
ca /etc/openvpn/easy-rsa/2.0/keys/ca.crt
cert /etc/openvpn/easy-rsa/2.0/keys/server.crt
key /etc/openvpn/easy-rsa/2.0/keys/server.key
dh /etc/openvpn/easy-rsa/2.0/keys/dh1024.pem
server 172.18.50.0 255.255.255.0
plugin ./openvpn-auth-pam.so openvpn
client-cert-not-required
username-as-common-name
push "redirect-gateway def1 bypass-dhcp"
push "dhcp-option DNS 8.8.8.8"
push "dhcp-option DNS 8.8.4.4"
client-to-client
keepalive 20 60
comp-lzo
max-clients 50
persist-key
persist-tun
status /var/log/openvpn.log
log-append /var/log/openvpn.log
log /var/log/openvpn.log
verb 3
mute 20
script-security 2
client-connect ./connect
client-disconnect ./disconnect
EOF


cat>>/etc/openvpn/udp-451.conf<<EOF
local $1
port  451
proto udp
dev tun
ca /etc/openvpn/easy-rsa/2.0/keys/ca.crt
cert /etc/openvpn/easy-rsa/2.0/keys/server.crt
key /etc/openvpn/easy-rsa/2.0/keys/server.key
dh /etc/openvpn/easy-rsa/2.0/keys/dh1024.pem
server 172.18.51.0 255.255.255.0

plugin ./openvpn-auth-pam.so openvpn
client-cert-not-required
username-as-common-name
push "redirect-gateway def1 bypass-dhcp"
push "dhcp-option DNS 8.8.8.8"
push "dhcp-option DNS 8.8.4.4"
client-to-client
keepalive 20 60
comp-lzo
max-clients 50
persist-key
persist-tun
status /var/log/openvpn.log
log-append /var/log/openvpn.log
log /var/log/openvpn.log
verb 3
mute 20
script-security 2
client-connect ./connect
client-disconnect ./disconnect
EOF

cat>>/etc/openvpn/udp-452.conf<<EOF
local $1
port  452
proto udp
dev tun
ca /etc/openvpn/easy-rsa/2.0/keys/ca.crt
cert /etc/openvpn/easy-rsa/2.0/keys/server.crt
key /etc/openvpn/easy-rsa/2.0/keys/server.key
dh /etc/openvpn/easy-rsa/2.0/keys/dh1024.pem
server 172.18.52.0 255.255.255.0
#user/pass auth from pam_mysql
plugin ./openvpn-auth-pam.so openvpn
client-cert-not-required
username-as-common-name
push "redirect-gateway def1 bypass-dhcp"
push "dhcp-option DNS 8.8.8.8"
push "dhcp-option DNS 8.8.4.4"
client-to-client
keepalive 20 60
comp-lzo
max-clients 50
persist-key
persist-tun
status /var/log/openvpn.log
log-append /var/log/openvpn.log
log /var/log/openvpn.log
verb 3
mute 20
script-security 2
client-connect ./connect
client-disconnect ./disconnect
EOF


cat>>/etc/openvpn/tcp-460.conf<<EOF
local $1
port  460
proto tcp
dev tun
ca /etc/openvpn/easy-rsa/2.0/keys/ca.crt
cert /etc/openvpn/easy-rsa/2.0/keys/server.crt
key /etc/openvpn/easy-rsa/2.0/keys/server.key
dh /etc/openvpn/easy-rsa/2.0/keys/dh1024.pem

server 172.18.60.0 255.255.255.0
plugin ./openvpn-auth-pam.so openvpn
client-cert-not-required
username-as-common-name
push "redirect-gateway def1 bypass-dhcp"
push "dhcp-option DNS 8.8.8.8"
push "dhcp-option DNS 8.8.4.4"
client-to-client
keepalive 20 60
comp-lzo
max-clients 50
persist-key
persist-tun
status /var/log/openvpn.log
log-append /var/log/openvpn.log
log /var/log/openvpn.log
verb 3
mute 20
script-security 2
client-connect ./connect
client-disconnect ./disconnect
EOF

cat>>/etc/openvpn/tcp-461.conf<<EOF
local $1
port  461
proto tcp
dev tun
ca /etc/openvpn/easy-rsa/2.0/keys/ca.crt
cert /etc/openvpn/easy-rsa/2.0/keys/server.crt
key /etc/openvpn/easy-rsa/2.0/keys/server.key
dh /etc/openvpn/easy-rsa/2.0/keys/dh1024.pem
server 172.18.61.0 255.255.255.0

plugin ./openvpn-auth-pam.so openvpn
client-cert-not-required
username-as-common-name
push "redirect-gateway def1 bypass-dhcp"
push "dhcp-option DNS 8.8.8.8"
push "dhcp-option DNS 8.8.4.4"
client-to-client
keepalive 20 60
comp-lzo
max-clients 50
persist-key
persist-tun
status /var/log/openvpn.log
log-append /var/log/openvpn.log
log /var/log/openvpn.log
verb 3
mute 20
script-security 2
client-connect ./connect
client-disconnect ./disconnect
EOF


cat>>/etc/openvpn/tcp-462.conf<<EOF
local $1
port  462
proto tcp
dev tun
ca /etc/openvpn/easy-rsa/2.0/keys/ca.crt
cert /etc/openvpn/easy-rsa/2.0/keys/server.crt
key /etc/openvpn/easy-rsa/2.0/keys/server.key
dh /etc/openvpn/easy-rsa/2.0/keys/dh1024.pem
server 172.18.62.0 255.255.255.0

plugin ./openvpn-auth-pam.so openvpn
client-cert-not-required
username-as-common-name
push "redirect-gateway def1 bypass-dhcp"
push "dhcp-option DNS 8.8.8.8"
push "dhcp-option DNS 8.8.4.4"
client-to-client
keepalive 20 60
comp-lzo
max-clients 50
persist-key
persist-tun
status /var/log/openvpn.log
log-append /var/log/openvpn.log
log /var/log/openvpn.log
verb 3
mute 20
script-security 2
client-connect ./connect
client-disconnect ./disconnect
EOF


############# End Config ###############


/etc/init.d/openvpn restart


echo "OpenVPN Server is ready!!!!!"