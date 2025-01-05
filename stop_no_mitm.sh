#!/bin/bash

INTERFACE="your_in_iface"
OUT_INTERFACE="your_out_iface"
BURP_PORT=8888

# Stopper les services hostapd et dnsmasq
echo "Stopping services hostapd and dnsmasq..."
systemctl stop hostapd
systemctl stop dnsmasq

# Pckt forwrding
echo "Disabling packet forwarding"
sysctl -w net.ipv4.ip_forward=0

# Enable traffic forwarding
echo "Removing iptables rules"
sudo iptables -D FORWARD -i $INTERFACE -o $OUT_INTERFACE -j ACCEPT
sudo iptables -t nat -D POSTROUTING -o $OUT_INTERFACE -j MASQUERADE
sudo iptables -D FORWARD -i $OUT_INTERFACE -o $INTERFACE -m state --state ESTABLISHED,RELATED -j ACCEPT



sudo ip a flush $INTERFACE 
sudo pkill dnsmasq
echo "AP stopped and services disabled avec succès."

