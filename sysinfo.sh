#!/bin/bash
##Name: sysinfo.sh
##Info: Provides a small summary of information on macOS system.
##Auth: XLNC
##Date: 28/09/18

# set -x
echo " Generating ..."

userName="$(id -F)"
macosModel="$(sysctl -n hw.model)"
macosName="$(sw_vers -productName)"
macosVersion="$(sw_vers -productVersion)"
macosBuild="$(sw_vers -buildVersion)"
if [[ "${macosVersion}" =~ 10.13.[0-6] ]]; then
	macosName="High Sierra"
elif [[ "${macosVersion}" =~ 10.12.[0-6] ]]; then
	macosName="Sierra"
fi
FileLoc="$(mktemp /tmp/xlnc.diskinfo.plist)"
diskutil info -plist / >"${FileLoc}"
bootDiskId="$(defaults read "${FileLoc}" ParentWholeDisk)"
bootDiskEfiId="$(defaults read "${FileLoc}" ParentWholeDisk)s1" #hardcoded /needs to be corrected
bootDiskSize="$(diskutil info "${bootDiskId}" | grep Disk\ Size | awk {'print $3 $4'})"
typeSSD="$(test "$(defaults read "${FileLoc}" SolidState)" -eq 0 && echo "No" || echo "Yes")"
bootVolName="$(defaults read "${FileLoc}" VolumeName)"
bootVolId="$(defaults read "${FileLoc}" DeviceIdentifier)"
bootVolTotalSize="$(diskutil info / | grep Total | awk {'print $4 $5'})"
bootVolUsedSize="$(diskutil info / | grep Used | awk {'print $4 $5'})"
bootVolFreeSize="$(diskutil info / | grep 'Avail\|Free' | awk {'print $4 $5'})"
rm -rf "${FileLoc}"
bootArgs="$(sysctl -n kern.bootargs)"
kernelVer="$(uname -v | cut -d ":" -f1 | sed 's/ Kernel\ Version//g')"
kernelCompileDate="$(uname -v | cut -d ';' -f1 | cut -d ':' -f2-)"
kernelHClass="$(uname -m)"
cpuName="$(sysctl -n machdep.cpu.brand_string)"
cpuSig="$(sysctl -n machdep.cpu.signature)"
cpuSigHex="$(echo "obase=16; ${cpuSig}" | bc)"
cpuCores="$(sysctl -n hw.physicalcpu)"
cpuThreads="$(sysctl -n hw.logicalcpu)"
cpuCacheL1i="$(($(sysctl -n hw.l1icachesize) / 1024))"
cpuCacheL1d="$(($(sysctl -n hw.l1dcachesize) / 1024))"
cpuCacheL2="$(($(sysctl -n hw.l2cachesize) / 1024))"
cpuCacheL3="$(($(sysctl -n hw.l3cachesize) / 1024))"
cpuSpeed="$(($(sysctl -n hw.cpufrequency) / 1000000))"
cpuStatistics="$(top -l 1 | grep -E "^CPU" | cut -d ":" -f2)"
cpuBusSpeed="$(($(sysctl -n hw.busfrequency_max) / 1000000))"
cpuSpeedGHz="$(system_profiler SPHardwareDataType | grep Speed | cut -d ":" -f2)"
cpuFeatures="$(sysctl -n machdep.cpu.features) $(sysctl -n machdep.cpu.extfeatures) $(sysctl -n machdep.cpu.leaf7_features)"
ramAmount="$(($(sysctl -n hw.memsize) / 1024 / 1024))"
ramAmountGB="$(system_profiler SPHardwareDataType | grep Memory | cut -d ":" -f2)"
ramStatistics=$(top -l 1 | grep -E "^Phys" | cut -d ":" -f2)
processStatistics=$(top -l 1 | grep -E "^Proc" | cut -d ":" -f2)
gpuModel="$(system_profiler SPDisplaysDataType | grep Chipset | cut -d ':' -f2)"
gpuDevId="$(system_profiler SPDisplaysDataType | grep Dev | cut -d ':' -f2)"
gpuVenId="$(system_profiler SPDisplaysDataType | grep Vendor | cut -d '(' -f2 | cut -d ')' -f1)"
gpuVramSize="$(system_profiler SPDisplaysDataType | grep VRAM | cut -d ':' -f2)"
gateKeeperStatus="$(spctl --status | grep enabled &>/dev/null && echo "Enabled" || echo "Disabled")"
sipStatus="$(csrutil status | grep enabled && echo "Enabled" || echo "Disabled")"

printf '\033[8;50;150t' && clear
ITL='\x1b[3m'
STD='\033[0;0;39m'
echo
echo -e "${ITL}  System Information ~XLNC~ ${STD}"
echo -e "${ITL}  $(date -R) ${STD}"
echo -e "${ITL}  ${userName} ${STD}"
echo

cat <<EOF
mac Model      : ${macosModel}
macOS Release  : ${macosName}
macOS Version  : ${macosVersion}
macOS Build    : ${macosBuild}

Boot Volume    : Name: ${bootVolName}     ID: ${bootVolId}      Size: ${bootVolTotalSize} (${bootVolUsedSize} used, ${bootVolFreeSize} free)
Boot Disk      : ID: ${bootDiskId}        EFI-ID: ${bootDiskEfiId}      Size: ${bootDiskSize}    SSD: ${typeSSD}

Boot Arguments : ${bootArgs}
Kernel Version : ${kernelVer}
Kernel Mode    : ${kernelHClass}
Kernel Date    :${kernelCompileDate}

CPU Name       : ${cpuName}
CPU ID         : Ox${cpuSigHex}
CPU Cores      : ${cpuCores}
CPU Threads    : ${cpuThreads}
CPU Speed      :${cpuSpeedGHz} (${cpuSpeed}Mhz)
Bus Speed      : ${cpuBusSpeed} Mhz
CPU Usage      :${cpuStatistics}
CPU Caches     : L1i: ${cpuCacheL1i}Kb , L1d: ${cpuCacheL1d}Kb , L2/c: ${cpuCacheL2}Kb , L3: ${cpuCacheL3}Kb
CPU Features   : ${cpuFeatures}

RAM Size       :${ramAmountGB} (${ramAmount}MB)
RAM Usage      :${ramStatistics}
Processes      :${processStatistics}

GPU Model      :${gpuModel}
GPU Device ID  :${gpuDevId}
GPU Vendor ID  : ${gpuVenId}
GPU VRAM Size  :${gpuVramSize}

Gatekeeper     : ${gateKeeperStatus}
SIP Status     : ${sipStatus}
EOF

exit 0
