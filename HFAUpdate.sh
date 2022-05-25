#!/bin/bash
# Update all of the scripts from github and
# give the user the option of which ones to run perhaps
#
cd ~/hfaconfig
# get any new stuff or changed stuff
git pull
# A script names "DoUpdates.sh" will be customized
# to run things that are necessary and do any house-keeping
~/hfaconfig/DoUpdates.sh

