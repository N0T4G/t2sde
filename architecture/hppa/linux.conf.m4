dnl --- T2-COPYRIGHT-NOTE-BEGIN ---
dnl This copyright note is auto-generated by ./scripts/Create-CopyPatch.
dnl 
dnl T2 SDE: architecture/hppa/linux.conf.m4
dnl Copyright (C) 2004 - 2017 The T2 SDE Project
dnl 
dnl More information can be found in the files COPYING and README.
dnl 
dnl This program is free software; you can redistribute it and/or modify
dnl it under the terms of the GNU General Public License as published by
dnl the Free Software Foundation; version 2 of the License. A copy of the
dnl GNU General Public License can be found in the file COPYING.
dnl --- T2-COPYRIGHT-NOTE-END ---

# CONFIG_SMP is not set

dnl CONFIG_PA7000=y
CONFIG_PA8X00=y

CONFIG_HPPB=y
CONFIG_GSC_LASI=y
CONFIG_EISA=y
CONFIG_GSC_WAX=y
CONFIG_PCCARD=m

include(`linux-common.conf.m4')
include(`linux-block.conf.m4')
include(`linux-net.conf.m4')
include(`linux-fs.conf.m4')

CONFIG_PDC_CONSOLE=y
CONFIG_FB_STI=y
