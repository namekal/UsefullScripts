#!/bin/bash
##Name: kerntool.sh
##Info: Script to install kernel and rebuild caches on macOS system
##Auth: XLNC
##Date: 28/09/18

ITL='\033[3m'
STD='\033[0m'
printf '\e[9;1t' && clear
echo -e "\n${ITL}  Kernel Tool ~XLNC~ ${STD}"
echo -e "${ITL}  $(date -R) ${STD}"
sleep 1.5
echo
function rebuildCaches() {
	sleep 1
	echo -e "\n> Rebuilding caches ...\n"
	sudo chown -R 0:0 /System/Library/Extensions/ /Library/Extensions/
	sudo chmod -R 755 /System/Library/Extensions/ /Library/Extensions/
	sudo touch /System/Library/Extensions/ /Library/Extensions/
	sudo rm -rf /System/Library/PrelinkedKernels/pre*
	sudo killall kextcache
	sudo kextcache -Boot -U /
	echo -e "\n> Done !\n"
}
function kernelInstall() {
	sleep 1
	echo -e "\n> Installing kernel ..."
	echo -e "\n Kernel Location : ${KERNELFILE}"
	sudo cp -Rf "${KERNELFILE}" /System/Library/Kernels/
}
function sysKextInstall() {
	sleep 1
	echo -e "\n> Installing System.kext ..."
	echo -e "\n System.kext Location : ${SYSEXTFILE}"
	sudo cp -Rf "${SYSEXTFILE}" /System/Library/Extensions/
}
function usage() {
	cat <<'EOF'

Usage:./kerntool.sh [ -r | -k | -ke ]
      ./kerntool.sh -r                                      :  Rebuilds caches only
      ./kerntool.sh -k <kernel-file>                        :  Installs provided kernel then rebuilds caches
      ./kerntool.sh -ke <kernel-file> <System.kext-file>    :  Installs provided kernel and system.kext then rebuilds caches

Example:
      ./kerntool.sh -k ~/Desktop/kernel
      ./kerntool.sh -k ~/Desktop/kernel.test                   [ Use Bootflag : kcsuffix=test ]
      ./kerntool.sh -ke ~/Desktop/kernel ~/Desktop/System.kext
EOF
}

if [[ $# -lt 1 ]]; then
	usage
	exit
fi

case "$1" in
-r) rebuildCaches ;;
-k)
	KERNELFILE="$2"
	kernelInstall
	rebuildCaches
	;;
-ke)
	KERNELFILE="$2"
	SYSEXTFILE="$3"
	kernelInstall
	sysKextInstall
	rebuildCaches
	;;
*) usage ;;
esac
