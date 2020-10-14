#!/bin/bash 
# Reduced version does not install PS4 userspace driver and does not install as wifi access point.
#Install important bash rc files
cp .bashrc /home/pi/
cp .bash_aliases /home/pi/
sudo su -c 'echo "source /home/pi/.bashrc" >> /root/.bashrc'
sudo su -c 'echo "source /root/.bashrc" >> /root/.bash_profile'

cp -r .vim /home/pi
cp .vimrc /home/pi

#Enable ssh
echo "Enabling ssh"
sudo raspi-config nonint do_ssh 0

#Change default locale.
echo "Configure locale."
sudo raspi-config nonint do_change_locale "en_US.UTF-8"

#Change the timezone
sudo raspi-config nonint do_change_timezone "America/Chicago"

#Update to latest packages
sudo apt-get -y update
sudo apt-get -y upgrade

#Install a few packages I like to have on system
sudo apt-get -y install ctags vim screen python-pip python-dev libxml2-dev libxslt-dev git

#Install pip dependencies
sudo pip install -U future lxml pygame PyYAML

##Configure as wireless access point
#Prepare github directories and checkout and install
mkdir -p ~/Downloads/bliptrip
cd ~/Downloads/bliptrip
git clone https://github.com/bliptrip/mavlink.git
git clone https://github.com/bliptrip/pymavlink.git
git clone https://github.com/bliptrip/MAVProxy.git

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
cp MAVProxy/modules/mavproxy_joystick/joysticks/*.yml /home/pi/.config/mavproxy/joysticks/
sudo cp systemd/mavgateway.service /lib/systemd/system/
sudo systemctl enable mavgateway
cd ..

