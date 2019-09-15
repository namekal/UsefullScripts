#!/bin/bash
##Name : cpunamefix.sh
##Info : Script to fix CPU name in 'About This Mac' on macOS system.
##Auth : XLNC
## Date : 29/09/2018
# set -x
DIRLOCATION="/System/Library/PrivateFrameworks/AppleSystemInfo.framework/Versions/A/Resources/"
LIST=($(cd ${DIRLOCATION} && ls -1d */ | cut -d\/ -f1))
REALCPUNAME="$(sysctl -n machdep.cpu.brand_string)"
CURRENTCPUNAME="$(sudo /usr/libexec/PlistBuddy -c "Print :UnknownCPUKind" ${DIRLOCATION}/en.lproj/AppleSystemInfo.strings)"
ITL='\033[3m'
BOLD='\033[1m'
STD='\033[0m'

printf '\033[8;30;100t' && clear
echo -e "\n${ITL}  CPU Name Fix ~XLNC~ ${STD}"
echo -e "${ITL}  $(date -R) ${STD}"
sleep 1.5

echo -e "\n\nCurrent CPU name : ${BOLD}${CURRENTCPUNAME}${STD}"
echo -e "Actual CPU name  : ${BOLD}${REALCPUNAME}${STD}\n"
sleep 1.5

while ! [[ ${REPLY} =~ ^[Yy|Nn]$ ]]; do
	echo -e "Do you want to use a custom CPU name or the actual CPU name ?"
	read -p "[Custom=Y / Actual=N]: " REPLY
	if [[ ${REPLY} =~ ^[Yy]$ ]]; then
		echo
		read -p "Enter custom CPU name : " CPUNAME
		echo -e "\nApplying custom CPU name : ${BOLD}${CPUNAME}${STD}\n"
	elif [[ ${REPLY} =~ ^[Nn]$ ]]; then
		echo -e "\nApplying actual CPU name : ${BOLD}${REALCPUNAME}${STD}\n"
		CPUNAME="${REALCPUNAME}"
	else
		echo -e "\n[x] Error : Enter only Y or N\n"
	fi
done

if [[ $(sw_vers -productVersion | cut -d '.' -f2) == 15 ]]; then
	echo "Mounting filesystem as R/W"
	sudo mount -uw /
fi

for ITEM in "${LIST[@]}"; do
	if [ ! -e "${DIRLOCATION}${ITEM}/AppleSystemInfo.strings.backup" ]; then
		sudo cp -Rf ${DIRLOCATION}${ITEM}/AppleSystemInfo.strings ${DIRLOCATION}${ITEM}/AppleSystemInfo.strings.backup
	fi
	if [ -e "${DIRLOCATION}${ITEM}/AppleSystemInfo.strings.backup" ]; then
		sudo rm -rf ${DIRLOCATION}${ITEM}/AppleSystemInfo.strings
		sudo cp -Rf ${DIRLOCATION}${ITEM}/AppleSystemInfo.strings.backup ${DIRLOCATION}${ITEM}/AppleSystemInfo.strings
	fi

	FILE="${DIRLOCATION}${ITEM}/AppleSystemInfo.strings"

	function bintoxml() {
		sudo /usr/bin/plutil -convert xml1 "$1"
	}
	function xmltobin() {
		sudo /usr/bin/plutil -convert binary1 "$1"
	}

	bintoxml ${FILE}
	sudo /usr/libexec/PlistBuddy -c "Set :UnknownCPUKind ${CPUNAME}" ${FILE}
	sudo /usr/libexec/PlistBuddy -c "Set :UnknownComputerModel ${CPUNAME}" ${FILE}
	# sudo sed -i '' "s/\\<string\\>Unknown\\<\\/string\\>/\\<string\\>$CPUNAME\\<\\/string\\>/" ${FILE}
	xmltobin ${FILE}
done

echo -e "\nDone.\n"
open /System/Library/CoreServices/Applications/About\ This\ Mac.app
