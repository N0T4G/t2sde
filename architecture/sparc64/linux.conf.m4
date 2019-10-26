dnl --- T2-COPYRIGHT-NOTE-BEGIN ---
dnl This copyright note is auto-generated by ./scripts/Create-CopyPatch.
dnl 
dnl T2 SDE: architecture/sparc64/linux.conf.m4
dnl Copyright (C) 2004 - 2019 The T2 SDE Project
dnl 
dnl More information can be found in the files COPYING and README.
dnl 
dnl This program is free software; you can redistribute it and/or modify
dnl it under the terms of the GNU General Public License as published by
dnl the Free Software Foundation; version 2 of the License. A copy of the
dnl GNU General Public License can be found in the file COPYING.
dnl --- T2-COPYRIGHT-NOTE-END ---

define(`SPARC', 'SPARC')dnl

CONFIG_SPARC32_COMPAT=y
CONFIG_COMPAT=y
CONFIG_BINFMT_ELF32=y
CONFIG_HUGETLBFS=y
CONFIG_HUGETLB_PAGE=y

CONFIG_RTC=y
CONFIG_SUN_MOSTEK_RTC=y

CONFIG_KEYBOARD_SUNKBD=y
CONFIG_INPUT_MOUSE=y
CONFIG_MOUSE_SERIAL=y
CONFIG_INPUT_SPARCSPKR=y
CONFIG_SERIAL_SUNSU=y
CONFIG_SERIAL_SUNSU_CONSOLE=y
CONFIG_SERIAL_SUBZILOG=y
CONFIG_SERIAL_SUBSAB=y
CONFIG_SERIAL_SUNHV=y

CONFIG_PROM_CONSOLE=y

CONFIG_FB=y
CONFIG_FB_SBUS=y
CONFIG_FB_TCX=y
CONFIG_FB_LEO=y
CONFIG_FB_ATY=y
CONFIG_FB_ATY_CT=y
CONFIG_FB_ATY_GX=y
CONFIG_FB_ATY128=y
CONFIG_FB_FFB=y

# CONFIG_FB_RIVA is not set
# CONFIG_FB_RADEON is not set

CONFIG_FONT_8x16=y
CONFIG_FONT_SUN8x16=y
CONFIG_FONT_SUN12x22=y

include(`linux-common.conf.m4')
include(`linux-block.conf.m4')
include(`linux-net.conf.m4')
include(`linux-fs.conf.m4')

CONFIG_NR_CPUS=4

dnl LSI Logic / Symbios Logic (formerly NCR) 53c810 (rev 01)
dnl does not work reliable with MMIO on my Ultra SPARC 5 -ReneR
# CONFIG_SCSI_SYM53C8XX_IOMAPPED is not set

