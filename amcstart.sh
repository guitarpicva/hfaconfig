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

function GUI {
   # In this case
   # In my case, the Raspberry Pi is not connected to a monitor.
   # I access it remotely using VNC as described here:
   # http://learn.adafruit.com/adafruit-raspberry-pi-lesson-7-remote-control-with-vnc
   #
   # If VNC server is running, use its display number.
   # Otherwise default to :0 (the Xwindows on the HDMI display)
   #
   export DISPLAY=":0"

   #Reviewing for RealVNC sessions (stock in Raspbian Pixel)
   if [ -n "`ps -ef | grep vncserver-x11-serviced | grep -v grep`" ]; then
      sleep 0.1
      echo -e "\nRealVNC found - defaults to connecting to the :0 root window"
      elif [ -n "`ps -ef | grep Xtightvnc | grep -v grep`" ]; then
      #Reviewing for TightVNC sessions
      echo -e "\nTightVNC found - defaults to connecting to the :1 root window"
      v=`ps -ef | grep Xtightvnc | grep -v grep`
      d=`echo "$v" | sed 's/.*tightvnc *\(:[0-9]\).*/\1/'`
      export DISPLAY="$d"
   fi

   echo "Direwolf in GUI mode start up"
   echo "Direwolf in GUI mode start up" >> $LOGFILE
   echo "DISPLAY=$DISPLAY"
   echo "DISPLAY=$DISPLAY" >> $LOGFILE

   #
   # Auto adjust the startup for your particular environment:  gnome-terminal, xterm, etc.
   #

   if [ -x /usr/bin/lxterminal ]; then
      /usr/bin/lxterminal -t "Dire Wolf" -e "$AMCCMD" &
      SUCCESS=1
     elif [ -x /usr/bin/xterm ]; then
      /usr/bin/xterm -bg white -fg black -e "$AMCCMD" &
      SUCCESS=1
     elif [ -x /usr/bin/x-terminal-emulator ]; then
      /usr/bin/x-terminal-emulator -e "$AMCCMD" &
      SUCCESS=1
     else
      echo "Did not find an X terminal emulator.  Reverting to CLI mode"
      SUCCESS=0
   fi
   echo "-----------------------"
   echo "-----------------------" >> $LOGFILE
}

# -----------------------------------------------------------
# Main Script start
# -----------------------------------------------------------
# ensure that the CI-V serial port is created
# if the link is not there, make it again
#echo "Check and set "
# remove existing link not needed because we use ln -fs
#sudo rm -f $HOME/f8101_civ
serial=$( ls /dev/serial/by-id|grep _B-if )
# replace with current link as local user who is in dialout
ln -fs /dev/serial/by-id/$serial $HOME/f8101_civ

# When running from cron, we have a very minimal environment
# including PATH=/usr/bin:/bin.
#
export PATH=$HOME/AlertManagerConsole:$PATH

#Log the start of the script run and re-run
date >> $LOGFILE

sleep 3

#
# Nothing to do if AMC is already running.
#

a=`ps ax | grep $AMCCMD | grep -vi -e bash -e screen -e grep | awk '{print $1}'`
if [ -n "$a" ]
then
  #date >> /tmp/dw-start.log
  #echo "Alert Manager Console already running." >> $LOGFILE
  exit
fi

# Main execution of the script

if [ $RUNMODE == "AUTO" ];then
   GUI
   if [ $SUCCESS -eq 0 ]; then
      CLI
   fi
  elif [ $RUNMODE == "GUI" ];then
   GUI
  elif [ $RUNMODE == "CLI" ];then
   CLI
  else
   echo -e "ERROR: illegal run mode given.  Giving up"
   exit 1
fi
