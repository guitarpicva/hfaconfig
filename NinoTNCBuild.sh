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
echo "This script will download, compile and install necessary libraries."
echo ""
echo ""

START_TIME=$(date +%s)
mkdir -p ~/src
cd ~/src

#############################################
# START HAMLIB
# First, get Hamlib if required, comment out if not
# we want this installed first so direwolf picks up libhamlib
# so support will be compiled into direwolf
#git clone https://github.com/Hamlib/Hamlib.git
#cd ~/src/Hamlib
# if any of these fail, the script stops
#./bootstrap && ./configure && make -j3
#sudo make install
#sudo ldconfig
# END HAMLIB INSTALL
#############################################
# Direwolf installation
#cd ~/src
#git clone https://github.com/wb2osz/direwolf.git
# set to latest dev version to pick up GPS and other stuff
#cd ~/src/direwolf
#git checkout dev
#mkdir -p ~/src/direwolf/build
#cd ~/src/direwolf/build
#rm -fr ~/src/direwolf/build/*
#
######## THIS IS DANGEROUS ##########################
#sed -i 's/RIG_PTT_ON :/RIG_PTT_ON_DATA :/g' ~/src/direwolf/src/ptt.c
#####################################################
# if either of these fails, the script stops
#cmake .. && make -j3 
#sudo make install 
# don't create boilerplate conf files for this because 
# we'll put our custom config files into it
# in another script later.
#make install-conf
# and rename it.  ours is created below
#mv ~/direwolf.conf ~/direwolf.conf.example
# END Direwolf install
#############################################

cd ~
mkdir -p ~/src
git clone https://github.com/qt/qtmqtt.git -b 5.15.2
cd qtmqtt
mkdir build
cd build
qmake ../ && make -j3
sudo make install
# MQTT is now installed
END_TIME=$(date +%s)
secs=$(( $END_TIME - $START_TIME ))
mins=$(( $secs / 60 ))
secs=$(( $secs % 60 ))
if [ $secs -lt 10 ]; then secs="0$secs"; fi
echo "TIME:$mins:$secs"
echo "It took $mins:$secs to do the cloning and compiling and installing."
wait 1
echo "Library installation is complete."
#echo "It's time to build the direwolf.conf file."
return 0