# --- T2-COPYRIGHT-NOTE-BEGIN ---
# This copyright note is auto-generated by ./scripts/Create-CopyPatch.
# 
# T2 SDE: package/.../grub/stone_mod_grub.sh
# Copyright (C) 2004 - 2008 The T2 SDE Project
# Copyright (C) 1998 - 2003 ROCK Linux Project
# 
# More information can be found in the files COPYING and README.
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; version 2 of the License. A copy of the
# GNU General Public License can be found in the file COPYING.
# --- T2-COPYRIGHT-NOTE-END ---
#
# [MAIN] 70 grub2 GRUB2 Boot Loader Setup
# [SETUP] 90 grub2

create_kernel_list() {
	first=1
	for x in `(cd /boot/ ; ls vmlinux_* ) | sort -r` ; do
		ver=${x/vmlinux_/}
		if [ $first = 1 ] ; then
			label=linux ; first=0
		else
			label=linux-$ver
		fi

		cat << EOT

menuentry "T2/Linux $label" {
	set root=$bootdrive$bootpath
	linux /$x root=$rootdev ro
	initrd /initrd-${ver}.img
}
EOT
	done
}

create_device_map() {
	gui_cmd '(Re-)Create Device Map' "$( cat << "EOT"
rm -vf /boot/grub/device.map
echo quit | grub --batch --device-map=/boot/grub/device.map
EOT
	)"
}

convert_device() {
    local device="$1"
    local root_part=

    # extract device type (block) and major number for root drive
    local major_minor=`ls -Ll $device |
    awk '{if ($6 < 64) printf("%c%d0", $1, $5); else printf("%c%d1", $1, $5)}'`

    # find the matching BIOS device
    for bios_drive in `grep -v '^#' /boot/grub/device.map | awk '{print $2}'`
    do
        bios_major_minor=`ls -Ll $bios_drive 2>/dev/null |
        awk '{if ($6 < 64) printf("%c%d0", $1, $5); else printf("%c%d1", $1, $5)}'`

        if [ "$major_minor" = "$bios_major_minor" ]; then
	    # we found it
	    root_drive=`grep $bios_drive /boot/grub/device.map | awk '{print $1}'`
	    root_part=`ls -Ll $device | awk '{print $6}'`
            root_part=$(( $root_part % 16 - 1 ))
	    break
        fi
    done

    drive=`echo $root_drive | sed "s:)$:,$root_part):"`
    echo $drive
}

create_boot_menu() {
	# determine /boot path, relative to the boot device
	# (non local as used by create_kernel_list() ...)
	#
	if [ "$rootdrive" = "$bootdrive" ]
        then bootpath="/boot"; else bootpath=""; fi

	cat << EOT > /boot/grub2/grub.cfg
set timeout=30
set default=0
set fallback=1
EOT

	create_kernel_list >> /boot/grub2/grub.cfg

	gui_message "This is the new /boot/grub2/grub.cfg file:

$( cat /boot/grub2/grub.cfg )"
	unset bootpath
}

