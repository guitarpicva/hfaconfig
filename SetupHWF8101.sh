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
# now for first transmit minute
    echo "What is the minute of your first hourly transmissioN?"
    echo ""
    read -p "Enter this station's first transmission minute: " timeone
    if [[ $timeone =~ [0-9]{1,2} ]]
    then
        echo "Good Numeral, thank you."
    else
        echo "Bad Numeral...using default of 17th minute."
        timeone=17
    fi
timetwo=$((timeone+30))
echo "Second transmission at: $timetwo"
# now we can use the call sign to create or overwrite 
# a boilerplate for AlertManager.ini
INI=~/AlertManagerConsole/AlertManager.ini
echo "[General]" > $INI
echo "heardList=" >> $INI
echo "firstChannelName=14854000" >> $INI
echo "secondChannelName=4955500" >> $INI
echo "firstTxTime=$timeone" >> $INI
echo "secondTxTime=$timetwo" >> $INI
echo "mycall=$mycall" >> $INI
echo "tactical=" >> $INI
echo "tcp_address=localhost" >> $INI
echo "tcp_port=8001" >> $INI
echo "useZULUTime=true" >> $INI
echo "alertBeaconEnabled=true" >> $INI
echo "mqttHost=rpi0.homeip.net" >> $INI
echo "mqttPort=8883" >> $INI
echo "radioSerialPort=$HOME/f8101_civ" >> $INI

serial=$( ls /dev/serial/by-id|grep _B-if )
# ensure local folder holds the radio serial port link
sudo ln -fs /dev/serial/by-id/$serial $HOME/f8101_civ

# now we also know that the Nino TNC presents it's USB port
# as /dev/ttyACM0
#* * * * * /home/direwolf2/AlertManagerConsole/amcstart.sh >/dev/null 2>&1
# add a line to the crontab to auto-start/check direwolf each minute
# without fear of duplication in the crontab
croncmd="~/AlertManagerConsole/amcstart.sh"
cronjob="* * * * * $croncmd > /dev/null 2>&1"
( crontab -l | grep -v -F "$croncmd" ; echo "$cronjob" ) | crontab -
#
chmod +x ~/AlertManagerConsole/amcstart.sh

# add a line to the crontab to auto-start/check direwolf each minute
# without fear of duplication in the crontab
#croncmd="~/hfaconfig/dw-start.sh"
#cronjob="* * * * * $croncmd"
#( crontab -l | grep -v -F "$croncmd" ; echo "$cronjob" ) | crontab -
#
#chmod +x ~/hfaconfig/dw-start.sh 
echo "Setup and Configuration of the HF Alerting"
echo "HW Modem Station Complete....rebooting"
sudo reboot
