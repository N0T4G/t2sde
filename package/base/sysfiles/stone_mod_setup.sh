# --- ROCK-COPYRIGHT-NOTE-BEGIN ---
# 
# This copyright note is auto-generated by ./scripts/Create-CopyPatch.
# Please add additional copyright information _after_ the line containing
# the ROCK-COPYRIGHT-NOTE-END tag. Otherwise it might get removed by
# the ./scripts/Create-CopyPatch script. Do not edit this copyright text!
# 
# ROCK Linux: rock-src/package/base/sysfiles/stone_mod_setup.sh
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
# This module should only be executed once directly after the installation

make_fstab() {
	tmp1=`mktemp` ; tmp2=`mktemp`

	cat > $tmp2 <<- EOT
/dev/root / auto defaults 0 0
none /proc proc defaults 0 0
none /dev devfs defaults 0 0
none /dev/shm ramfs defaults 0 0
#none /tmp tmpfs defaults 0 0
EOT

	for x in /dev/cdroms/cdrom[0-9] ; do
	    if [ -e $x ] ; then
		mkdir -p /mnt/${x/*\//}
		echo "$x /mnt/${x/*\//} iso9660 ro,noauto 0 0" >> $tmp2
	    fi
	done

	for x in /dev/floppy/[0-9] ; do
	    if [ -e $x ] ; then
		mkdir -p /mnt/floppy${x/*\//}
		echo "$x /mnt/floppy${x/*\//} auto sync,noauto 0 0" >> $tmp2
	    fi
	done

	sed -e "s/ nfs [^ ]\+/ nfs rw/" < /etc/mtab | \
		sed "s/ rw,/ /; s/ rw / defaults /" >> $tmp2
	grep '^/dev/' /proc/swaps | cut -f1 -d' ' | \
		sed 's,$, swap swap defaults 0 0,' >> $tmp2

	cut -f2 -d' ' < $tmp2 | sort -u | while read dn ; do
		grep " $dn " $tmp2 | tail -1; done > $tmp1

	cat << 'EOT' > $tmp2
ARGIND == 1 {
    for (c=1; c<=NF; c++) if (ss[c] < length($c)) ss[c]=length($c);
}
ARGIND == 2 {
    for (c=1; c<NF; c++) printf "%-*s",ss[c]+2,$c;
    printf "%s\n",$NF;
}
EOT
	gawk -f $tmp2 $tmp1 $tmp1 | \
		sed 's,\( ext[23] .*\) 0  0$,\1 0  1,' > /etc/fstab

	while read a b c d e f ; do
		printf "%-60s %s\n" "$(
			printf "%-50s %s" "$(
				printf "%-40s %s" "$(
					printf "%-25s %s" "$a" "$b"
				)" $c
			)" "$d"
		)" "$e $f"
	done < /etc/fstab | tr ' ' '\240' > $tmp1

	gui_message $'Auto-created /etc/fstab file:\n\n'"$( cat $tmp1 )"
	rm -f $tmp1 $tmp2
}

set_rootpw() {
	if [ "$SETUPG" = dialog ] ; then
		tmp1="`mktemp`" ; tmp2="`mktemp`" ; rc=0
		gui_dialog --nocancel --passwordbox "Setting a root password. `
			`Type password:" 8 70 > $tmp1
		gui_dialog --nocancel --passwordbox "Setting a root password. `
			`Retype password:" 8 70 > $tmp2
		if [ -s $tmp1 ] && cmp -s $tmp1 $tmp2 ; then
			echo -n "root:" > $tmp1 ; echo >> $tmp2
			cat $tmp1 $tmp2 | chpasswd
		else
			gui_message "Password 1 and password 2 are `
					`not the same" ; rc=1
		fi
		rm $tmp1 $tmp2
		return $rc
	else
		passwd root
		return $?
	fi
}

main() {
	ldconfig
	export gui_nocancel=1

	make_fstab
	$STONE general set_keymap
	while ! set_rootpw; do :; done
	$STONE general set_tmzone
	$STONE general set_dtime
	$STONE general set_locale

	cron.run

	unset gui_nocancel
	exec $STONE
}

