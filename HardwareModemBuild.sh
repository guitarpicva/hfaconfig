#!/bin/bash
#############################################
# Author Mitch Winkle, AB4MW 2022-05-11 
#############################################
echo ""
echo ""
echo "This script will install necessary applications."
echo ""
echo ""

START_TIME=$(date +%s)
# mkdir -p ~/src
# cd ~/src/
# THIS CAN BE CHANGED TO A wget OF A tar.gz instead
# git clone git@192.168.0.151:/home/git/AlertManagerConsole.git
# cd AlertManagerConsole
# mkdir build
# cd build
# qmake .. && make -j3
mkdir -p ~/AlertManagerConsole
cp -f ~/hfaconfig/AlertManagerConsole ~/AlertManagerConsole/
chmod +x ~/AlertManagerConsole/AlertManagerConsole
#cp -f ~/hfaconfig/AlertManagerConsole.desktop ~/.local/share/applications
echo "Alert Manager Console installation is complete."
desktop=`grep /boot/issue.txt stage4`
if [ -z $desktop ]
then
    echo "Lite build"
else
    echo "Desktop build"
    mkdir -p ~/UIConnect
    cp -f ~/hfaconfig/UIConnect ~/UIConnect/
    chmod +x ~/UIConnect/UIConnect
    sed -i "s|XXXXX|$HOME|g" ~/UICOnnect/UIConnect.desktop
    cp -f ~/hfaconfig/UIConnect.desktop ~/Desktop
    echo "UI Connect installation is complete."
    sed -i "s|XXXXX|$HOME|g" ~/hfaconfig/HFAUpdate.desktop
    cp -f ~/hfaconfig/HFAUpdate.desktop ~/Desktop
    echo "HFA Update desktop icon installation is complete."
fi

# END THIS CAN BE CHANGED....

END_TIME=$(date +%s)
secs=$(( $END_TIME - $START_TIME ))
mins=$(( $secs / 60 ))
secs=$(( $secs % 60 ))
if [ $secs -lt 10 ]; then secs="0$secs"; fi
echo "TIME:$mins:$secs"
echo "It took $mins:$secs to do the cloning and compiling and installing."
wait 1
#echo "It's time to build the direwolf.conf file."
return 0