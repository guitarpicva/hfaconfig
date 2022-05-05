#/bin/bash
# Used to configure a GPS dongle for use as a time standard
# and to feed position data to Direwolf
# It also configures chrony which seeks NTP sources first but reverts
# to GPS source ("NMEA" in "chronyc sources -v") when network is unavailable

#
# Also need to update /etc/default/gpsd
#############
sudo apt update
sudo apt install -y chrony gpsd libgps-dev 
## This line needs to be added to the /etc/chrony/chrony.conf at the end
#refclock SHM 0 offset 0.5 delay 0.2 refid NMEA
sudo echo "refclock SHM 0 offset 0.5 delay 0.2 refid NMEA" >> /etc/chrony/chrony.conf
# The gpsd-clients package is not really needed and avoids a lot of UI 
# stuff and python3 which are large and doesn't work on a headlyess Pi
# but it can safely be installed manually if the need arises for diagnostics
# regarding to the GPS receiver

# Usually the GPS USB device is /dev/ttyACM0 once plugged in
# NOTE: This will edit the existing std. gpsd file, so let's make a copy 
sudo cp /etc/default/gpsd /etc/default/gpsd.orig
sudo sed 's|DEVICES=\"\"|DEVICES=\"/dev/ttyACM0\"|g' /etc/default/gpsd
sudo sed 's|GPSD_OPTIONS=\"\"|GPSD_OPTIONS=\"-n\"|g' /etc/default/gpsd
#
#
# Now restart everything 
sudo systemctl restart gpsd
sudo systemctl restart chrony
#
# Direwolf needs a line to gather the position information
#echo "GPSD localhost" >> ~/direwolf.conf
# The config for Direwolf is also not really needed, since we are not
# doing APRS.
