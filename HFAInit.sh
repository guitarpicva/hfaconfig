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
cd ~/hfaconfig
#
# This gives us all of the configuration files for our system in the
# ~/hfaconfig directory, which is where cron and other programs will
# find their configuration files (direwolf.conf, etc.)
#
# Show the list of existing files
ls -lA --color=auto
# Set all scripts to be executable
chmod u+x *.sh
# Query the user to see if we need to do the first time compiling
read -p "Is this an initial installation on a clean RPi OS? (y/N) " answer
# only take the first letter of the reply
answer=${answer:0:1}
#echo "answer is $answer"
if [[ $answer == [Nn] || -z $answer ]]
then
	echo "Existing HFA System....got it."
	echo ""
	echo "This is where we would copy over new config files, alerts files, etc"
	echo "with an update script."
elif [[ $answer == [Yy] ]]
then
	echo "New Install....got it."
	# Set some house-keeping
	echo "Set alias for ll to ls -lA in .bashrc"
	#echo "alias ll='ls -lA --color=auto'" >> ~/.bashrc
	echo "Turn off bcm audio and HDMI audio"
	bmcline=grep /boot/config.txt 'dtparam=audio=on'
	echo "BCM Audio Setting: $bcmline"
	bcmline=${bcmline:0:1}
	if [[ $bcmline != [#] ]]
	then
	# use sed to remove the leading "#" from dtparam audio=off
	sudo sed -i 's/dtparam=audio=on/#dtparam=audio=on/g' /boot/config.txt
	fi
	# append a line to turn off the HDMI audio since it will never be used
	# in a headless RPi
	# first delete any existing line
	sudo sed -i '/dtoverlay=vc4-kms-v3d/d' /boot/config.txt
	sudo sed -i '$a dtoverlay=vc4-kms-v3d,audio=off' /boot/config.txt
	echo "Enabling and Starting sshd server..."
	sudo systemctl enable ssh
	sudo systemctl start sshd

	# Run the clone and compile script HamlibDirewolfBuild.sh
	~/hfaconfig/HamlibDirewolfBuild.sh
fi
