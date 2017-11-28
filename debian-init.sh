#!/bin/sh

# setup wifi
if [ -e /lib/firmware/brcm/brcmfmac43602-pcie.bin ];then;
	wget https://git.kernel.org/cgit/linux/kernel/git/firmware/linux-firmware.git/plain/brcm/brcmfmac43602-pcie.bin
	mkdir /lib/firmware
	mkdir /lib/firmware/brcm
	mv brcmfmac43602-pcie.bin /lib/firmware/brcm/
	
	apt-get update
	apt-get install gtkpod usbmuxd libimobiledevice-dev libimobiledevice-utils libimobiledevice6 ideviceinstaller
fi



