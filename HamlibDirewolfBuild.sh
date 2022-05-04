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
mkdir -p ~/src/direwolf/build
cd ~/src/direwolf/build
rm -fr ~/src/direwolf/build/*
#
######## THIS IS DANGEROUS ##########################
sed -i 's/RIG_PTT_ON :/RIG_PTT_ON_DATA :/g' ~/src/direwolf/src/ptt.c
#####################################################
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
return 0