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

INS_DIR=/opt/qmi_files          # New directory
OLD_DIR=/home/$(whoami)/files/quectel-CM   # Old directory
UDHCPC_DIR=/usr/share/udhcpc

service_name=qmi_reconnect.service

# clean old installation 
status="$(systemctl is-active $service_name)"
if ["$status"="active"]; then 
    systemctl stop $service_name
    systemctl disable $service_name
fi

if [ -d "$OLD_DIR" ]; then rm -rf /home/$(whoami)/files ; fi # for old directory
if [ -d "$INS_DIR" ]; then rm -rf $INS_DIR; fi

echo -e "${YELLOW}Create and Change directory to $INS_DIR ${SET}"
mkdir -p $INS_DIR &&
pushd $INS_DIR

echo -e "${YELLOW}Downloading Connect Manager${SET}"
wget https://github.com/sixfab/Sixfab_QMI_Installer/blob/master/src/quectel-CM.zip  #TODO: check link
unzip quectel-CM.zip -d $INS_DIR && rm -r quectel-CM.zip
:'
echo -e "${YELLOW}Checking Kernel${SET}"
case $(uname -r) in
    4.14*) echo $(uname -r) based kernel found
        echo "${YELLOW}Downloading source files${SET}"
        wget https://github.com/sixfab/Sixfab_QMI_Installer/blob/master/src/4.14.zip -O drivers.zip #TODO: check link
        unzip drivers.zip -d $INS_DIR && rm -r drivers.zip;;
    4.19*) echo $(uname -r) based kernel found 
        echo "${YELLOW}Downloading source files${SET}"
        wget https://github.com/sixfab/Sixfab_QMI_Installer/blob/master/src/4.19.1.zip -O drivers.zip   #TODO: check link
        unzip drivers.zip -d $INS_DIR && rm -r drivers.zip;;
    5.4*) echo $(uname -r) based kernel contains driver;;
    *) echo "${RED}Driver for $(uname -r) kernel not found${SET}";exit 1;
esac
'
echo -e "${YELLOW}Installing udhcpc${SET}"
apt install udhcpc

echo -e "${YELLOW}Copying udhcpc default script${SET}"
mkdir -p $UDHCPC_DIR
cp $INS_DIR/quectel-CM/default.script $UDHCPC_DIR
chmod +x $UDHCPC_DIR/default.script
popd

echo -e "${YELLOW}Change directory to $INS_DIR/drivers${SET}"
pushd $INS_DIR/drivers
make && make install
popd

echo -e "${YELLOW}Change directory to $INS_DIR/quectel-CM${SET}"
pushd $INS_DIR/quectel-CM
make
popd

echo -e "${YELLOW}After reboot please follow commands mentioned below${SET}"
echo -e "${YELLOW}go to $INS_DIR/quectel-CM and run sudo ./quectel-CM -s [YOUR APN] for manual operation${SET}"

read -p "Press ENTER key to reboot" ENTER
reboot
