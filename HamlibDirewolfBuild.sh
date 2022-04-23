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
#
# Author Mitch Winkle, AB4MW 2022-04-22
#############################################
echo "This script will download and install Hamlib and Direwolf, and compile them both."
echo ""
echo "Do NOT run this on an existing HF Alerting system unless instructed to."
echo ""
answer="N"
read -p "Continue? (y/N) " answer
if [[ $answer == [Nn]* ]]
then 
exit 0
fi
START_TIME=$(date +%s)
mkdir -p ~/src
cd ~/src
#############################################
# Install required packages to a clean RPi OS box
sudo apt update
sudo apt upgrade -y
sudo apt autoremove -y
sudo apt install build-essential git cmake libasound2-dev libudev-dev libtool dos2unix telnet mosquitto -y
#############################################
# START HAMLIB
# First, get Hamlib if required, comment out if not
# we want this installed first so direwolf picks up libhamlib
# so support will be compiled into direwolf
git clone https://github.com/Hamlib/Hamlib.git
cd ~/src/Hamlib
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
cmake ..
make -j3
sudo make install
make install-conf
# END Direwolf install
#############################################
#
#############################################
# Start configuration into the home directory
cd ~/src
git clone https://github.com/guitarpicva/hfaconfig.git
# This gives a base set of configuration files which can be
# manipulated by configuration scripts also included in this
# repository.  A 'git fetch' can be used to get the latest
# and then run a specified script to update everything
# appropriately.
#############################################
echo "Direwolf installation is complete.  It's time to edit the direwolf.conf file."
echo ""
cd ~
echo "Use \"nano direwolf.conf\" to edit the file."
END_TIME=$(date +%s)
echo "It took $(($END_TIME - $START_TIME)) seconds to do this work!"
exit 0

