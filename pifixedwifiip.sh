#!/bin/bash

if [[ -f /home/pi/Documents/pifixedwifiactive ]]; then
  echo "You have installed your pi fixed wifi already"
  exit 0;
fi

function changeIP() {
  local ipFinal=$1
  [ $# -eq 0 ] && { local ipFinal=210; }
  R_Gat=$(route -n | grep UG | tr -s ' ' | cut -d' ' -f2)
  R_Interface=$(route -n | grep UG | tr -s ' ' | cut -d' ' -f8)
  R_Mask=$(ifconfig | grep -m 1 $(route -n | grep UG | tr -s ' ' | cut -d' ' -f 2 | cut -d. -f1-3) | sed 's/.*Mask://')
  R_IP="$(route -n | grep UG | tr -s ' ' | cut -d' ' -f 2 | cut -d. -f1-3).$ipFinal"
  R_Network="$(route -n | grep UG | tr -s ' ' | cut -d' ' -f 2 | cut -d. -f1-3).0"
  R_Broad="$(route -n | grep UG | tr -s ' ' | cut -d' ' -f 2 | cut -d. -f1-3).255"

  sudo sh -c 'cat << EOF >> /etc/network/interfaces

  iface home inet static
  address $R_IP
  netmask $R_Mask
  gateway $R_Gat

  iface default inet dhcp
EOF'

  sudo sed -i 's/network={/&\n\tid_str="home"/' /etc/wpa_supplicant/wpa_supplicant.conf

  sudo touch /home/pi/Documents/pifixedwifiactive
}


changeIP
