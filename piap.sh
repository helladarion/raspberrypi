#!/bin/bash

# Verifying if we can run the program
if [[ -f /home/pi/Documents/apactive ]]; then
  echo "You have installed your pi ap already"
  exit 0;
fi

# Update repository
sudo apt-get update
# Download the required packages
sudo apt-get install -y dnsmasq hostapd

# configuring dhcpcd to ignore the interface
sudo echo "denyinterfaces wlan0" >> /etc/dhcpcd.conf
# configuring interfaces
#sudo nano /etc/network/interfaces
sudo sed -i 's/iface wlan0 inet /&static\n\taddress 172.24.1.1\n\tnetmask 255.255.255.0\n\tnetwork 172.24.1.0\n\tbroadcast 172.24.1.255/;s/255manual/255/;0,/wpa-conf/{s/wpa-conf/\#&/}' /etc/network/interfaces
# restarting the services
sudo service dhcpcd restart
sudo ifdown wlan0; sudo ifup wlan0
# Creating file hostapd
cat << "EOF" | sudo tee /etc/hostapd/hostapd.conf
# This is the name of the WiFi interface we configured above
interface=wlan0

# Use the nl80211 driver with the brcmfmac driver
driver=nl80211

# This is the name of the network
ssid=Pi3-AP

# Use the 2.4GHz band
hw_mode=g

# Use channel 6
channel=6

# Enable 802.11n
ieee80211n=1

# Enable WMM
wmm_enabled=1

# Enable 40MHz channels with 20ns guard interval
ht_capab=[HT40][SHORT-GI-20][DSSS_CCK-40]

# Accept all MAC addresses
macaddr_acl=0

# Use WPA authentication
auth_algs=1

# Require clients to know the network name
ignore_broadcast_ssid=0

# Use WPA2
wpa=2

# Use a pre-shared key
wpa_key_mgmt=WPA-PSK

# The network passphrase
wpa_passphrase=raspberry

# Use AES, instead of TKIP
rsn_pairwise=CCMP
EOF

# Include the file on the startup
sudo sed -i 's/\#DAEMON_CONF=""/DAEMON_CONF="\/etc\/hostapd\/hostapd.conf"/' /etc/default/hostapd

# Adjusting dnsmasq file
sudo mv /etc/dnsmasq.conf /etc/dnsmasq.conf.orig
cat << "EOF" | sudo tee /etc/dnsmasq.conf
interface=wlan0      # Use interface wlan0
listen-address=172.24.1.1 # Explicitly specify the address to listen on
bind-interfaces      # Bind to the interface to make sure we aren't sending things elsewhere
server=8.8.8.8       # Forward DNS requests to Google DNS
domain-needed        # Don't forward short names
bogus-priv           # Never forward addresses in the non-routed address spaces.
dhcp-range=172.24.1.50,172.24.1.150,12h # Assign IP addresses between 172.24.1.50 and 172.24.1.150 with a 12 hour lease time
EOF

# Here you can access your raspberry from outside, just enable vnc and ssh and restart your raspberry

# Making sure to not run the program again
sudo touch /home/pi/Documents/apactive
