# --- ROCK-COPYRIGHT-NOTE-BEGIN ---
# 
# This copyright note is auto-generated by ./scripts/Create-CopyPatch.
# Please add additional copyright information _after_ the line containing
# the ROCK-COPYRIGHT-NOTE-END tag. Otherwise it might get removed by
# the ./scripts/Create-CopyPatch script. Do not edit this copyright text!
# 
# ROCK Linux: rock-src/package/base/sysfiles/stone_mod_packages.sh
# ROCK Linux is Copyright (C) 1998 - 2003 Clifford Wolf
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version. A copy of the GNU General Public
# License can be found at Documentation/COPYING.
# 
# Many people helped and are helping developing ROCK Linux. Please
# have a look at http://www.rocklinux.org/ and the Documentation/TEAM
# file for details.
# 
# --- ROCK-COPYRIGHT-NOTE-END ---
#
# [MAIN] 90 packages Package Management (Install, Update and Remove)

if [ -n "$ROCK_INSTALL_SOURCE_DEV" ] ; then
	dev="$ROCK_INSTALL_SOURCE_DEV"
	dir="/mnt/source" ; root="/mnt/target"
	gasguiopt="-F"

	ROCKCFG_SHORTID="Automatically choose first"
elif [ -n "$ROCK_INSTALL_SOURCE_URL" ] ; then
	dev="NETWORK INSTALL"
	dir="$ROCK_INSTALL_SOURCE_URL"
	root="/mnt/target"
	gasguiopt="-F"

	ROCKCFG_SHORTID="$( grep '^export ROCKCFG_SHORTID=' \
		/etc/ROCK-CONFIG/config 2> /dev/null | cut -f2- -d= )"
	ROCKCFG_SHORTID="${ROCKCFG_SHORTID//\'/}"
else
	dev="/dev/cdroms/cdrom0"
	dir="/mnt/cdrom" ; root="/"
	gasguiopt=""

	ROCKCFG_SHORTID="$( grep '^export ROCKCFG_SHORTID=' \
		/etc/ROCK-CONFIG/config 2> /dev/null | cut -f2- -d= )"
	ROCKCFG_SHORTID="${ROCKCFG_SHORTID//\'/}"
fi

read_ids() {
	mnt="`mktemp`"
	rm -f $mnt ; mkdir $mnt

	cmd="$cmd '' ''"

	if mount $opt $dev $mnt ; then
		for x in `cd $mnt; ls -d */pkgs | cut -f1 -d/` ; do
			cmd="$cmd '$x' 'ROCKCFG_SHORTID=\"$x\"'"
		done
		umount $mnt
	else
		cmd="$cmd 'The medium could not be mounted!' ''"
	fi

	rmdir $mnt
}

startgas() {
	[ -z "$( cd $dir; ls )" ] && mount $opt -v -o ro $dev $dir
	if [ "$ROCKCFG_SHORTID" = "Automatically choose first" ]; then
		ROCKCFG_SHORTID="$( cd $dir; ls -d */pkgs | \
					cut -f1 -d/ | head -n 1 )"
		echo "Using Config-ID <${ROCKCFG_SHORTID:-None}> .."
	fi
	if [ $startgas = 1 ] ; then
		echo
		echo "Running: gasgui $gasguiopt \\"
		echo "                -c '$ROCKCFG_SHORTID' \\"
		echo "                -t '$root' \\"
		echo "                -d '$dev' \\"
		echo "                -s '$dir'"
		echo
		gasgui $gasguiopt -c "$ROCKCFG_SHORTID" -t "$root" -d "$dev" -s "$dir"
	elif [ $startgas = 2 ] ; then
		echo
		echo "Running: stone gas main \\"
		echo "               '$ROCKCFG_SHORTID' \\"
		echo "               '$root' \\"
		echo "               '$dev' \\"
		echo "               '$dir'"
		$STONE gas main "$ROCKCFG_SHORTID" "$root" "$dev" "$dir"
	fi
}

main() {
	local startgas=0
	while : ; do
		cmd="gui_menu packages 'Package Management

Note: You can install, update and remove packages (as well as query
package information) with the command-line tool \"mine\". This is just
a simple frontend for the \"mine\" program.'"

		cmd="$cmd 'Mount Options:  $opt'"
		cmd="$cmd 'gui_input \"Mount Options (e.g. -s -o sync) \" \"\$opt\" opt'"

		cmd="$cmd 'Source Device:  $dev'"
		cmd="$cmd 'gui_input \"Source Device\" \"\$dev\" dev'"

		cmd="$cmd 'Mountpoint:     $dir'"
		cmd="$cmd 'gui_input \"Mountpoint\" \"\$dir\" dir'"

		cmd="$cmd 'ROCK Config ID: $ROCKCFG_SHORTID'"
		cmd="$cmd 'gui_input \"ROCK Config ID\""
		cmd="$cmd \"\$ROCKCFG_SHORTID\" ROCKCFG_SHORTID'"

		read_ids

		cmd="$cmd '' ''"
		type -p gasgui > /dev/null &&
			cmd="$cmd 'Start gasgui Package Manager (recommended)' 'startgas=1'"
		cmd="$cmd 'Start gastone Package manager (minimal)'  'startgas=2'"

		if eval "$cmd" ; then
			if [ $startgas != 0 ]; then
				startgas $startgas
				break
			fi
		else
			break
		fi
	done
}

