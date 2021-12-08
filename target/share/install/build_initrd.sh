#!/bin/bash
# --- T2-COPYRIGHT-NOTE-BEGIN ---
# T2 SDE: target/share/install/build_initrd.sh
# Copyright (C) 2004 - 2021 The T2 SDE Project
# 
# This Copyright note is generated by scripts/Create-CopyPatch,
# more information can be found in the files COPYING and README.
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License version 2.
# --- T2-COPYRIGHT-NOTE-END ---

set -e

[ "$boot_title" ] || boot_title="T2 Installation"

. $base/misc/target/initrd.in
. $base/misc/target/boot.in

cd $build_toolchain

# Additional initrd overlay
#
rm -rf initramfs
mkdir -p initramfs/{,usr/}{,s}bin
# TODO: add gzip ip
cp $build_root/usr/embutils/{tar,readlink,rmdir,bunzip2} initramfs/bin/
cp -a $build_root/usr/bin/{,un}zstd initramfs/usr/bin/
cp $build_root/usr/bin/fget initramfs/bin/

sed '/PANICMARK/Q' $build_root/sbin/initrdinit > initramfs/init
cat $base/target/share/install/init >> initramfs/init
chmod +x initramfs/init

# For each available kernel:
#
arch_boot_cd_pre $isofsdir
for x in `egrep 'X .* KERNEL .*' $base/config/$config/packages |
          cut -d ' ' -f 5`; do
 kernel=${x/_*/}
 for kernelver in `sed -n "s,.*boot/kconfig.,,p" $build_root/var/adm/flists/$kernel`; do
  initrd="initrd-$kernelver"
  kernelimg=`ls $build_root/boot/vmlinu?-$kernelver`
  kernelimg=${kernelimg##*/}

  cp $build_root/boot/vmlinu?-$kernelver $isofsdir/boot/
  cp $build_root/boot/$initrd $isofsdir/boot/
  extend_initrd $isofsdir/boot/$initrd $build_toolchain/initramfs
  arch_boot_cd_add $isofsdir $kernelver "$boot_title" \
                   /boot/$kernelimg /boot/$initrd
  initrd=${initrd/initrd/minird}
  if [ -e $build_root/boot/$initrd ]; then
    cp $build_root/boot/$initrd $isofsdir/boot/
    extend_initrd $isofsdir/boot/$initrd $build_toolchain/initramfs
    arch_boot_cd_add $isofsdir $kernelver-minird "$boot_title (minird)" \
                     /boot/$kernelimg /boot/$initrd
  fi
 done
done

arch_boot_cd_post $isofsdir
