#!/bin/bash
#
# This script is called from VDR to mount/unmount/eject
# the sources for MP3 play.
#
# argument 1: wanted action, one of mount,unmount,eject,status
# argument 2: mountpoint to act on
#
# mount,unmount,eject must return 0 if succeeded, 1 if failed
# status must return 0 if device is mounted, 1 if not
#

action="$1"
path="$2"

mount_device() {
	case "$action" in
	mount)
		eject -t "$path" || exit 1         # close the tray
		mount "$path" || exit 1            # mount it
		;;
	unmount)
		umount "$path" || exit 1           # unmount it
		;;
	eject)
		eject "$path" || exit 1            # eject disk
		;;
	status)
		cat /proc/mounts | grep -q "$path" # check if mounted
		if [ $? -ne 0 ]; then              # not mounted ...
			exit 1
		fi
	esac
}

mount_directory() {
	if [ ! -d $path ] ; then                # not an existing directory
		logger " $path does not exist !"
	exit 1
	fi

	case "$action" in
		mount)
			;;
		unmount)
			;;
		eject)
			;;
		status)
			;;
	esac
}

if [ "`grep $path /etc/fstab | grep -v '^#' `" != "" ] ; then   # there is an entry in fstab
        logger "Mounting device $path ..."
        mount_device
else
        logger "Mounting dir $path ..."
        mount_directory
fi

exit 0
