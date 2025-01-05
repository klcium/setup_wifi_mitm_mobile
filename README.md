# Lab setup scripts

This repository is a test one.

It contains scripts to setup and stop an ALFA AWUS036ACM as an AP and route traffic to Burpsuite.

There are two scripts:
- `setup.sh` and `stop.sh` will proxy your 80 and 443 traffic on the 8888 port of burpsuite.
- `setup_no_mitm.sh` and `stop_no_mitm.sh` will forward all the traffic to your internet interface without proxying anything.

Proxy scripts probably not working atm.

# Requirements
```
sudo apt-get install hostapd dnsmasq iptables
```

# How to
Edit your iface in the appropriate setup and stop files.

# Warning
Backup your dnsmasq and hostapd conf files if you have any already set.
You've been warned.