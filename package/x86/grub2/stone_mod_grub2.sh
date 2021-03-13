# --- T2-COPYRIGHT-NOTE-BEGIN ---
# This copyright note is auto-generated by scripts/Create-CopyPatch.
# 
# T2 SDE: package/*/grub2/stone_mod_grub2.sh
# Copyright (C) 2004 - 2021 The T2 SDE Project
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

# TODO:
# void efibootmgr duplicates :-/
# impl. & test sparc, mips, riscv, ...
# unify non-crypt, and direct non-EFI BIOS install

arch=$(uname -m)
arch=${arch/i?86/i386}

create_kernel_list() {
	first=1
	for x in `(cd /boot/ ; ls vmlinux-* ) | sort -r` ; do
		ver=${x/vmlinux-/}
		[[ $arch = *86* ]] && x=${x/vmlinux/vmlinuz}
		if [ $first = 1 ] ; then
			label=linux ; first=0
		else
			label=linux-$ver
		fi

		cat << EOT

menuentry "T2/Linux $label" {
	linux $bootpath/$x root=$rootdev ro
	initrd $bootpath/initrd-${ver}
}
EOT
	done
}


create_boot_menu() {
	# determine /boot path, relative to the boot device
	# (non local as used by create_kernel_list() ...)
	#
	[ "$rootdev" = "$bootdev" ] && bootpath="/boot" || bootpath=""

	mkdir -p /boot/grub/
	cat << EOT > /boot/grub/grub.cfg
set timeout=30
set default=0
set fallback=1

if [ "\$grub_platform" = "efi" ]; then
    set debug=video
    insmod efi_gop
    insmod efi_uga
    insmod font
    if loadfont \${prefix}/unicode.pf2; then
	insmod gfxterm
	set gfxmode=auto
	set gfxpayload=keep
	terminal_output gfxterm
    fi
fi

EOT
	if [ -z "$cryptdev" ]; then
		cat << EOT >> /boot/grub/grub.cfg
set uuid=$grubdev
search --set=root --no-floppy --fs-uuid \$uuid

EOT
	else
		cat << EOT >> /boot/grub/grub.cfg
set root=$cryptdev

EOT
	fi

	create_kernel_list >> /boot/grub/grub.cfg

	gui_message "This is the new /boot/grub/grub.cfg file:

$( cat /boot/grub/grub.cfg )"
	unset bootpath
}

grubmods="part_gpt part_msdos ntfs ntfscomp hfsplus fat ext2 iso9660 \
          boot configfile linux btrfs all_video reiserfs xfs jfs lvm \
          normal crypto cryptodisk luks part_apple sleep reboot \
          search_fs_file search_label search_fs_uuid hfs" # gcry_sha256 gcry_rijndael

grub_inst() {
    if [[ $arch != ppc* ]]; then
	if [ -z "$cryptdev" ]; then
		grub2-install $instdev
	else
	    for efi in /boot/efi*; do
		mkdir -p $efi/EFI/grub

		cat << EOT > $efi/EFI/grub/grub.cfg
set uuid=$grubdev
cryptomount -u \$uuid
configfile (crypto0)/boot/grub/grub.cfg
EOT

		local exe=grubx.efi
		[ $arch = x86_64 ] && exe=${exe/.efi/64.efi}
		
		grub-mkimage -O $arch-efi -o $efi/EFI/grub/$exe \
			-p /efi/grub -d /usr/lib*/grub/$arch-efi/ \
			$grubmods
	    done
	    efibootmgr -c -L t2sde -l "\\EFI\\grub\\$exe"
	fi
    else
	# Apple PowerPC - install into FW read-able HFS partition
	hformat /dev/sda2
	mount /dev/sda2 /mnt
	
	if [ -z "$cryptdev" ]; then
		cat << EOT > /mnt/grub.cfg
set uuid=$grubdev
search --set=root --no-floppy --fs-uuid \$uuid
configfile (\$root)/boot/grub/grub.cfg
EOT
	else
		cat << EOT > /mnt/grub.cfg
set uuid=$grubdev
cryptomount -u \$uuid
configfile (crypto0)/boot/grub/grub.cfg
EOT
	fi

	grub-mkimage -O powerpc-ieee1275 -p / -o /mnt/grub.elf \
		-d /usr/lib64/grub/powerpc-ieee1275 \
		$grubmods suspend # -c /tmp/grub.cfg 

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
    fi
}


