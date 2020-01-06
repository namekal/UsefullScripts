#!/bin/bash

rm -rf /tmp/macinfo*

userName="$(id -F)"
version="$(curl -s https://api.github.com/repos/acidanthera/MacInfoPkg/releases/latest | grep "tag_name" | cut -d "\"" -f 4)"
download_link="https://github.com/acidanthera/MacInfoPkg/releases/download/${version}/macinfo-${version}-mac.zip"
macgen_zip="/tmp/macinfo-${version}-mac.zip"
macgen_folder="/tmp/macinfo-${version}-mac"
uuid="$(uuidgen)"

wget -qP /tmp/ $download_link
unzip -o -a $macgen_zip -d $macgen_folder &>/dev/null

printf '\033[8;25;90t' && clear
ITL='\x1b[3m'
STD='\033[0;0;39m'
echo
echo -e "${ITL}  SMBIOS Data Generator ~XLNC~ ${STD}"
echo -e "${ITL}  $(date -R) ${STD}"
echo -e "${ITL}  ${userName} ${STD}"
echo

generateSMBIOS() {
echo
read -p "Enter SMBIOS: " SMBIOS
echo
echo "     SMBIOS    |    SERIAL    |     MLB   "
$macgen_folder/macserial -a | grep -i "$SMBIOS" | head -1
echo
echo "                       UUID"
echo "         $uuid"
}

while ! [[ $REPLY =~ [Ee] ]]; do
	generateSMBIOS
	echo
	read -p "Press [Enter] to generate again or [E] to exit. " -n 1 -r
done


rm -rf $macgen_zip $macgen_folder