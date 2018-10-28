#!/bin/bash
clear

# Commands
_crypt="/sbin/cryptsetup"
_vg="/sbin/vgscan"
_vgc="/sbin/vgchange"
_mnt="/bin/mount"
_umnt="/bin/umount"

# Variables
_nameMountedDevice="secureDev"
_nameMountedDocker="secureDocker"

# Open partition with luksOpen
function mountDevice {
	${_crypt} luksOpen ${_device} ${_nameMountedDevice} && echo "Partition successfuly opened" || echo "ERROR"
	mkdir -p /mnt/${_nameMountedDevice}
	${_mnt} /dev/mapper/${_nameMountedDevice} /mnt/${_nameMountedDevice}
}

# Close partition with luksOpen
function unmountDevice {
	fuser -kim /mnt/${_nameMountedDevice}
	${_umnt} /mnt/${_nameMountedDevice}
	${_crypt} luksClose ${_nameMountedDevice} && echo "Partition successfuly closed" || echo "ERROR"
}

function mountDocker {
	${_crypt} tcryptOpen --veracrypt ${_docker} ${_nameMountedDocker} && echo "Docker successfuly opened" || echo "ERROR"
	mkdir -p /mnt/${_nameMountedDocker}
	${_mnt} /dev/mapper/${_nameMountedDocker} /mnt/${_nameMountedDocker}
}

# Close partition with luksOpen
function unmountDocker {
	fuser -kim /mnt/${_nameMountedDocker}
	${_umnt} /mnt/${_nameMountedDocker}
	${_crypt} tcryptClose ${_nameMountedDocker} && echo "Docker successfuly closed" || echo "ERROR"
}

# Display select options & chekc if Luks device
function selectDevice {
	# Transform command result in array
	readarray -t devices < <(fdisk -l | grep '^/dev' | cut -d' ' -f1)

	COLUMNS=12 # Display options in columns
	select _device in "${devices[@]}";
	do
		[[ -n $_device ]] || { echo "Invalid device. Please try again." >&2; continue; }
		cryptsetup status $_docker &> /dev/null && { echo "Docker already opened" >&2; continue; }
		cryptsetup isLuks $_device || { echo "Invalid Luks device. Please try again." >&2; continue; }
		break;
	done
}

function selectDocker {
	COLUMNS=12 # Display options in columns
	while true; do
		read -p "Docker : " _docker
		cryptsetup status $_docker &> /dev/null && { echo "Docker already opened" >&2; continue; }
		break;
	done
}

# Check if exec with sudo
if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

echo
echo "This script is a tool that can syncronize encrypted devices"

echo
echo "Which device you want to retrieve data ?"
selectDevice

echo
echo "Which docker you want to sync data ?"
selectDocker

#echo
#echo "Mounting $_device..."
#mountDevice

echo
echo "Mounting $_docker..."
mountDocker

cd /mnt/${_nameMountedDocker}
#touch test.txt
ls

sleep 5

echo
echo "Unmounting $_docker..."
unmountDocker

#echo
#echo "Unmounting $_device..."
#unmount

exit
