# --- T2-COPYRIGHT-NOTE-BEGIN ---
# This copyright note is auto-generated by ./scripts/Create-CopyPatch.
# 
# T2 SDE: package/.../xorg-server/stone_mod_xorg.sh
# Copyright (C) 2004 - 2005 The T2 SDE Project
# Copyright (C) 1998 - 2004 ROCK Linux Project
# 
# More information can be found in the files COPYING and README.
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; version 2 of the License. A copy of the
# GNU General Public License can be found in the file COPYING.
# --- T2-COPYRIGHT-NOTE-END ---
#
# [MAIN] 50 xorg X11 Configuration

set_wm() {
	echo "export WINDOWMANAGER=\"$*\"" > /etc/profile.d/windowmanager
}

set_xdm() {
	echo "export XDM=\"$*\"" > /etc/conf/xdm
}

main() {
	while
		WINDOWMANAGER=""
		if [ -f /etc/profile.d/windowmanager ]; then
			. /etc/profile.d/windowmanager
		fi

		XDM=""
		if [ -f /etc/conf/xdm ]; then
			. /etc/conf/xdm
		fi

		cmd="gui_menu x 'X11 Configuration Menu'

		'Run xorgcfg (recommended, new interactive config)'
			'gui_cmd xorgcfg xorgcfg -config /etc/X11/xorg'

		'Run X -configure (automated config)'
			'gui_cmd Xorg Xorg -configure ; mv -v /root/xorg.conf.new /etc/X11/xorg.conf'

		'Run xorgconfig (old textual config)'
			'gui_cmd xorgconfig xorgconfig'"

		cmd="$cmd '' ''"

		for x in /usr/share/rock-registry/xdm/* ; do
		  if [ -f $x ] ; then
			. $x

			if [ "$XDM" = "$exec" ]; then
			pre='[*]' ; else
			pre='[ ]' ; fi

			cmd="$cmd
			    '$pre Use $name in runlevel 5'
			    'set_xdm $exec'"
		  fi
		done

		cmd="$cmd '' ''"

		for x in /usr/share/rock-registry/wm/* ; do
		  if [ -f $x ] ; then
			. $x

			if [ "$WINDOWMANAGER" = "$exec" ]; then
			pre='[*]' ; else
			pre='[ ]' ; fi

			cmd="$cmd
			    '$pre Use $name as default Windowmanager'
			    'set_wm $exec'"
		  fi
		done

		cmd="$cmd '' ''"

		cmd="$cmd
		'Edit/View /etc/X11/xorg.conf'
			'gui_edit xorg.conf /etc/X11/xorg.conf'
		'Edit/View /etc/profile.d/windowmanager'
			'gui_edit WINDOWMANAGER /etc/profile.d/windowmanager'"

		eval $cmd
	do : ; done
}

