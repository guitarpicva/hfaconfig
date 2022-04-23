#!/bin/bash
########################################################################
# Shell script to do an automated update to the HF Alerting installation
# on a Linux host.  Updates Direwolf, Hamlib and configuration files as
# necessary to maintain a current HF Alerting station.
#
# Author, Mitch Winkle AB4MW 2022-04-23
########################################################################
# If not there, make it
mkdir -p ~/hfaconfig
cd ~
git clone https://github.com/guitarpicva/hfaconfig.git
cd ~/hfaconfig
# Show the list of files
ls -lA --color=auto
#
# This gives us all of the configuration files for our system in the
# ~/hfaconfig directory, which is where cron and other programs will
# find their configuration files (direwolf.conf, etc.)
#
# Add a line to see if git fetch works
