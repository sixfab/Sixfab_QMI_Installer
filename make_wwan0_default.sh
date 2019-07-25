#!/bin/bash

LINE1='interface wwan0;'
LINE2='metric 200;'
FILE='/etc/dhcpcd.conf'

# Control dhcpcd.conf and add wwan0 metric to there if it doesn't exist already. 
if grep -q "interface wwan0;" /etc/dhcpcd.conf; then
    echo -e "Already exist"
else
    echo "$LINE1" >> "$FILE"
    echo "$LINE2" >> "$FILE"
    echo -e "Priority is given for wwan0 by added new metrics!"
fi
