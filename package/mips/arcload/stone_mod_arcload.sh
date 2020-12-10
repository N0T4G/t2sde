# --- T2-COPYRIGHT-NOTE-BEGIN ---
# This copyright note is auto-generated by scripts/Create-CopyPatch.
# 
# T2 SDE: package/.../arcload/stone_mod_arcload.sh
# Copyright (C) 2004 - 2020 The T2 SDE Project
# 
# More information can be found in the files COPYING and README.
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; version 2 of the License. A copy of the
# GNU General Public License can be found in the file COPYING.
# --- T2-COPYRIGHT-NOTE-END ---
#
# [MAIN] 70 arcload Arcload Setup
# [SETUP] 90 arcload

install_arcload() {
	dvhtool -d "${bootdev%[0-9]*}" --unix-to-vh /boot/arcload sash64
}

create_kernel_list() {
	first=1
	for x in `(cd /boot/; ls vmlinux_*dist ) | sort -r`; do
		if [ $first = 1 ]; then
			label=t2sde; first=0
		else
			label=t2sde-${x/vmlinux_/}
		fi
		ver=${x/vmlinux_}
		cat << EOT
$label {
	image system "$bootpath/$x";
	#initrd system "$bootpath/initrd-${ver}.img";
	append "root=$rootdev";
}
EOT
	done
}

create_arcload_conf() {
	create_kernel_list > $bootpath/arc.cf

	gui_message "This is the new $bootpath/arc.cf file:

$(< $bootpath/arc.cf)"
}

device4() {
	local dev="`sed -n "s,\([^ ]*\) $1 .*,\1,p" /etc/fstab | tail -n 1`"
	if [ ! "$dev" ]; then # try the higher dentry
		local try="`dirname $1`"
		dev="`grep \" $try \" /etc/fstab | tail -n 1 | \
		      cut -d ' ' -f 1`"
	fi
	if [ -h "$dev" ]; then
	  echo "/dev/`readlink $dev`"
	else
	  echo $dev
	fi
}

realpath() {
	dir="`dirname $1`"
	file="`basename $1`"
	dir="`dirname $dir`/`readlink $dir`"
	dir="`echo $dir | sed 's,[^/]*/\.\./,,g'`"
	echo $dir/$file
}

main() {
	rootdev="`device4 /`"
	bootdev="`device4 /boot`"

	[ "$rootdev" = "$bootdev" ] && bootpath="/boot"

	if [ ! -f $bootpath/arc.cf ]; then
	  if gui_yesno "Arcload does not appear to be configured.
Automatically configure Arcload now?"; then
	    create_arcload_conf && install_arcload
	  fi
	fi

	while

	gui_menu arcload 'Arcload Setup' \
		"Following settings only for expert use: (default)" "" \
		"Root Device ........... $rootdev" "" \
		"Boot Device ........... $bootdev" "" \
		'' '' \
		"(Re-)Create default $bootpath/arc.cf" 'create_arcload_conf' \
		'(Re-)Install Arcload into the VH' 'install_arcload' \
		'' '' \
		"Edit $bootpath/arc.cf (Config file)" \
		"gui_edit 'Arcload Configuration' $bootpath/arc.cf"
    do : ; done
}
