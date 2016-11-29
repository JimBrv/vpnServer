#!/bin/bash

### Add mysql remote auth
mysql -p -e "grant all on openvpn.* to openvpn@'$1' identified by 'openvpn'"
mysql -p -e "grant all on radius.* to openvpn@'$1' identified by 'openvpn'"

### Add radius auth client
cat >>/etc/freeradius/clients.conf<<EOF
client $1 {
      ipaddr = $1
      secret = RopVPN
      nastype = other
}
EOF