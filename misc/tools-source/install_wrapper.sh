#!/bin/bash
# --- T2-COPYRIGHT-NOTE-BEGIN ---
# This copyright note is auto-generated by ./scripts/Create-CopyPatch.
# 
# T2 SDE: misc/tools-source/install_wrapper.sh
# Copyright (C) 2004 - 2005 The T2 SDE Project
# 
# More information can be found in the files COPYING and README.
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; version 2 of the License. A copy of the
# GNU General Public License can be found in the file COPYING.
# --- T2-COPYRIGHT-NOTE-END ---

PATH="${PATH/:$INSTALL_WRAPPER_MYPATH:/:}"
PATH="${PATH#$INSTALL_WRAPPER_MYPATH:}"
PATH="${PATH%:$INSTALL_WRAPPER_MYPATH}"

filter="${INSTALL_WRAPPER_FILTER:+|} $INSTALL_WRAPPER_FILTER"

if [ "$INSTALL_WRAPPER_NOLOOP" = 1 ]; then
	echo "--"
	echo "Found loop in install_wrapper: $0 $*" >&2
	echo "INSTALL_WRAPPER_MYPATH=$INSTALL_WRAPPER_MYPATH"
	echo "PATH=$PATH"
	echo "--"
	exit 1
fi
export INSTALL_WRAPPER_NOLOOP=1

logfile="${INSTALL_WRAPPER_LOGFILE:-/dev/null}"
[ -z "${logfile##*/*}" -a ! -d "${logfile%/*}" ] && logfile=/dev/null

command="${0##*/}"
destination=""
declare -a sources
newcommand="$command"
sources_counter=0
error=0

echo ""						>> $logfile
echo "$PWD:"					>> $logfile
echo "* ${INSTALL_WRAPPER_FILTER:-No Filter.}"	>> $logfile
echo "- $command $*"				>> $logfile

if [ "${*/--target-directory//}" != "$*" ]; then
	echo "= $command $*" >> $logfile
	$command "$@"; exit $?
fi

while [ $# -gt 0 ]; do
	case "$1" in
		-g|-m|-o|-S|--group|--mode|--owner|--suffix)
			newcommand="$newcommand $1 $2"
			shift 1
			;;
		-s|--strip)
			if [[ "$ROCKCFG_DEBUG" = 0 || $command != *install ]]
			then
				newcommand="$newcommand $1"
			fi
			;;
		-*)
			newcommand="$newcommand $1"
			;;
		*)
			if [ -n "$destination" ]; then
				sources[sources_counter++]="$destination"
			fi
			destination="$1"
			;;
	esac
	shift 1
done

[ -z "${destination##/*}" ] || destination="$PWD/$destination"

if [ "$filter" != " " ]; then
	destination="$( eval "echo \"$destination\" | tr -s '/' $filter" )"
fi

if [ -z "$destination" ]; then
	: do nothing
elif [ $sources_counter -eq 0 ]; then
	echo "+ $newcommand $destination" >> $logfile
	$newcommand "$destination" || error=$?
elif [ -d "$destination" ]; then
	for source in "${sources[@]}"; do
		thisdest="${destination}"
		[ ! -d "${source//\/\///}" ] && thisdest="$thisdest/${source##*/}"
		thisdest="${thisdest//\/\///}"
		[ "$filter" != " " ] && thisdest="$( eval "echo \"$thisdest\" $filter" )"
		if [ ! -z "$thisdest" ]; then
			echo "+ $newcommand $source $thisdest" >> $logfile
			$newcommand "$source" "$thisdest" || error=$?
		fi
	done
else
	echo "+ $newcommand ${sources[*]} $destination" >> $logfile
	$newcommand "${sources[@]}" "$destination" || error=$?
fi

echo "===> Returncode: $error" >> $logfile
exit $error

