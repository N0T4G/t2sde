# --- ROCK-COPYRIGHT-NOTE-BEGIN ---
# 
# This copyright note is auto-generated by ./scripts/Create-CopyPatch.
# Please add additional copyright information _after_ the line containing
# the ROCK-COPYRIGHT-NOTE-END tag. Otherwise it might get removed by
# the ./scripts/Create-CopyPatch script. Do not edit this copyright text!
# 
# ROCK Linux: rock-src/package/*/sysfiles/stone_mod_gas.sh
# Copyright (C) 1998 - 2003 ROCK Linux Project
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

select_packages() {
	local namever installed uninstalled

	for (( ; ; )) ; do
		cmd="gui_menu gastone 'Install/Remove packages: $5

Note: any (un)installations are done immediately'"

		installed=""
		uninstalled=""
		for (( i=${#pkgs[@]} - 1; i >= 0; i-- )) ; do
			if echo "${cats[$i]}" | grep -q -F "$5" ; then
				namever="${pkgs[$i]}-${vers[$i]}"
				if [ -f $2/var/adm/packages/${pkgs[$i]} ] ; then
					cmd="$cmd '[*] $namever' '$packager -r -R $2 ${pkgs[$i]}'"
					installed="$installed ${pkgs[$i]}"
				elif [ -f "$4/$1/pkgs/$namever$ext" ] ; then
					cmd="$cmd '[ ] $namever' '$packager -i -R $2 $4/$1/pkgs/$namever$ext'"
					uninstalled="$uninstalled $namever$ext"
				elif [ -f "$4/$1/pkgs/${pkgs[$i]}$ext" ] ; then
					cmd="$cmd '[ ] $namever' '$packaher -i -R $2 $4/$1/pkgs/${pkgs[$i]}$ext'"
					uninstalled="$uninstalled ${pkgs[$i]}$ext"
				fi
			fi
		done
		[ "$uninstalled$installed" ] && cmd="$cmd '' ''"
		[ "$uninstalled" ] && \
			cmd="$cmd 'Install all packages marked as [ ]' '(cd $4/$1/pkgs ; $packager -i -R $2 $uninstalled)'"
		[ "$installed" ] && \
			cmd="$cmd 'Uninstall all packages marked as [*]' '$packager -r -R $2 $installed'"

		eval "$cmd" || break
	done
}

main() {
	if ! [ -f $4/$1/pkgs/packages.db ] ; then
		gui_message "gas: package database not accessible."
		return
	fi

	if ! [ -d $2 ] ; then
		gui_message "gas: target directory not accessible."
		return
	fi

	if [ $2 = "${2#/}" ] ; then
		gui_message "gas: target directory not absolute."
		return
	fi

	local packager ext

	if type -p bize > /dev/null && ! type -p mine > /dev/null ; then
		packager=bize
		ext=.tar.bz2
	else
		packager=mine
		ext=.gem
	fi

	declare -a pkgs vers cats
	local a b category
	unset package

	while read a b ; do
		if [ "$a" = "[C]" ] ; then cats[${#pkgs[@]}]="${cats[${#pkgs[@]}]} $b"
		elif [ "$a" = "[V]" ] ; then vers[${#pkgs[@]}]="$b"
		elif [ -z "$b" ] ; then
			pkgs[${#pkgs[@]}]="$package"
			vers[${#pkgs[@]}]="0.0"
			cats[${#pkgs[@]}]="all/all"
			package="$a"
		else
			gui_message "gas: invalid package database input '$a $b'."
			return
		fi
	done < <( gzip -d < $4/$1/pkgs/packages.db | grep "^[a-zA-Z0-9_+.-]\+$\|^\[[CV]\]")
	[ "$package" ] && pkgs[${#pkgs[@]}]="$package"

	category="gui_menu category 'Select category'"
	for i in `echo ${cats[@]} | sed -e 's/ /\n/g' | sort -u` ; do
		category="$category $i 'select_packages $1 $2 $3 $4 $i'"
	done
	while eval "$category" ; do : ; done
}
