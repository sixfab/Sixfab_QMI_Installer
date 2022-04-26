# Sixfab_QMI_Installer
QMI (wwan0) interface installer for providing internet connection using Quectel modules. 

## How to install
First download the installation script 
`wget https://raw.githubusercontent.com/sixfab/Sixfab_QMI_Installer/main/qmi_install.sh`

Then change the permission 
`chmod +x qmi_install.sh`

Finally run the script to install
`sudo ./qmi_install.sh`

Once the installation is completed, your Raspberry Pi will reboot.
After the reboot navigate to **/opt/qmi_files/quectel-CM**
then run 
`sudo ./quectel-CM -s <yourAPN>`
