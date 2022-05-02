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
echo "This script will download, compile and install Hamlib and Direwolf."
echo ""
echo "Do NOT run this on an existing HF Alerting system unless instructed to."
echo ""
read -p "Continue? (y/N) " answer
answer=${answer:0:1}
if [[ $answer == [Nn] ]]
then 
return
fi
if [ $# -eq 0 ]
then
    echo "First, let's gather the station call sign."
    echo ""
    read -p "Enter this station's VOICE call sign: " mycall
    if [[ $mycall =~ [A-Za-z0-9]{5,6} ]]
    then
    echo "Good callsign..."
    fi
else
    mycall=$1
fi
# make it upper case
mycall=${mycall^^}
START_TIME=$(date +%s)
mkdir -p ~/src
cd ~/src
#############################################
# Install required packages to a clean RPi OS box
sudo apt update
sudo apt upgrade -y
sudo apt autoremove -y
sudo apt install git dialog cmake libasound2-dev libudev-dev libtool dos2unix telnet mosquitto mosquitto-clients screen chrony gpsd gpsd-clients libgps-dev -y
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
cd ~/src/direwolf
git checkout dev
mkdir -p ~/src/direwolf/build && cd ~/src/direwolf/build && rm -fr ~/src/direwolf/build/*
patch -p 0 ~/src/direwolf/src/ptt.c ~/hfaconfig/dwptt.patch
# if either of these fails, the script stops
cmake .. && make -j3 
sudo make install 
# don't create boilerplate conf files for this because 
# we'll put our custom config files into it
# in another script later.
#make install-conf
# and rename it.  ours is created below
mv ~/direwolf.conf ~/direwolf.conf.example
# END Direwolf install
#############################################
echo "Setting up MQTT broker (mosquitto) on all localhost and bridge."
cd ~/hfaconfig
sudo cp -f mqdirewolf.conf /etc/mosquitto/conf.d/direwolf.conf
# just in case it got turned off somehow, it doesn't hurt to enable it
sudo systemctl enable mosquitto
# pick up the new configuration file
sudo systemctl restart mosquitto
cd ~
END_TIME=$(date +%s)
secs=$(( $END_TIME - $START_TIME ))
mins=$(( $secs / 60 ))
secs=$(( $secs % 60 ))
if [ $secs -lt 10 ]; then secs="0$secs"; fi
echo "TIME:$mins:$secs"
echo "It took $mins:$secs to do the cloning and compiling and installing."
wait 1
echo "Hamlib and Direwolf installation is complete."
echo "It's time to build the direwolf.conf file."
cd ~/hfaconfig
. ./SetupDirewolf.sh $mycall