grub_inst() {
	mount /dev/sda2 /mnt
	cp -vf /boot/grub2/grub.cfg /mnt
	echo "configfile (ieee1275/hd,apple2)/grub.cfg" > /tmp/grub.cfg
	grub-mkimage -O powerpc-ieee1275 -p /mnt -o /mnt/grub.elf \
		-c /tmp/grub.cfg -d /usr/lib64/grub/powerpc-ieee1275/ \
		part_gpt part_msdos ntfs ntfscomp hfsplus fat ext2 iso9660 \
		boot configfile linux btrfs all_video reiserfs xfs jfs lvm \
		normal crypto cryptodisk luks part_apple suspend sleep reboot \
		search_fs_file search_label search_fs_uuid hfs gcry_sha256 gcry_rijndael
	rm /tmp/grub.cfg

	cat > /mnt/ofboot.b <<-EOT
<CHRP-BOOT>
<COMPATIBLE>
MacRISC MacRISC3 MacRISC4
</COMPATIBLE>
<DESCRIPTION>
T2 SDE
</DESCRIPTION>
<BOOT-SCRIPT>
" screen" output
load-base release-load-area
boot hd:2,\grub.elf
</BOOT-SCRIPT>
<OS-BADGE-ICONS>
1010
000000000000F8FEACF6000000000000
0000000000F5FFFFFEFEF50000000000
00000000002BFAFEFAFCF70000000000
0000000000F65D5857812B0000000000
0000000000F5350B2F88560000000000
0000000000F6335708F8FE0000000000
00000000005600F600F5FD8100000000
00000000F9F8000000F5FAFFF8000000
000000008100F5F50000F6FEFE000000
000000F8F700F500F50000FCFFF70000
00000088F70000F50000F5FCFF2B0000
0000002F582A00F5000008ADE02C0000
00090B0A35A62B0000002D3B350A0000
000A0A0B0B3BF60000505E0B0A0B0A00
002E350B0B2F87FAFCF45F0B2E090000
00000007335FF82BF72B575907000000
000000000000ACFFFF81000000000000
000000000081FFFFFFFF810000000000
0000000000FBFFFFFFFFAC0000000000
000000000081DFDFDFFFFB0000000000
000000000081DD5F83FFFD0000000000
000000000081DDDF5EACFF0000000000
0000000000FDF981F981FFFF00000000
00000000FFACF9F9F981FFFFAC000000
00000000FFF98181F9F981FFFF000000
000000ACACF981F981F9F9FFFFAC0000
000000FFACF9F981F9F981FFFFFB0000
00000083DFFBF981F9F95EFFFFFC0000
005F5F5FDDFFFBF9F9F983DDDD5F0000
005F5F5F5FDD81F9F9E7DF5F5F5F5F00
0083DD5F5F83FFFFFFFFDF5F835F0000
000000FBDDDFACFBACFBDFDFFB000000
000000000000FFFFFFFF000000000000
0000000000FFFFFFFFFFFF0000000000
0000000000FFFFFFFFFFFF0000000000
0000000000FFFFFFFFFFFF0000000000
0000000000FFFFFFFFFFFF0000000000
0000000000FFFFFFFFFFFF0000000000
0000000000FFFFFFFFFFFFFF00000000
00000000FFFFFFFFFFFFFFFFFF000000
00000000FFFFFFFFFFFFFFFFFF000000
000000FFFFFFFFFFFFFFFFFFFFFF0000
000000FFFFFFFFFFFFFFFFFFFFFF0000
000000FFFFFFFFFFFFFFFFFFFFFF0000
00FFFFFFFFFFFFFFFFFFFFFFFFFF0000
00FFFFFFFFFFFFFFFFFFFFFFFFFFFF00
00FFFFFFFFFFFFFFFFFFFFFFFFFF0000
000000FFFFFFFFFFFFFFFFFFFF000000
</OS-BADGE-ICONS>
</CHRP-BOOT>
EOT

	umount /mnt
	hmount /dev/sda2
	hattrib -b Untitled:
	hattrib -c UNIX -t tbxi Untitled:ofboot.b
	humount
}


grub_install() {
	gui_cmd 'Installing GRUB2' "grub_inst"
}

main() {
	rootdev="`grep ' / ' /proc/mounts | tail -n 1 | sed 's, .*,,'`"
	bootdev="`grep ' /boot ' /proc/mounts | tail -n 1 | sed 's, .*,,'`"
	[ -z "$bootdev" ] && bootdev="$rootdev"

	i=0
	rootdev="$( cd `dirname $rootdev` ; pwd -P )/$( basename $rootdev )"
	while [ -L $rootdev ] ; do
		directory="$( cd `dirname $rootdev` ; pwd -P )"
		rootdev="$( ls -l $rootdev | sed 's,.* -> ,,' )"
		[ "${rootdev##/*}" ] && rootdev="$directory/$rootdev"
		i=$(( $i + 1 )) ; [ $i -gt 20 ] && rootdev="Not found!"
	done

	i=0
	bootdev="$( cd `dirname $bootdev` ; pwd -P )/$( basename $bootdev )"
	while [ -L $bootdev ] ; do
		directory="$( cd `dirname $bootdev` ; pwd -P )"
		bootdev="$( ls -l $bootdev | sed 's,.* -> ,,' )"
		[ "${bootdev##/*}" ] && bootdev="$directory/$bootdev"
		i=$(( $i + 1 )) ; [ $i -gt 20 ] && bootdev="Not found!"
	done

	if [ ! -f /boot/grub2/grub.cfg ] ; then
	  if gui_yesno "GRUB2 does not appear to be configured.
Automatically install GRUB2 now?"; then
	    create_device_map
	    rootdrive=`convert_device $rootdev`
	    bootdrive=`convert_device $bootdev`
	    create_boot_menu
	    if ! grub_install; then
	      gui_message "There was an error while installing GRUB2."
	    fi
	  fi
	fi

	while

	if [ -s /boot/grub/device.map ] ; then
		rootdrive=`convert_device $rootdev`
		bootdrive=`convert_device $bootdev`
	else    
		rootdrive='No Device Map found!'
		bootdrive='No Device Map found!'
	fi

        gui_menu grub 'GRUB2 Boot Loader Setup' \
		'(Re-)Create Device Map' 'create_device_map' \
		"Root Device ... $rootdev" "" \
		"Boot Drive .... $bootdrive$boot_path" "" \
		'' '' \
		'(Re-)Create boot menu with installed kernels' 'create_boot_menu' \
		'(Re-)Install GRUB2 in MBR of (hd0)' 'grub_install' \
		'' '' \
		"Edit /boot/grub/device.map (Device Map)" \
			"gui_edit 'GRUB2 Device Map' /boot/grub/device.map" \
		"Edit /boot/grub/menu.lst (Boot Menu)" \
			"gui_edit 'GRUB2 Boot Menu' /boot/grub/menu.lst"
    do : ; done
}
