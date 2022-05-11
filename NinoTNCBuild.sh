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
git clone https://github.com/qt/qtmqtt.git -b 5.15.2
cd qtmqtt
mkdir build
cd build
qmake .. && make -j3
sudo make install
echo "Library installation is complete."
# MQTT is now installed and we can compile AlertManagerConsole
cd ~/src/
git clone git@192.168.0.151:/home/git/AlertManagerConsole.git
cd AlertManagerConsole
mkdir build
cd build
qmake .. && make -j3
mkdir ~/AlertManagerConsole
cp -f ./AlertManagerConsole ~/AlertManagerConsole/
echo "Alert Manager Console installation is complete."

END_TIME=$(date +%s)
secs=$(( $END_TIME - $START_TIME ))
mins=$(( $secs / 60 ))
secs=$(( $secs % 60 ))
if [ $secs -lt 10 ]; then secs="0$secs"; fi
echo "TIME:$mins:$secs"
echo "It took $mins:$secs to do the cloning and compiling and installing."
wait 1
#echo "It's time to build the direwolf.conf file."
return 0