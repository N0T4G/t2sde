# --- ROCK-COPYRIGHT-NOTE-BEGIN ---
# 
# This copyright note is auto-generated by ./scripts/Create-CopyPatch.
# Please add additional copyright information _after_ the line containing
# the ROCK-COPYRIGHT-NOTE-END tag. Otherwise it might get removed by
# the ./scripts/Create-CopyPatch script. Do not edit this copyright text!
# 
# ROCK Linux: rock-src/package/base/linux24/lx_config.sh
# ROCK Linux is Copyright (C) 1998 - 2003 Clifford Wolf
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version. A copy of the GNU General Public
# License can be found at Documentation/COPYING.
# 
# Many people helped and are helping developing ROCK Linux. Please
# have a look at http://www.rocklinux.org/ and the Documentation/TEAM
# file for details.
# 
# --- ROCK-COPYRIGHT-NOTE-END ---

treever=${pkg/linux/} ; treever=${treever/-*/}
archdir="$base/download/$repository/linux$treever"
srctar="linux-${vanilla_ver}.tar.bz2"

lx_cpu=`echo "$arch" | sed -e s/x86/i386/ -e s/powerpc/ppc/`
MAKE="$MAKE CROSS_COMPILE=$archprefix KCC=$KCC ARCH=$lx_cpu"

lx_config ()
{
	echo "Generic linux source patching and configuration ..."

	for x in $lx_patches ; do
		echo "Applying $x ..."
		[ -e $x ] || x=$archdir/$x
		if [[ $x = *.bz2 ]] ; then
		  bzcat $x | patch -p1 -s
		else
		  cat $x | patch -p1 -s
		fi
	done

	hook_eval prepatch
	echo "Patching ..."
		for x in $patchfiles ; do
		echo "Applying '$x' ..."
		patch -p1 -s < $x
	done
	hook_eval postpatch

	echo "Redefining some VERSION flags ..."
	sed -e "s/EXTRAVERSION =.*/EXTRAVERSION = -${ver/[0-9,.]*-/}-rock/" \
		Makefile > Makefile.new
	mv Makefile.new Makefile

	echo "Correcting user and permissions ..."
	chown -R root.root . * ; chmod -R u=rwX,go=rX .

	if [[ $treever = 24* ]] ; then
		echo "Create symlinks and a few headers for <$lx_cpu> ... "
		make ARCH=$lx_cpu include/linux/version.h symlinks
		cp $base/package/base/linux24/autoconf.h include/linux/
		touch include/linux/modversions.h
	fi

	echo "Creating default configuration ...."

	if [ -f $base/architecture/$arch/kernel$treever.conf.sh ] ; then
		echo "  using: architecture/$arch/kernel$treever.conf.sh"
		. $base/architecture/$arch/kernel$treever.conf.sh > .config
	elif [ -f $base/architecture/$arch/kernel$treever.conf.m4 ] ; then
		echo "  using: architecture/$arch/kernel$treever.conf.m4"
		m4 -I $base/architecture/$arch -I $base/architecture/share \
		   $base/architecture/$arch/kernel$treever.conf.m4 > .config
	elif [ -f $base/architecture/$arch/kernel$treever.conf ] ; then
		echo "  using: architecture/$arch/kernel$treever.conf"
		cp $base/architecture/$arch/kernel$treever.conf .config
	elif [ -f $base/architecture/$arch/kernel.conf.sh ] ; then
		echo "  using: architecture/$arch/kernel.conf.sh"
		. $base/architecture/$arch/kernel.conf.sh > .config
	elif [ -f $base/architecture/$arch/kernel.conf.m4 ] ; then
		echo "  using: architecture/$arch/kernel.conf.m4"
		m4 -I $base/architecture/$arch -I $base/architecture/share \
		   $base/architecture/$arch/kernel.conf.m4 > .config
	elif [ -f $base/architecture/$arch/kernel.conf ] ; then
		echo "  using: architecture/$arch/kernel.conf"
		cp $base/architecture/$arch/kernel.conf .config
	else
		echo "  using: no rock kernel config found"
		cp arch/$lx_cpu/defconfig .config
	fi

	echo "  merging (system default): 'arch/$lx_cpu/defconfig'"
	grep '^CONF.*=y' arch/$lx_cpu/defconfig | cut -f1 -d= | \
	while read tag ; do egrep -q "(^| )$tag[= ]" .config || echo "$tag=y"
	  done >> .config

	# all modules needs to be first so modules can be disabled by i.e.
	# the targets later
	echo "Enabling all modules ..."
	yes '' | make ARCH=$lx_cpu no2modconfig > /dev/null

	if [ -f $base/target/$target/kernel$treever.conf.sh ] ; then
		conffiles="$base/target/$target/kernel$treever.conf.sh $conffiles"
	elif [ -f $base/target/$target/kernel.conf.sh ] ; then
		conffiles="$base/target/$target/kernel.conf.sh $conffiles"
	fi

	for x in $conffiles ; do
		echo "  running: $x"
		sh $x .config
	done

	# merge target config
	if [ -f $base/config/$config/linux.cfg ] ; then
		echo "  merging: 'config/$config/linux.cfg'"
		x="$(sed '/CONFIG_/ ! d; s,.*CONFIG_\([^ =]*\).*,\1,' \
			$base/config/$config/linux.cfg | tr '\n' '|')"
		egrep -v "\bCONFIG_($x)\b" < .config > .config_new
		sed 's,\(CONFIG_.*\)=n,# \1 is not set,' \
			$base/config/$config/linux.cfg >> .config_new
		mv .config_new .config
	fi

	# create a valid .config
	yes '' | make ARCH=$lx_cpu oldconfig > /dev/null

	# last disable broken crap
	sh $base/package/base/linux24/disable-broken.sh \
	$pkg_linux_brokenfiles < .config > config.new
	mv config.new .config

	# create a valid .config (dependencies might need to be disabled)
	yes '' | make ARCH=$lx_cpu oldconfig > /dev/null

	# save final config
	cp .config .config_modules

	echo "Creating config without modules ...."
	sed "s,\(CONFIG_.*\)=m,# \1 is not set," .config > .config_new
	mv .config_new .config
	# create a valid .config (dependencies might need to be disabled)
	yes '' | make ARCH=$lx_cpu oldconfig > /dev/null
	mv .config .config_nomods

	# which .config to use?
	if [ "$ROCKCFG_PKG_LINUX_MODS" = 0 ] ; then
		cp .config_nomods .config
	else
		cp .config_modules .config
	fi

	if [[ $treever = 25* ]] ; then
		echo "Create symlinks and a few headers for <$lx_cpu> ... "
		make ARCH=$lx_cpu include/linux/version.h include/asm
		make ARCH=$lx_cpu oldconfig > /dev/null
	fi

	echo "Clean up the *.orig and *~ files ... "
	rm -f .config.old `find -name '*.orig' -o -name '*~'`

	echo "Generic linux source configuration finished."
}

pkg_linux_brokenfiles="$base/architecture/$arch/kernel-disable.lst \
	$base/architecture/$arch/kernel$treever-disable.lst \
	$base/package/base/linux$treever/disable-broken.lst \
	$pkg_linux_brokenfiles"
