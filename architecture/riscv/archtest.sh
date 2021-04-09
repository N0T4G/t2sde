# --- T2-COPYRIGHT-NOTE-BEGIN ---
# This copyright note is auto-generated by scripts/Create-CopyPatch.
# 
# T2 SDE: architecture/riscv/archtest.sh
# Copyright (C) 2004 - 2021 The T2 SDE Project
# 
# More information can be found in the files COPYING and README.
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; version 2 of the License. A copy of the
# GNU General Public License can be found in the file COPYING.
# --- T2-COPYRIGHT-NOTE-END ---

if [ "$SDECFG_RISCV_XLEN" = 32 ]; then
	arch_sizeof_long=4 && arch_sizeof_char_p=4
fi
arch_machine=${arch_machine}${SDECFG_RISCV_XLEN}
arch_target=${arch_machine}-t2-linux-gnu
