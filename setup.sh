#!/bin/bash

INTERFACE="your_in_interface"
SSID="yourwifibssid"
PASS="yourwifipwd"
IP_RANGE="192.168.10.10,192.168.10.50"
NETMASK="255.255.255.0"
BURP_PORT=8888
LISTENADDR="192.168.10.3"

# Créer le fichier de configuration pour hostapd
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

# Configurer dnsmasq pour le DHCP
echo "Création du fichier de configuration pour dnsmasq..."
cat <<EOL > /etc/dnsmasq.conf
interface=$INTERFACE
dhcp-range=$IP_RANGE,$NETMASK,12h
dhcp-option=252,"http://$LISTENADDR:$BURP_PORT"
EOL

# Modifier le fichier /etc/default/hostapd pour spécifier la config
echo "Modification de /etc/default/hostapd..."
sed -i 's|#DAEMON_CONF=""|DAEMON_CONF="/etc/hostapd/hostapd.conf"|' /etc/default/hostapd

	# Démarrer les services hostapd et dnsmasq
echo "Démarrage de hostapd et dnsmasq..."
ifconfig $INTERFACE  192.168.10.3 netmask 255.255.255.0 up
systemctl start hostapd
systemctl start dnsmasq

# Configurer iptables pour intercepter le trafic sans impact sur les autres interfaces
echo "Configuration d'iptables pour intercepter le trafic sans affecter les autres interfaces..."

# Rediriger le trafic HTTP/HTTPS vers Burp Suite (port 8888)
echo "Redirection du trafic HTTP et HTTPS vers Burp Suite (port $BURP_PORT)..."
sudo iptables -t nat -A PREROUTING -p tcp --dport 80 -j REDIRECT --to-port $BURP_PORT  # Rediriger HTTP
sudo iptables -t nat -A PREROUTING -p tcp --dport 443 -j REDIRECT --to-port $BURP_PORT  # Rediriger HTTPS
sudo iptables -A INPUT -p udp --dport 53 -j ACCEPT
sudo iptables -A OUTPUT -p udp --sport 53 -j ACCEPT
# Permettre le trafic local (sinon les clients n'auront pas accès au réseau interne)
sudo iptables -A FORWARD -i $INTERFACE -o $INTERFACE -j ACCEPT

# Masquer les paquets en sortie pour simuler un NAT (sinon, les clients ne pourront pas accéder à Internet)
sudo iptables -t nat -A POSTROUTING -o $INTERFACE -j MASQUERADE

echo "Point d'accès configuré et démarré avec succès !"

