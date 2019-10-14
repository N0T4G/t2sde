#!/bin/bash
# --- T2-COPYRIGHT-NOTE-BEGIN ---
# This copyright note is auto-generated by ./scripts/Create-CopyPatch.
# 
# T2 SDE: package/.../mkinitrd/mkinitrd.sh
# Copyright (C) 2005 - 2019 The T2 SDE Project
# 
# More information can be found in the files COPYING and README.
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; version 2 of the License. A copy of the
# GNU General Public License can be found in the file COPYING.
# --- T2-COPYRIGHT-NOTE-END ---

set -e

map=`mktemp`

if [ $UID != 0 ]; then
	echo "Non root - exiting ..."
	exit 1
fi

while [ "$1" ]; do
  case $1 in
	[0-9]*) kernelver="$1" ;;
	-R) root="$2" ; shift ;;
	*) echo "Usage: mkinitrd [ -R root ] [ kernelver ]"
	   exit 1 ;;
  esac
  shift
done

[ "$root" ] || root=""
[ "$kernelver" ] || kernelver=`uname -r`
[ "$moddir" ] || moddir="$root/lib/modules/$kernelver"

echo "Kernel: $kernelver, module dir: $moddir"

if [ ! -d $moddir ]; then
	echo "Module dir $moddir does not exist!"
	exit 2
fi

sysmap=""
[ -f "$root/boot/System.map_$kernelver" ] && sysmap="$root/boot/System.map_$kernelver"

if [ -z "$sysmap" ]; then
	echo "System.map_$kernelver not found!"
	exit 2
fi

echo "System.map: $sysmap"

# check needed tools
for x in cpio gzip ; do
	if ! type -p $x >/dev/null ; then
		echo "$x not found!"
		exit 2
	fi
done

tmpdir="$map.d"

# create basic structure
#
rm -rf $tmpdir >/dev/null

echo "Create dirtree ..."

mkdir -p $tmpdir/{dev,bin,sbin,proc,sys,lib/modules,lib/udev,etc/hotplug.d/default}
mknod $tmpdir/dev/console c 5 1

# copy the basic / rootfs kernel modules
#
echo "Copying kernel modules ..."

