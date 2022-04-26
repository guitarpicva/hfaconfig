#!/bin/bash
#############################################
# Hamlib-Direwolf latest builds for RPi2/3/4
#
# This script is intended for a clean
# RPi OS installation with no previous
# changes made to it.  This will run
# on an RPi OS Lite version (headless), and 
# that is the intended purpose, so even the 
# RPi2 B+ may be used.
# Author Mitch Winkle, AB4MW 2022-04-22
#############################################
echo "This script will download and install Hamlib and Direwolf, and compile them both."
echo ""
echo "Do NOT run this on an existing HF Alerting system unless instructed to."
echo ""
read -p "Continue? (y/N) " answer
answer=${answer:0:1}
if [[ $answer == [Nn] ]]
then 
return
fi
START_TIME=$(date +%s)
mkdir -p ~/src
cd ~/src
#############################################
# Install required packages to a clean RPi OS box
sudo apt update
sudo apt upgrade -y
sudo apt autoremove -y
sudo apt install build-essential git cmake libasound2-dev libudev-dev libtool dos2unix telnet mosquitto mosquitto-clients -y
#############################################
# START HAMLIB
# First, get Hamlib if required, comment out if not
# we want this installed first so direwolf picks up libhamlib
# so support will be compiled into direwolf
git clone https://github.com/Hamlib/Hamlib.git
cd ~/src/Hamlib
# if any of these fail, the script stops
./bootstrap && ./configure && make -j3
sudo make install
sudo ldconfig
# END HAMLIB INSTALL
#############################################
# Direwolf installation
cd ~/src
git clone https://github.com/wb2osz/direwolf.git
# set to latest dev version to pick up GPS and other stuff
git checkout dev
cd ~/src/direwolf
mkdir ~/src/direwolf/build && cd ~/src/direwolf/build
# if either of these fails, the script stops
cmake .. && make -j3 
sudo make install
# create the boilerplate configuration file in the home directory
make install-conf
# and rename it.  ours is created below
mv ~/direwolf.conf ~/direwolf.conf.example
# END Direwolf install
#############################################
# Cleanup
#############################################
cd ~
END_TIME=$(date +%s)
echo "It took $(($END_TIME - $START_TIME)) seconds to do this work!"
wait 1
echo "Direwolf installation is complete.  It's time to build the direwolf.conf file."
echo "Creating Direwolf configuration file."
echo "First, let's gather the station call sign."
echo ""
read -p "Enter this station's VOICE call sign: " mycall
if [[ $mycall =~ [A-Za-z0-9]{5,6} ]]
then
# makei it upper case
mycall=${mycall^^}
fi
# it's a fair bet that the F8101 is the only sound card
# connected and the only one with this signature
$sounders=$( aplay -l|grep 'USB Audio CODEC' )
sounders=${sounders:5:1}

serial=$( ls /dev/serial/by-id|grep '_B-if00' )
cd ~
ln -s /dev/serial/by-id/$serial ~/modem

echo "ADEVICE  plughw:$sounders,0" > ~/direwolf.conf
echo "CHANNEL 0" >> ~/direwolf.conf
echo "MYCALL $mycall" >> ~/direwolf.conf
echo "MODEM 300" >> ~/direwolf.conf
# "modem" corresponds to a symlink in the home
# folder which points to the proper device from
# /dev/serial/by-id
echo "PTT RIG 3086 modem" >> ~/direwolf.conf
# a short TXDELAY of 30 ms
echo "TXDELAY 3" >> ~/direwolf.conf
# turn off the AGWPORT
echo "AGWPORT 0" >> ~/direwolf.conf
# set the port number for KISS
echo "KISSPORT 8001" >> ~/direwolf.conf
# the end
exit 0