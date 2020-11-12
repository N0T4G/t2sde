#!/usr/bin/gawk -f
# --- T2-COPYRIGHT-NOTE-BEGIN ---
# This copyright note is auto-generated by scripts/Create-CopyPatch.
# 
# T2 SDE: misc/tools-source/smartwr.awk
# Copyright (C) 2020 The T2 SDE Project
# Copyright (C) 1998 - 2003 ROCK Linux Project
# 
# More information can be found in the files COPYING and README.
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; version 2 of the License. A copy of the
# GNU General Public License can be found in the file COPYING.
# --- T2-COPYRIGHT-NOTE-END ---

BEGIN {
	speedargidx = 0;
	sizeargidx = 0;
	ishot = 0;
}

# argument 1, read in smart profile db
ARGIND == 1 {
	hotlist[$2] = 1;
}

# argument 2, read command list from stdin
ARGIND == 2 {
	if (gsub("^-SPEED", "") == 1)
		speedarg[speedargidx++] = $0;
	else if (gsub("^-SIZE", "") == 1)
		sizearg[sizeargidx++] = $0;
	else {
		speedarg[speedargidx++] = $0;
		sizearg[sizeargidx++] = $0;

		# remove path prefix, and lookup hot file
		gsub(".*/", "");
		if (hotlist[$0] == 1)
			ishot = 1;
	}
}

END {
	if (ishot)
		for (i = 0; i < speedargidx; i++)
			print speedarg[i];
	else
		for (i = 0; i < sizeargidx; i++)
			print sizearg[i];
}
