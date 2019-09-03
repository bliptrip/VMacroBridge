#!/bin/bash

#Add following to /etc/cmdline.txt
sudo echo -n "ipv6.disable hid.ignore_special_drivers=1" > /boot/cmdline.txt

#Enable ssh and vnc
echo "Enabling ssh"
sudo raspi-config nonint do_ssh 0
echo "Enabling vnc server"
sudo raspi-config nonint do_vnc 0

#Change hostname
#Change hostname to default.
echo "Changing hostname."
sudo raspi-config nonint do_hostname "dronepi"

#Change default locale.
echo "Configure locale."
sudo raspi-config nonint do_change_locale "en_US.UTF-8"

#Change the timezone
sudo raspi-config nonint do_change_timezone "America/Chicago"

#Update to latest packages
sudo apt-get -y update
sudo apt-get -y upgrade

#Install a few packages I like to have on system
sudo apt-get -y install ctags vim screen tmux dnsmasq hostapd python-dev libxml2-dev libxslt-dev ipheth-utils usbmuxd

#Install pip dependencies
sudo pip install -U future lxml pygame PyYAML

#Configure as wireless access point
sudo cp dhcpcd.conf /etc/
sudo cp dnsmasq.conf /etc/
sudo cp hostapd.conf /etc/hostapd/
sudo cp hostapd /etc/default/
sudo systemctl unmask hostapd
sudo systemctl enable hostapd
#Enable ipv4 forwarding
sudo cp sysctl.conf /etc
#Setup firewall to do NAT
sudo cp iptables.ipv4.nat /etc/
sudo cp rc.local /etc/


#Prepare github directories and checkout and install
mkdir ~/Downloads/bliptrip
cd ~/Downloads/bliptrip
git clone https://github.com/bliptrip/mavlink.git
git clone https://github.com/bliptrip/pymavlink.git
git clone https://github.com/bliptrip/MAVProxy.git
git clone https://github.com/bliptrip/ds4drv.git

#Install ds4drv
cd ds4drv/
sudo pip install .
sudo cp systemd/ds4drv.service /lib/systemd/system/
sudo systemctl enable ds4drv
sudo cp udev/50-ds4drv.rules /etc/udev/rules.d
#Blacklist hid_sony linux kernel driver as we don't want it overriding our ps4 driver
sudo echo -n "blacklist hid_sony" > /etc/modprobe.d/raspi-blacklist.conf
cd ..

#Install pymavlink manually with latest mavlink definition files to get full Mavlink 2.0 extension support
cd pymavlink
sudo su -c 'MDEF=/home/pi/Downloads/bliptrip/mavlink/message_definitions pip install . -v'
cd ..

#Install my modifications to MAVProxy to support more than 8 channel RC override and my fake ps4 controller
cd MAVProxy
sudo pip install .
#Install mavgateway service file and my joystick definitions
mkdir -p /home/pi/.config/mavproxy/joysticks/
mkdir -p /home/pi/.mavproxy
mkdir -p /home/pi/.mavproxy/bliptrip
cp MAVProxy/modules/mavproxy_joystick/joysticks/sony-dualshock-ps4.yml /home/pi/.config/mavproxy/joysticks/
sudo cp systemd/mavgateway.service /lib/systemd/system/
sudo systemctl enable mavgateway
cd ..

#Update to latest


