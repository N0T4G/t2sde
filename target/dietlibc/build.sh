# --- T2-COPYRIGHT-NOTE-BEGIN ---
# This copyright note is auto-generated by ./scripts/Create-CopyPatch.
# 
# T2 SDE: target/dietlibc/build.sh
# Copyright (C) 2004 - 2005 The T2 SDE Project
# 
# More information can be found in the files COPYING and README.
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; version 2 of the License. A copy of the
# GNU General Public License can be found in the file COPYING.
# --- T2-COPYRIGHT-NOTE-END ---

# This is the shortest possible target build.sh script. Some targets will
# add code after calling pkgloop() or modify pkgloop's behavior by defining
# a new pkgloop_action() function.
#
pkgloop

echo_header "Finishing build."

echo_status "Creating package database ..."
admdir="build/${ROCKCFG_ID}/var/adm"
create_package_db $admdir build/${ROCKCFG_ID}/TOOLCHAIN/pkgs \
		  build/${ROCKCFG_ID}/TOOLCHAIN/pkgs/packages.db

echo_status "Creating isofs.txt file .."
cat << EOT > build/${ROCKCFG_ID}/TOOLCHAIN/isofs.txt
DISK1   $admdir/cache/					${ROCKCFG_SHORTID}/info/cache/
DISK1   $admdir/cksums/					${ROCKCFG_SHORTID}/info/cksums/
DISK1   $admdir/dependencies/				${ROCKCFG_SHORTID}/info/dependencies/
DISK1   $admdir/descs/					${ROCKCFG_SHORTID}/info/descs/
DISK1   $admdir/flists/					${ROCKCFG_SHORTID}/info/flists/
DISK1   $admdir/md5sums/				${ROCKCFG_SHORTID}/info/md5sums/
DISK1   $admdir/packages/				${ROCKCFG_SHORTID}/info/packages/
EVERY   build/${ROCKCFG_ID}/TOOLCHAIN/pkgs/packages.db	${ROCKCFG_SHORTID}/pkgs/packages.db
SPLIT   build/${ROCKCFG_ID}/TOOLCHAIN/pkgs/			${ROCKCFG_SHORTID}/pkgs/
EOT
