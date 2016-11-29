#!/bin/bash

#install packages
echo -e "install system packages"
apt-get -y install pptpd mysql-client libmysqlclient-dev
#apt-get -y install apache2 

mknod /dev/ppp c 108 0
#/etc/init.d/freeradius stop
/etc/init.d/pptpd stop
#/etc/init.d/apache2 stop

mkdir -p /usr/local/etc/radiusclient
cp -raf etc-ppp/*         /etc/ppp/
cp -raf usr-local-etc-radiusclient/*  /usr/local/etc/radiusclient/
cp -af  etc-pptpd.conf  /etc/pptpd.conf
#cp -raf etc-freeradius/*  /etc/freeradius/

#chown freerad  /etc/freeradius
#chmod u+x      /etc/freeradius

chmod o+r      /var/log/syslog
#chmod o+r,o+x  /var/log/freeradius
#chmod o+r      /var/log/freeradius/radius.log

/etc/init.d/pptpd start