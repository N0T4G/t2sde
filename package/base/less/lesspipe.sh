#!/bin/sh
#
# --- T2-COPYRIGHT-NOTE-BEGIN ---
# This copyright note is auto-generated by ./scripts/Create-CopyPatch.
# 
# T2 SDE: package/.../less/lesspipe.sh
# Copyright (C) 2004 - 2005 The T2 SDE Project
# Copyright (C) 1998 - 2003 ROCK Linux Project
# 
# More information can be found in the files COPYING and README.
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; version 2 of the License. A copy of the
# GNU General Public License can be found in the file COPYING.
# --- T2-COPYRIGHT-NOTE-END ---

case "$1" in
	# Archives
	*.a) ar t $1;;
	*.tar) tar tvf $1;;
	*.tgz|*.tar.gz|*.tar.[Zz]) tar tvfz $1;;
	*.tbz2|*.tar.bz2) tar tvfI $1;;
	*.zip) unzip -l $1;;
	# Packages
	*.gem) mine -p $1 ; echo -e "\nFile List:" ; mine -l $1;;
	*.rpm) rpm -q -i -p $1 ; echo "File List   :" ; rpm -q -l -p $1;;
	# Manuals
	*ld.so.8) nroff -p -t -c -mandoc $1;;
	*.so.*) ;;
	*.[1-9]|*.[1-9][mxt]|*.[1-9]thr|*.man)
		nroff -p -t -c -mandoc $1;;
	# Compressed manuals
	*.[1-9].gz|*.[1-9][mxt].gz|*.[1-9]thr.gz|*.man.gz|\
	*.[1-9].[Zz]|*.[1-9][mxt].[Zz]|*.[1-9]thr.[Zz]|*.man.[Zz])
		gzip -c -d $1 | nroff -p -t -c -mandoc;;
	*.[1-9].bz2|*.[1-9][mxt].bz2|*.[1-9]thr.bz2|*.man.bz2)
		bzip2 -c -d $1 | nroff -p -t -c -mandoc ;;
	# Compressed files
	*.gz|*.Z|*.z) gzip -c -d $1;;
	*.bz2) bzip2 -c -d $1;;
esac
