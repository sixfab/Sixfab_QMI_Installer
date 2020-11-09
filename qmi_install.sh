#!/bin/bash

: '
QMI installation script by Sixfab
This script is strictly for Raspberry Pi OS.

Created By Metin Koc, Nov 2018
Maintainers: Saeed Johar,Yasin Kaya
Last modified: Nov 2020
'
# Text colors
YELLOW='\033[1;33m'
RED='\033[0;31m'
SET='\033[0m'

# Directories
INS_DIR=/opt/qmi_files          # New directory
OLD_DIR=/home/$(whoami)/files/quectel-CM   # Old directory
UDHCPC_DIR=/usr/share/udhcpc

# service names
service_reconnect=qmi_reconnect.service
service_ModemManager=ModemManager

# clean old installation 
status_reconnect="$(systemctl is-active $service_reconnect)"
if [ "$status" = "active" ]; then 
    systemctl stop $service_reconnect
    systemctl disable $service_reconnect
fi

if [ -d "$OLD_DIR" ]; then rm -rf /home/$(whoami)/files ; fi # for old directory
if [ -d "$INS_DIR" ]; then rm -rf $INS_DIR; fi

# Installations
echo -e "${YELLOW}Installing kernel headers for Raspberry Pi${SET}"
apt install raspberrypi-kernel-headers
# For ubuntu it should be 
#apt install linux-headers-$(uname -r)

echo -e "${YELLOW}Installing udhcpc${SET}"
apt install udhcpc

# Download and isntall resources
echo -e "${YELLOW}Create and Change directory to $INS_DIR ${SET}"
mkdir -p $INS_DIR &&
pushd $INS_DIR

echo -e "${YELLOW}Checking Kernel${SET}"
case $(uname -r) in
    4.14*) echo $(uname -r) based kernel found
        echo "${YELLOW}Downloading source files${SET}"
        wget https://github.com/sixfab/Sixfab_QMI_Installer/raw/master/src/v4.14.zip -O drivers.zip #TODO: check link
        unzip drivers.zip -d $INS_DIR && rm -r drivers.zip;;
    4.19*) echo $(uname -r) based kernel found 
        echo "${YELLOW}Downloading source files${SET}"
        wget https://github.com/sixfab/Sixfab_QMI_Installer/raw/master/src/v4.19.1.zip -O drivers.zip   #TODO: check link
        unzip drivers.zip -d $INS_DIR && rm -r drivers.zip;;
    5.4.5*) echo $(uname -r) based kernel contains driver;;
    5.4.7*) echo $(uname -r) based kernel found 
        echo "${YELLOW}Downloading source files${SET}"
        wget https://github.com/sixfab/Sixfab_QMI_Installer/raw/master/src/v5.4.72.zip -O drivers.zip   #TODO: check link
        unzip drivers.zip -d $INS_DIR && rm -r drivers.zip;;
    *) echo "${RED}Driver for $(uname -r) kernel not found${SET}";exit 1;
esac

echo -e "${YELLOW}Change directory to $INS_DIR/drivers${SET}"
if [ -d "$INS_DIR/drivers" ];then
    pushd $INS_DIR/drivers
    make && make install
    popd
fi

wget https://github.com/sixfab/Sixfab_QMI_Installer/raw/master/src/qmi_wwan.zip -O qmi_wwan.zip 
unzip qmi_wwan.zip -d $INS_DIR && rm qmi_wwan.zip
pushd $INS_DIR/qmi_wwan
make && make install
popd

echo -e "${YELLOW}Downloading Connection Manager${SET}"
wget https://github.com/sixfab/Sixfab_QMI_Installer/raw/master/src/quectel-CM.zip -O quectel-CM.zip
unzip quectel-CM.zip && rm quectel-CM.zip

echo -e "${YELLOW}Copying udhcpc default script${SET}"
mkdir -p $UDHCPC_DIR
cp $INS_DIR/quectel-CM/default.script $UDHCPC_DIR
chmod +x $UDHCPC_DIR/default.script

echo -e "${YELLOW}Making $INS_DIR/quectel-CM${SET}"
pushd $INS_DIR/quectel-CM
make
popd

popd

# If ModemManager is isntalled and running, stop it as it will interfere 
status_modemmanager="$(systemctl is-active $service_ModemManager)"
if [ "$status_modemmanager" = "active" ]; then 
    systemctl stop $service_ModemManager
    systemctl disable $service_ModemManager
fi

echo -e "${YELLOW}After reboot please follow commands mentioned below${SET}"
echo -e "${YELLOW}go to $INS_DIR/quectel-CM and run sudo ./quectel-CM -s [YOUR APN] for manual operation${SET}"

read -p "Press ENTER key to reboot" ENTER
reboot
