dnl --- T2-COPYRIGHT-NOTE-BEGIN ---
dnl This copyright note is auto-generated by ./scripts/Create-CopyPatch.
dnl 
dnl T2 SDE: architecture/alpha/linux.conf.m4
dnl Copyright (C) 2004 - 2017 The T2 SDE Project
dnl 
dnl More information can be found in the files COPYING and README.
dnl 
dnl This program is free software; you can redistribute it and/or modify
dnl it under the terms of the GNU General Public License as published by
dnl the Free Software Foundation; version 2 of the License. A copy of the
dnl GNU General Public License can be found in the file COPYING.
dnl --- T2-COPYRIGHT-NOTE-END ---
define(`ALPHA', `Alpha AXP')dnl

CONFIG_ALPHA_GENERIC=y
# CONFIG_BINFMT_EM86 is not set


include(`linux-common.conf.m4')
include(`linux-block.conf.m4')
CONFIG_BLK_DEV_CY82C693=y

include(`linux-net.conf.m4')
include(`linux-fs.conf.m4')
