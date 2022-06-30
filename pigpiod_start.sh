#!/bin/bash
# Run this from crontab periodically to start up AMC
# add any config params to this line
AMC="sudo pigpiod"
AMCCMD="$AMC"
#Where will logs go - needs to be writable by non-root users
# Put the log in the home folder so it's easy to find
LOGFILE=~/pigpiod_start.log
# Nothing to do if it is already running.
a=`ps ax | grep $AMCCMD | grep -vi -e bash -e grep | awk '{print $1}'`
if [ -z "$a" ]
then
  echo "restarting pigpiod"
else
  exit 0
fi
#Log the start of the script run and re-run
date >> $LOGFILE
sleep 1
# Main execution of the startup scripting
$AMC