#!/bin/bash

: '
QMI installation script by Sixfab
Created By Metin Koc, Nov 2018
Modified by Saeed Johar,Yasin Kaya, June 2019
'

YELLOW='\033[1;33m'
RED='\033[0;31m'
SET='\033[0m'

INS_DIR=/opt/qmi_files
mkdir -p $INS_DIR

# clean old installation for new one. 
systemctl stop qmi_reconnect.service
systemctl disable qmi_reconnect.service
if [ -d "/home/pi/files" ]; then rm -rf /home/pi/files ; fi # for old directory
if [ -d "$INS_DIR" ]; then rm -rf $INS_DIR; fi


echo -e "${YELLOW}Change directory to $INS_DIR ${SET}"
pushd $INS_DIR

echo -e "${YELLOW}Downloading source files${SET}"
wget https://github.com/sixfab/Sixfab_RPi_3G-4G-LTE_Base_Shield/raw/master/tutorials/QMI_tutorial/src/quectel-CM.zip
unzip quectel-CM.zip -d $INS_DIR && rm -r quectel-CM.zip


#echo -e "${YELLOW}Updating rpi${SET}"
#apt update

#echo -e "${YELLOW}Downlading kernel headers${SET}"
#apt install raspberrypi-kernel-headers
echo -e "${YELLOW}Checking Kernel${SET}"

case $(uname -r) in
    4.14*) echo $(uname -r) based kernel found
        echo "${YELLOW}Downloading source files${SET}"
        wget https://github.com/sixfab/Sixfab_RPi_3G-4G-LTE_Base_Shield/raw/master/tutorials/QMI_tutorial/src/4.14.zip -O drivers.zip
        unzip drivers.zip -d $INS_DIR && rm -r drivers.zip;;
    4.19*) echo $(uname -r) based kernel found 
        echo "${YELLOW}Downloading source files${SET}"
        wget https://github.com/sixfab/Sixfab_RPi_3G-4G-LTE_Base_Shield/raw/master/tutorials/QMI_tutorial/src/4.19.1.zip -O drivers.zip
        unzip drivers.zip -d $INS_DIR && rm -r drivers.zip;;
    *) echo "Driver for $(uname -r) kernel not found";exit 1;
esac

echo -e "${YELLOW}Installing udhcpc${SET}"
apt install udhcpc

echo -e "${YELLOW}Copying udhcpc default script${SET}"
mkdir -p /usr/share/udhcpc
cp -r  $INS_DIR/quectel-CM/default.script /usr/share/udhcpc/
chmod +x /usr/share/udhcpc/default.script
popd

echo -e "${YELLOW}Change directory to /home/pi/files/drivers${SET}"
pushd $INS_DIR/drivers
make && make install
popd

echo -e "${YELLOW}Change directory to /home/pi/files/quectel-CM${SET}"
pushd $INS_DIR/quectel-CM
make
popd

echo -e "${YELLOW}After reboot please follow commands mentioned below${SET}"
echo -e "${YELLOW}go to $INS_DIR/quectel-CM and run sudo ./quectel-CM -s [YOUR APN] for manual operation${SET}"

read -p "Press ENTER key to reboot" ENTER
reboot
