#!/bin/bash

# Run this from crontab periodically to start up AMC

#  CLI mode is suited for say a Raspberry Pi running the Jessie LITE version
#  where it will run from the CLI w/o requiring Xwindows - requires screen

RUNMODE=CLI

# Location of the direwolf binary.  Depends on $PATH as shown.
# change this if you want to use some other specific location.
# e.g.  AMC="$HOME/AlertManagerConsole/AlertManagerConsole"

AMC="$HOME/AlertManagerConsole/AlertManagerConsole"


#Direwolf start up command :: Uncomment only one of the examples.
#
# 1. For normal operation as TNC, digipeater, IGate, etc.
#    Print audio statistics each 100 seconds for troubleshooting.
#    Change this command to however you wish to start Direwolf

# run this instance in IL2P mode on transmit!!!!
AMCCMD="$AMC"

#Where will logs go - needs to be writable by non-root users
# Put the log in the home folder so it's easy to find
LOGFILE=~/amcstart.log


#-------------------------------------
# Main functions of the script
#-------------------------------------

#Status variables
SUCCESS=0

function CLI {
   SCREEN=`which screen`
   if [ $? -ne 0 ]; then
      echo -e "Error: screen is not installed but is required for CLI mode."
      echo "Install screen with \"sudo apt install screen -y\""
      echo "Aborting"
      exit 1
   fi

   echo "AMC in CLI mode start up"
   echo "AMC in CLI mode start up" >> $LOGFILE

   # Screen commands
   #  -d m :: starts the command in detached mode
   #  -S   :: name the session
   cd ~/AlertManagerConsole
   $SCREEN -dmS amc $AMCCMD >> $LOGFILE
   SUCCESS=1

   $SCREEN -list amc
   $SCREEN -list amc >> $LOGFILE

   echo "-----------------------"
   echo "-----------------------" >> $LOGFILE
}


# -----------------------------------------------------------
# Main Script start
# -----------------------------------------------------------
# ensure that the CI-V serial port is created
# if the link is not there, make it again
echo "Check and set radio serial link in home folder,"
echo "and start AlertManagerConsole if not already running."
#
# Nothing to do if AMC is already running.
#

a=`ps ax | grep $AMCCMD | grep -vi -e bash -e screen -e grep | awk '{print $1}'`
if [ -z "$a" ]
then
  echo "restarting AMC"
else
  #date >> /tmp/dw-start.log
  #echo "Alert Manager Console already running." >> $LOGFILE
  exit 0
fi

# Better be plugged in!!!
# remove existing link not needed because we use ln -fs
sudo rm -f "$HOME/f8101_civ"
serial=$( ls /dev/serial/by-id|grep _B-if )
# replace with current link as local user who is in dialout
ln -fs /dev/serial/by-id/$serial $HOME/f8101_civ

# now deal with the Nino modem
# Better be plugged in!!!
sudo rm -f "$HOME/modem"
modem=$( ls /dev/serial/by-id|grep 2221 )
ln -fs /dev/serial/by-id/$modem $HOME/modem

# When running from cron, we have a very minimal environment
# including PATH=/usr/bin:/bin.
#
# Don't need this because full path is at the top
#export PATH=$HOME/AlertManagerConsole:$PATH

#Log the start of the script run and re-run
date >> $LOGFILE
sleep 1
# Main execution of the startup scripting
CLI