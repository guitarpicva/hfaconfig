#!/bin/bash
########################################################################
# Shell script to do an automated update to the HF Alerting installation
# on a Linux host.  Updates Direwolf, Hamlib and configuration files as
# necessary to maintain a current HF Alerting station.
#
# Author, Mitch Winkle AB4MW 2022-04-23
########################################################################
# If not there, make it
#mkdir -p ~/hfaconfig
#cd ~
#git clone https://github.com/guitarpicva/hfaconfig.git
cd ~/hfaconfig
#
# This gives us all of the configuration files for our system in the
# ~/hfaconfig directory, which is where cron and other programs will
# find their configuration files (direwolf.conf, etc.)
#
# Show the list of existing files
ll
# Set all scripts to be executable
chmod +x *.sh
# Query the user to see if we need to do the first time compiling
answer="N"
read -p "Is this an initial installation on a clean RPi OS? (y/N) " answer
if [[ $answer == [Nn]* ]]
then
	echo "Existing HFA System....got it."
else 
	echo "New Install....got it."
	# Set some house-keeping
	echo "Set alias for ll to ls -lA in .bashrc"
	#echo "alias ll='ls -lA --color=auto'" >> ~/.bashrc
	echo "Starting sshd server..."
	sudo systemctl enable ssh
	sudo systemctl start sshd
	# Run the clone and compile script HamlibDirewolfBuild.sh
	~/hfaconfig/HamlibDirewolfBuild.sh
fi
exit 0