#!/bin/bash

echo "1">/proc/sys/net/ipv4/ip_forward
iptables -t nat -A POSTROUTING -s 172.18.0.0/16 -j SNAT --to-source $1
iptables -t nat -A PREROUTING -p udp -m udp --dport 53 -j DNAT --to-destination 8.8.8.8
