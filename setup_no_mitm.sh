#!/bin/bash

INTERFACE="your_in_iface"
OUT_INTERFACE="your_out_iface"
SSID="yourwifibssid"
PASS="yourwifipwd"
IP_RANGE="192.168.10.10,192.168.10.50"
NETMASK="255.255.255.0"
BURP_PORT=8888
LISTENADDR="192.168.10.3"

# HOSTAPD setup
echo "Création du fichier de configuration pour hostapd..."
cat <<EOL > /etc/hostapd/hostapd.conf
interface=$INTERFACE
driver=nl80211
ssid=$SSID
hw_mode=g
channel=6
auth_algs=1
wpa=2
wpa_passphrase=$PASS
EOL

# DNS & DHCP
echo "Overwriting dnsmasq config"
cat <<EOL > /etc/dnsmasq.conf
interface=$INTERFACE
dhcp-range=$IP_RANGE,$NETMASK,12h
server=8.8.8.8
EOL

# HOSTAPD
echo "Update config /etc/default/hostapd..."
sed -i 's|#DAEMON_CONF=""|DAEMON_CONF="/etc/hostapd/hostapd.conf"|' /etc/default/hostapd

# Start services hostapd et dnsmasq
echo "Starting hostapd and dnsmasq..."
ifconfig $INTERFACE  192.168.10.3 netmask 255.255.255.0 up
systemctl start hostapd
systemctl start dnsmasq

# ip frwd
echo "Enabling packet forwarding"
sysctl -w net.ipv4.ip_forward=1

# Enable traffic forwarding
echo "Setup iptables"
sudo iptables -A FORWARD -i $INTERFACE -o $OUT_INTERFACE -j ACCEPT
sudo iptables -t nat -A POSTROUTING -o $OUT_INTERFACE -j MASQUERADE
sudo iptables -A FORWARD -i $OUT_INTERFACE -o $INTERFACE -m state --state ESTABLISHED,RELATED -j ACCEPT

echo "No MITM traffic forwarding set !"