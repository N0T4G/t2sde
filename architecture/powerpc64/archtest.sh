# --- T2-COPYRIGHT-NOTE-BEGIN ---
# This copyright note is auto-generated by scripts/Create-CopyPatch.
# 
# T2 SDE: architecture/powerpc64/archtest.sh
# Copyright (C) 2004 - 2020 The T2 SDE Project
# 
# More information can be found in the files COPYING and README.
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; version 2 of the License. A copy of the
# GNU General Public License can be found in the file COPYING.
# --- T2-COPYRIGHT-NOTE-END ---

case "$SDECFG_POWERPC64_ENDIANESS" in
    le)
	arch_bigendian=no
	arch_machine="${arch_machine/powerpc64/powerpc64le}"
	arch_target="${arch_target/powerpc64/powerpc64le}"
	;;
esac
