# --- T2-COPYRIGHT-NOTE-BEGIN ---
# This copyright note is auto-generated by scripts/Create-CopyPatch.
# 
# T2 SDE: architecture/x86/linux.conf.sh
# Copyright (C) 2004 - 2021 The T2 SDE Project
# 
# More information can be found in the files COPYING and README.
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; version 2 of the License. A copy of the
# GNU General Public License can be found in the file COPYING.
# --- T2-COPYRIGHT-NOTE-END ---

{
	cat <<- 'EOT'
		define(`INTEL', `Intel X86 PCs')dnl
		
		dnl CPU configuration
		dnl

		# CONFIG_64BIT is not set
	EOT

	# all CPUs with PAE must sort after pentiumpro
	linux_arch=386
	for x in "i386		386"		\
		 "i486		486"		\
		 "c3		MCYRIXIII"	\
		 "c3-2		MVIAC3_2"	\
		 "pentium	586"		\
		 "pentium-mmx	586MMX"		\
		 "i686		686"		\
		 "geodelx	GEODE_LX"	\
		 "k6		K6"		\
		 "k6-2		K6"		\
		 "k6-3		K6"		\
		 "pentiumpro	686"		\
		 "pentium2	PENTIUMII"	\
		 "pentium3	PENTIUMIII"	\
		 "pentium4	PENTIUM4"	\
		 "pentium-m	PENTIUMM"	\
		 "atom		ATOM"		\
		 "athlon	K7"		\
		 "athlon-tbird	K7"		\
		 "athlon4	K7"		\
		 "athlon-xp	K7"		\
		 "athlon-mp	K7"
	do
		set $x # split line into $1, $2
		[ "$1" == "pentiumpro" ] && pae=1
		if [ "$1" == "$SDECFG_X86_OPT" ]; then
			linux_arch=$2
			break
		fi
	done

	# echo `grep -A 20 'Processor family' \
	#	/usr/src/linux/arch/i386/config.in | expand | \
	#	cut -c 57- | cut -f1 -d' ' | tr -d '"'`
	#
	for x in 386 486 586 586TSC 586MMX 686 PENTIUMIII PENTIUM4 PENTIUMM \
	         K6 K7 K8 ELAN CRUSOE WINCHIPC6 WINCHIP2 WINCHIP3D \
	         CYRIXIII VIAC3_2 ATOM GEODE_LX
	do
		if [ "$linux_arch" != "$x" ]
		then echo "# CONFIG_M$x is not set"
		else echo "CONFIG_M$x=y" ; fi
	done

	case "$linux_arch" in
		386|486)  echo "CONFIG_MATH_EMULATION=y" ;;
		*) echo "# CONFIG_MATH_EMULATION is not set" ;;
	esac

	[ "$pae" ] && cat <<- 'EOT'
		dnl Allow more than 4GB (split 3/1) of RAM by default
		dnl (and NX (Execute Disable) protection)
		dnl
		CONFIG_HIGHMEM=y
		CONFIG_HIGHMEM4G=y
		CONFIG_HIGHMEM64G=y
		CONFIG_X86_PAE=y
	EOT

	echo
	cat <<- 'EOT'
		include(`linux-x86.conf.m4')
		include(`linux-common.conf.m4')
		include(`linux-block.conf.m4')
		include(`linux-net.conf.m4')
		include(`linux-fs.conf.m4')

		# CONFIG_NAMESPACES is not set
		# CONFIG_SMP is not set
		# CONFIG_IOMMU_SUPPORT is not set
		# CONFIG_SFI is not set

		CONFIG_RTC_DRV_CMOS=y
	EOT
} | m4 -I $base/architecture/$arch -I $base/architecture/share
