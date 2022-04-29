#!/bin/bash
if [ $# -eq 0 ]
then
    echo "First, let's gather the station call sign."
    echo ""
    read -p "Enter this station's VOICE call sign: " mycall
    if [[ $mycall =~ [A-Za-z0-9]{5,6} ]]
    then
        echo "Good Call Sign"
    else
        echo "Bad Call Sign...giving up"
        return
    fi
else
    mycall=$1
fi
# make it upper case
mycall=${mycall^^} 
# it's a fair bet that the F8101 is the only sound card 
# connected with this signature
sounders=$( aplay -l|grep 'USB Audio CODEC' )
sounders=${sounders:5:1}

serial=$( ls /dev/serial/by-id|grep _B-if00 )
cd ~
sudo rm -f /dev/f8101_civ
sudo ln -fs /dev/serial/by-id/$serial /dev/f8101_civ

echo "ADEVICE  plughw:$sounders,0" > ~/direwolf.conf
echo "CHANNEL 0" >> ~/direwolf.conf
echo "MYCALL $mycall" >> ~/direwolf.conf
echo "MODEM 300 1600:1800 3@20" >> ~/direwolf.conf
# "radio" corresponds to a symlink in the home
# folder which points to the proper device from
# /dev/serial/by-id
echo "PTT RIG 3086 /dev/f8101_civ 38400" >> ~/direwolf.conf
# a short TXDELAY of 30 ms
echo "TXDELAY 3" >> ~/direwolf.conf
# turn off the AGWPORT
echo "AGWPORT 0" >> ~/direwolf.conf
# set the port number for KISS
echo "KISSPORT 8001" >> ~/direwolf.conf
#
echo "Setup and Configuration of the HF Alerting Station Complete....rebooting"
sudo reboot
