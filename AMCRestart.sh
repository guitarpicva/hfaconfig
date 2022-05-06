#!/bin/bash
# Restart the Alert Manager Console program
sudo killall AlertManagerConsole
sleep 3
~/AlertManagerConsole/AlertManagerConsole &
exit 0 
