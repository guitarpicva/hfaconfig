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
echo "refclock SHM 0 offset 0.5 delay 0.2 refid NMEA" >> /etc/chrony/chrony.conf
# The gpsd-clients package is not really needed and avoids a lot of UI 
# stuff and python3 which are large and doesn't work on a headlyess Pi
# but it can safely be installed manually if the need arises for diagnostics
# regarding to the GPS receiver

# Usually the GPS USB device is /dev/ttyACM0 once plugged in
# NOTE: This will kill the existing gpsd file, so let's make a copy 
sudo cp /etc/default/gpsd /etc/default/gpsd.orig
sudo echo 'USBAUTO="true"' > /etc/default/gpsd
sudo echo 'DEVICES="/dev/ttyACM0"' >> /etc/default/gpsd
sudo echo 'GPSD_OPTIONS="-n"' >> /etc/default/gpsd
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
