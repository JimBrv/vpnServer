#!/bin/bash

# install packages
echo -e "install system packages"
apt-get install apache2 php5 php-pear phpmyadmin freeradius freeradius-mysql pptpd
pear install DB


mknod /dev/ppp c 108 0

echo -e "insert radius Database"
mysql -proot < radius.sql

#stop process
echo -e "stopping freeradius, pptp..."
/etc/init.d/freeradius stop
/etc/init.d/pptpd stop
/etc/init.d/apache2 stop


# copy config files
echo -e "copy config files to right loction"
mkdir -p /rop/radius
mkdir -p /usr/local/etc/radiusclient

cp -raf daloradius        /rop/radius/
cp -raf etc-freeradius/*  /etc/freeradius/
cp -raf etc-ppp/*         /etc/ppp/
cp -raf usr-local-etc-radiusclient/*  /usr/local/etc/radiusclient/
cp -af  etc-pptpd.conf  /etc/pptpd.conf

# note: freeradius has strict permissions, make it happy.
chown freerad  /etc/freeradius
chmod u+x      /etc/freeradius
chown www-data /rop/radius -R
chgrp www-data /rop/radius -R

# note: make dalo read log file
chmod o+r      /var/log/syslog
chmod o+r,o+x  /var/log/freeradius
chmod o+r      /var/log/freeradius/radius.log


cp -af  apache2-ports.conf /etc/apache2/ports.conf
cp -af  apache2-daloradius /etc/apache2/sites-available/
ln -sf  /etc/apache2/sites-available/apache2-daloradius /etc/apache2/sites-enabled/001-daloradius


echo -e "flush netfilter rule..."
./vpn-iptable.sh


#start process
echo -e "restarting freeradius, pptp process"
/etc/init.d/freeradius start
/etc/init.d/pptpd start
/etc/init.d/apache2 start

echo -e "all done, enjoy your VPN"

