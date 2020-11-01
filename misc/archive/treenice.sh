#!/bin/sh
#
# --- T2-COPYRIGHT-NOTE-BEGIN ---
# This copyright note is auto-generated by scripts/Create-CopyPatch.
# 
# T2 SDE: misc/archive/treenice.sh
# Copyright (C) 2004 - 2020 The T2 SDE Project
# Copyright (C) 1998 - 2003 ROCK Linux Project
# 
# More information can be found in the files COPYING and README.
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; version 2 of the License. A copy of the
# GNU General Public License can be found in the file COPYING.
# --- T2-COPYRIGHT-NOTE-END ---

main() {
	renice $newpriority -p $1
	ls /proc/$1/task | xargs renice $newpriority -p
	for y in `cut -f1,4 -d' ' /proc/[0-9]*/stat | grep " $1\$" | cut -f1 -d' '`
	do main $y "$2  " ; done
}

newpriority=$1
shift

if [ $# = 0 ] ; then
	echo "Usage: $0 <new priority> <pid> [ <pid> [ ... ] ]"
	exit 1
else
	for x ; do
		for y in $( ps -e -o pid,comm | tail -n +2 |
			awk "\$1 == \"$x\" || \$2 == \"$x\" { print \$1; }" )
		do
				main $y ""
		done
	done
fi

exit 0
