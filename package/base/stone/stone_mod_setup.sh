# --- T2-COPYRIGHT-NOTE-BEGIN ---
# T2 SDE: package/*/stone/stone_mod_setup.sh
# Copyright (C) 2004 - 2021 The T2 SDE Project
# Copyright (C) 1998 - 2003 ROCK Linux Project
# 
# This Copyright note is generated by scripts/Create-CopyPatch,
# more information can be found in the files COPYING and README.
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License version 2.
# --- T2-COPYRIGHT-NOTE-END ---
#
# This module should only be executed once directly after the installation

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
	echo $dev
}

make_fstab() {
	tmp1=`mktemp` ; tmp2=`mktemp`

	# some defaults and fallbacks
	cat <<- EOT > $tmp2
none /proc proc defaults 0 0
none /dev devtmpfs mode=755 0 0
none /dev/pts devpts defaults 0 0
none /dev/shm tmpfs defaults 0 0
none /sys sysfs defaults 0 0
none /tmp tmpfs nosuid,nodev,noexec 0 0
EOT

	# currently mounted filesystems
	sed -e "s/ nfs [^ ]\+/ nfs rw/" < /etc/mtab |
		sed "s/ rw,/ /; s/ rw / defaults /" >> $tmp2
	# currently active swaps
	sed -e 1d -e 's/ .*//' -e 's,.*$,& none swap defaults 0 0,' \
	    /proc/swaps >> $tmp2

	# sort resulting entries and grab the last (e.g. non-default) one
	cut -f2 -d' ' < $tmp2 | sort -u | while read dn; do
		grep " $dn " $tmp2 | tail -n 1 |
		while read dev point type residual; do
			dev=$(get_uuid $dev)
			case $type in
			  *tmpfs|swap)
				echo $dev $point $type $residual && continue ;;
			esac
			case $point in
			  /dev*|/proc*|/sys)
				echo $dev $point $type $residual ;;
			  /)
				echo $dev $point $type ${residual%0 0} 0 1 ;;
			  *)
				echo $dev $point $type ${residual%0 0} 0 2 ;;
			esac
		done
	done > $tmp1

	cat << EOT > $tmp2
ARGIND == 1 {
    for (c=1; c<=NF; c++) if (ss[c] < length(\$c)) ss[c]=length(\$c);
}
ARGIND == 2 {
    for (c=1; c<NF; c++) printf "%-*s",ss[c]+2,\$c;
    printf "%s\n",\$NF;
}
EOT
	gawk -f $tmp2 $tmp1 $tmp1 > /etc/fstab

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
	type -p ldconfig && ldconfig
	export gui_nocancel=1

	make_fstab
	$STONE general set_keymap
	while ! set_rootpw; do :; done

	unset gui_nocancel

	# run the stone modules that registered itself for the first SETUP pass
	while read -u 200 a b c cmd ; do
		$STONE $cmd
	done 200< <( grep -h '^# \[SETUP\] [0-9][0-9] ' \
	          $SETUPD/mod_*.sh | sort )

	cron.run

	# run the postinstall scripts right here
	for x in /etc/postinstall.d/* ; do
		[ -f $x ] || continue
		echo "Running $x ..."
		$x
	done

	exec $STONE
}
