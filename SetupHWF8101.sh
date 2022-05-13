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

serial=$( ls /dev/serial/by-id|grep _B-if )
# ensure local folder holds the radio serial port link
sudo ln -fs /dev/serial/by-id/$serial $HOME/f8101_civ

# now we also know that the Nino TNC presents it's USB port
# as /dev/ttyACM0
#* * * * * /home/direwolf2/AlertManagerConsole/amcstart.sh >/dev/null 2>&1
# add a line to the crontab to auto-start/check direwolf each minute
# without fear of duplication in the crontab
croncmd="~/AlertManagerConsole/amcstart.sh"
cronjob="* * * * * $croncmd"
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
echo "Setup and Configuration of the HF Alerting HW Modem Station Complete....rebooting"
sudo reboot
