#!/bin/sh
# --- T2-COPYRIGHT-NOTE-BEGIN ---
# This copyright note is auto-generated by ./scripts/Create-CopyPatch.
# 
# T2 SDE: misc/archive/findorphans.sh
# Copyright (C) 2006 The T2 SDE Project
# 
# More information can be found in the files COPYING and README.
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; version 2 of the License. A copy of the
# GNU General Public License can be found in the file COPYING.
# --- T2-COPYRIGHT-NOTE-END ---

config=default
root=
folders=

usage() {
	echo "usage: $0 [-cfg <config>|-root <root>|-system]"
}

while [ $# -gt 0 ]; do
	case "$1" in
	-cfg)	config="$2"
		root= ; shift ;;
	-root)	root="$2"; shift ;;
	-system) root=/ ;;
	-just)	shift; folders="$@"; break ;;
	-help)	usage; exit 0 ;;
	*)	echo "ERROR: unknown argument '$1'"
		usage; exit 1 ;;
	esac
	shift
done

if [ -z "$root" ]; then
	if [ ! -f config/$config/config ]; then
		echo "ERROR: '$config' is not a valid config"
		exit 2
	else
		root="build/`grep ' SDECFG_ID=' \
			config/$config/config | cut -d\' -f2`"
	fi
fi

if [ ! -d "$root/var/adm/flists" ]; then
	echo "ERROR: '$root' is not a valid T2 box/sandbox root"
	exit 3
fi	

flists=$( cd "$root"; echo var/adm/flists/* )
realroot=$( cd "$root"; pwd )

findroot=
for f in $folders; do
	findroot="$findroot $realroot/${f#/}"
done
[ "$findroot" ] || findroot="$realroot"

pushd "$realroot" > /dev/null
find $findroot -mindepth 1 \
	\( -path "$realroot/TOOLCHAIN" -o \
	   -path "$realroot/proc" -o \
	   -path "$realroot/tmp" -o \
	   -path '*/.svn' \) -prune \
	-o -print | sed -e "s,^$realroot/,," |
	while read file; do
		if ! grep -q -l "^[^ ]*: ${file}\$" $flists; then
			echo "$file"
		fi
done
popd > /dev/null
