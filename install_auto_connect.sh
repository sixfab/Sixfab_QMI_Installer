#!/bin/sh

echo "What is the APN?"
read carrierapn

wget --no-check-certificate https://github.com/sixfab/Sixfab_RPi_Lora_Gateway/raw/master/Sixfab_QMI_Installer/reconnect_service -O qmi_reconnect.service
wget --no-check-certificate https://github.com/sixfab/Sixfab_RPi_Lora_Gateway/raw/master/Sixfab_QMI_Installer/reconnect_sh -O qmi_reconnect.sh

sed -i "s/#APN/$carrierapn/" qmi_reconnect.sh

mv qmi_reconnect.sh /usr/src/
mv qmi_reconnect.service /etc/systemd/system/

systemctl daemon-reload
systemctl start qmi_reconnect.service
systemctl enable qmi_reconnect.service

echo "DONE"
