#!/bin/bash
#
#
#
#
#

# Commands
_crypt="/sbin/cryptsetup"
_vg="/sbin/vgscan"
_vgc="/sbin/vgchange"
_mnt="/bin/mount"
_umnt="/bin/umount"
_rsync="/usr/bin/rsync"

# Variables
_nameMountedDevice="secureDevice"
_nameMountedDocker="secureContainer"

# Check if exec with sudo
if [ "$EUID" -ne 0 ]
  then echo "Please run as root."
  exit
fi

# Check if help
for i in "$@" ; do
  if [[ $i == "--help" ]] ; then 
		echo "syncproject 1.0.1"
		echo "Usage: $0 [--help] <path_frst_device> <path_second_device>"
		exit 1
	elif [[ $i == "--umountall" ]] ; then 
		${_umnt} ${_nameMountedDocker}
		${_umnt} ${_nameMountedDevice}
		exit 1
	fi
done

# Check if exactly 2 arguments
if [ $# -ne 2 ]
then
	echo "$0: bad usage"
  echo "Usage: $0 <path_frst_device> <path_second_device>"
  echo "Try '$0 --help' for more information."
  exit 1
fi

# Secondly, check if --help or if file exist (docker) or is isLuks device (device)
for i in "$@" ; do
    if [ ! -f "$i" ] && ! cryptsetup isLuks $i 2> /dev/null ; then 
			echo "Device $i doesn't exist or is already mounted."
			exit 1
    fi
done

function copen {
	#If isLuks
	if ${_crypt} isLuks $1 2> /dev/null ; then 
		#If is
		if ! ${_crypt} status $1 2> /dev/null ; then 
			${_crypt} luksOpen $1 ${_nameMountedDevice} && echo "${_nameMountedDevice} successfuly opened" || return 0
			cmount ${_nameMountedDevice}
  	else
  		echo "$1 already opened. Openning skipped."
  	fi
	else
			${_crypt} tcryptOpen --veracrypt $1 ${_nameMountedDocker} && echo "${_nameMountedDocker} successfuly opened"; cmount ${_nameMountedDocker} }
  fi
}

function cmount {
	mkdir -p /mnt/$1
	${_mnt} /dev/mapper/$1 /mnt/$1 && echo "$1 successfuly mounted to /mnt/$1"
}

function cumount {
	${_umnt} /mnt/$1
	cclose $1
}

function cclose {
		${_crypt} tcryptClose $1 && echo "Successfuly unmounted"
		rm -r /mnt/$1 >> logs.txt
}

clear
echo "This script is a tool that can syncronize encrypted devices"
echo

read -n 1 -s -r -p "Presse any key to mount $1"
echo
echo "Mounting $1..."
copen $1

echo
read -n 1 -s -r -p "Presse any key to mount $2"
echo
echo "Mounting $2..."
copen $2

echo
read -n 1 -s -r -p "Presse any key to rsync"
echo
echo "How to you cant to sync ?"
echo "1) $2 -> $1 [1]"
echo "2) $1 -> $2 [2]"
read s
case $s in
  1) ${_rsync} --progress -avz --delete $1 $2 && echo "Transfert finished";;
  2) ${_rsync} --progress -avz --delete $2 $1 && echo "Transfert finished";;
esac

echo "Do you want to close ${_nameMountedDocker}?"
echo "1) Yes"
echo "2) No"
read yn
case $yn in
  Yes) cumount ${_nameMountedDocker};;
esac

echo
echo "Do you want to close ${_nameMountedDevice}?"
echo "1) Yes"
echo "2) No"
read yn
case $yn in
  Yes) cumount ${_nameMountedDevice};;
esac

exit