(
  declare -A added
  add_depend() {
     local x="$1"
     if [ "${added["$x"]}" != 1 ]; then
	added["$x"]=1

	# expand to full name if it was a depend
	[ $x = ${x##*/} ] && x=`sed -n "/\/$x\..*o$/{p; q}" $map`

	echo -n "${x##*/} "

	# strip $root prefix
	xt=${x##$root}

	mkdir -p `dirname $tmpdir/$xt`
	cp $x $tmpdir/$xt 2>/dev/null
	
	# add it's deps, too
	for fn in `modinfo -F depends $x | sed 's/,/ /g'`; do
	     add_depend "$fn"
	done
     else
        #echo "already there"
	:
     fi
  }

  find $moddir/kernel -type f > $map
  cat $map |
  grep -v -e /wireless/ -e netfilter |
  grep  -e reiserfs -e reiser4 -e ext2 -e ext3 -e ext4 -e btrfs -e /jfs -e /xfs \
	-e isofs -e udf -e /unionfs -e ntfs -e fat -e dm-mod \
	-e /ide/ -e /ata/ -e /scsi/ -e /message/ -e /sdhci/ -e nvme \
	-e cciss -e ips -e virtio -e floppy -e crypto \
	-e hci -e usb-common -e usb-storage -e sbp2 -e uas \
	-e /net/ -e drivers/md/ -e '/ipv6\.' \
	-e usbhid -e hid-generic -e hid-multitouch -e hid-apple -e hid-microsoft |
  while read fn; do
	add_depend "$fn"
  done
) | fold -s ; echo

# generate map files
#
depmod -ae -b $tmpdir -F $sysmap $kernelver

echo "Injecting programs and configuration ..."

# copying config
#
cp -ar $root/etc/group $tmpdir/etc/
cp -ar $root/etc/udev $tmpdir/etc/
[ -e $root/lib/udev/rules.d ] && cp -ar $root/lib/udev/rules.d $tmpdir/lib/udev/
[ -e $root/etc/mdadm.conf ] && cp -ar $root/etc/mdadm.conf $tmpdir/etc/
cp -ar $root/etc/modprobe.* $root/etc/ld-* $tmpdir/etc/ 2>/dev/null || true
# in theory all, but fat and currently only cdrom_id is needed ...
#cp -a $root/lib/udev/cdrom_id $tmpdir/lib/udev/

elf_magic () {
	readelf -h "$1" | grep Machine
}

# copy dynamic libraries, if any.
#
declare -A added
copy_dyn_libs () {
	local magic
	# we can not use ldd(1) as it loads the object, which does not work on cross builds
	for lib in `readelf -de $1 |
		sed -n -e 's/.*Shared library.*\[\([^]\]*\)\]/\1/p' \
		       -e 's/.*Requesting program interpreter: \([^]]*\)\]/\1/p'`
	do
		if [ -z "$magic" ]; then
			magic="$(elf_magic $1)"
			[[ $1 = *bin/* ]] && echo "Warning: $1 is dynamically linked!"
		fi
		for libdir in $root/lib{64,}/ $root/usr/lib{64,}/ "$root"; do
			if [ -e $libdir$lib ]; then
			    [ "$magic" != "$(elf_magic $libdir$lib)" ] && continue
			    xlibdir=${libdir#$root}
			    echo "	${1#$root} NEEDS $xlibdir$lib"

			    if [ "${added["$xlibdir$lib"]}" != 1 ]; then
				added["$xlibdir$lib"]=1

				mkdir -p $tmpdir$xlibdir
				while local x=`readlink $libdir$lib`; [ "$x" ]; do
					echo "	$xlibdir$lib SYMLINKS to $x"
					local y=$tmpdir$xlibdir$lib
					mkdir -p ${y%/*}
					ln -sfv $x $tmpdir$xlibdir$lib
					if [ "${x#/}" == "$x" ]; then # relative?
						# directory to prepend?
						[ ${lib%/*} != "$lib" ] && x="${lib%/*}/$x"
					fi
					lib="$x"
				done
				local y=$tmpdir$xlibdir$lib
				mkdir -p ${y%/*}
				cp -fv $libdir$lib $tmpdir$xlibdir$lib

				copy_dyn_libs $libdir$lib
			    fi
			fi
		done
	done
}

# setup programs
#
for x in $root/sbin/{udevd,udevadm,modprobe,insmod,blkid} \
         $root/usr/sbin/disktype
do
	cp $x $tmpdir/sbin/
	copy_dyn_libs $x
done

# setup optional programs
#
for x in $root/sbin/{vgchange,lvchange,lvm,mdadm} \
	 $root/usr/sbin/cryptsetup $root/usr/embutils/dmesg
do
  if [ ! -e $x ]; then
	echo "Warning: Skipped optional file ${x#$root}!"
  else
	cp -a $x $tmpdir/sbin/
	copy_dyn_libs $x
  fi
done

ln -s /sbin/udev $tmpdir/etc/hotplug.d/default/10-udev.hotplug
cp $root/bin/pdksh $tmpdir/bin/sh

# static, tiny embutils and friends
#
cp $root/usr/embutils/{mount,umount,rm,mv,mkdir,ln,ls,switch_root,chroot,sleep,losetup,chmod,cat,sed,mknod} \
   $tmpdir/bin/
ln -s mv $tmpdir/bin/cp

cp $root/sbin/initrdinit $tmpdir/init

# Custom ACPI DSDT table
if test -f "$root/boot/DSDT.aml"; then
	echo "Adding local DSDT file: $dsdt"
	cp $root/boot/DSDT.aml $tmpdir/DSDT.aml
fi

# create the cpio image
#
echo "Archiving ..."
( cd $tmpdir
  find . | cpio -o -H newc | zstd -19 -T0 > $root/boot/initrd-$kernelver.img
)
rm -rf $tmpdir $map
