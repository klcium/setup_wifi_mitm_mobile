#!/bin/bash

INTERFACE="yourinterface"
BURP_PORT=8888
# Stopper les services hostapd et dnsmasq
echo "Arrêt des services hostapd et dnsmasq..."
systemctl stop hostapd
systemctl stop dnsmasq

# Supprimer les règles iptables
echo "Suppression des règles iptables..."

# Réinitialiser les règles iptables (supprimer les redirections et masquer les règles)
echo "Réinitialisation des règles iptables..."
sudo iptables -t nat -D PREROUTING -p tcp --dport 80 -j REDIRECT --to-port $BURP_PORT
sudo iptables -t nat -D PREROUTING -p tcp --dport 443 -j REDIRECT --to-port $BURP_PORT
sudo iptables -t nat -D POSTROUTING -o $INTERFACE -j MASQUERADE
sudo iptables -D FORWARD -i $INTERFACE -o $INTERFACE -j ACCEPT

sudo iptables -D INPUT -p udp --dport 53 -j ACCEPT
sudo iptables -D OUTPUT -p udp --sport 53 -j ACCEPT

sudo ip a flush $INTERFACE 
sudo pkill dnsmasq
echo "Point d'accès arrêté et services désactivés avec succès."