grub_install() {
	gui_cmd 'Installing GRUB2' "grub_inst"
}

get_dm_dev() {
	local dev="$1"
	local devnode=$(stat -c "%t:%T" $dev)
	for d in /dev/dm-*; do
		[ "$(stat -c "%t:%T" "$d")" = "$devnode" ] && echo $d && return
	done
}

get_dm_type() {
	local dev="$1"
	dev="${dev##*/}"
	[ -e /sys/block/$dev/dm/uuid ] && cat /sys/block/$dev/dm/uuid
}

get_uuid() {
	local dev="$1"

	# look up uuid
	for _dev in /dev/disk/by-uuid/*; do
		local d=$(readlink $_dev)
		d="/dev/${d##*/}"
		if [ "$d" = $dev ]; then
			echo $_dev
                        return
		fi
	done
}

get_realdev() {
	local dev="$1"
	dev=$(readlink $dev)
	[ "$dev" ] && echo /dev/${dev##*/} || echo $1
}

main() {
	rootdev="`grep ' / ' /proc/mounts | tail -n 1 | sed 's, .*,,'`"
	bootdev="`grep ' /boot ' /proc/mounts | tail -n 1 | sed 's, .*,,'`"

	# if device-mapper, get backing device
	if [[ "$rootdev" = *mapper* ]]; then
	    rootdev2=$(get_dm_dev $rootdev)
	    # encrypted?
	    if [[ "$(get_dm_type $rootdev2)" = CRYPT* ]]; then
		rootdev=$rootdev2
		realroot=$(cd /sys/block/${rootdev##*/}/slaves/; ls -d [a-z]*)
		if [ "$realroot" ]; then
			rootdev="/dev/$realroot"
			cryptdev="(crypto0)"
		fi
	    else
		cryptdev="lvm/${rootdev#/dev/mapper/}"
	    fi
	fi

	# get uuid
	uuid=$(get_uuid $rootdev)
	[ "$uuid" ] && rootdev=$uuid
	if [ "$bootdev" ]; then
		uuid=$(get_uuid $bootdev)
		[ "$uuid" ] && bootdev=$uuid
	fi

	[ "$bootdev" ] || bootdev="$rootdev"
	instdev=$(get_realdev $bootdev); instdev="${instdev%%[0-9*]}"
	[ "$grubdev" ] || grubdev="${bootdev##*/}"

	if [ ! -f /boot/grub/grub.cfg ] ; then
	  if gui_yesno "GRUB2 does not appear to be configured.
Automatically install GRUB2 now?"; then
	    create_boot_menu
	    if ! grub_install; then
	      gui_message "There was an error while installing GRUB2."
	    fi
	  fi
	fi

	while

        gui_menu grub 'GRUB2 Boot Loader Setup' \
		"Root device ... $rootdev" "" \
		"Boot device ... $bootdev" "" \
		"Crypt device .. $cryptdev" "" \
		"Grub device ... $grubdev" "" \
		"Inst device ... $instdev" "" \
		'' '' \
		'(Re-)Create boot menu with installed kernels' 'create_boot_menu' \
		"(Re-)Install GRUB2 in boot record ($instdev)" 'grub_install' \
		'' '' \
		"Edit /boot/grub/grub.cfg (Boot Menu)" \
			"gui_edit 'GRUB2 Boot Menu' /boot/grub/grub.cfg"
    do : ; done
}
