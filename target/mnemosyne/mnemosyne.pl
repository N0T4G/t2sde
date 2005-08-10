#!/url/bin/perl
# --- T2-COPYRIGHT-NOTE-BEGIN ---
# This copyright note is auto-generated by ./scripts/Create-CopyPatch.
# 
# T2 SDE: target/mnemosyne/mnemosyne.pl
# Copyright (C) 2004 - 2005 The T2 SDE Project
# 
# More information can be found in the files COPYING and README.
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; version 2 of the License. A copy of the
# GNU General Public License can be found in the file COPYING.
# --- T2-COPYRIGHT-NOTE-END ---

#source ./scripts/functions

sub tgt_mnemosyne_parser {
=for comment
	local output=$( sed -n "s,^#$1: \(.*\),\1,p" $2 )
	if [ -z "$output" ]; then
		[ -z "$3" ] && return 1
		output="$3"
	fi
	echo "$output"
=cut
}

sub tgt_mnemosyne_render {
	my ($root,$pkgseldir,$prefix) = @_;
	my ($file,$dirname,$dirvar,@subdirs,$x);

	# exported variables
	my ($onchoice,$render)=(0,0);

	if ( ($pkgseldir cmp $root) != 0 ) {
		$_=$pkgseldir;
		/^$root\/(.*)/i;
		$dirvar=uc "CFGTEMP_TRG_$prefix"."_$1" ;
		$_=$1;
		/^.*\/([^\/]*)/i;
		$dirname=$1;
		$dirvar=~s/\//_/g;

		print $RULESIN "$dirvar=0\n";
	}

	if ( $dirname ) {
		print $CONFIGIN "if [ \"\$$dirvar\" == 1 ]; then\n";
		$_ = $dirname;
		$_ =~ s/_/ /g;
		print $CONFIGIN "\tcomment '-- $_'\n";
		print $CONFIGIN "\tblock_begin 2\n";
		print $CONFIGIN "fi\n";
	}

	opendir(my $DIR, $pkgseldir);
	foreach( grep { ! /^\./ } readdir($DIR) ) {
		$_ = "$pkgseldir/$_";
		if ( -d $_ ) {
			tgt_mnemosyne_render($root,$_,$prefix);
			/$root\/(.*)/i;
			push @subdirs,($_);
		} else {
			tgt_mnemosyne_render_option("$pkgseldir/$_");
		}
	}
        closedir $DIR;

	if ( $dirname ) {
		print $CONFIGIN "if [ \"\$$dirvar\" == 1 ]; then\n";
		$_ = $dirname;
		$_ =~ s/_/ /g;
		print $CONFIGIN "\tblock_end\n";
		print $CONFIGIN "fi\n";
	}

	if ( $render ) {
		# always display this directory
		print $RULESIN "$dirvar=1\n";
	} else {
		# enable if any of the subdirs is enabled
		if ($dirvar) {
			for (@subdirs) {
				$x = uc $_;
				$x =~ s/\//_/g;
				print $RULESIN "\tif [ \"\$CFGTEMP_TRG_$prefix\_$x\" == 1 ]; then\n";
				print $RULESIN "\t\t$dirvar=1\n";
				print $RULESIN "\tfi\n";
			}
		}
	}
}

sub tgt_mnemosyne_render_option {
=for comment
	local file="$1" var0= var= kind= option= dir=
	local desc= conffile= forced= implied= val=
	local deps= depsin= pkgselfiles=
	local x= y=

	# this defines dir,var0,option and kind acording to the following format.
	# $dir/[$prio-]$var[$option].$kind
	eval `echo $file | \
	sed -n 's|\(.*\)/\([0-9]*\-\)\{0,1\}\([^\.]*\)\(.*\)\{0,1\}\.\([^\.]*\)|dir="\1" var0="\3" option="\4" kind="\5"|p'`
	option=${option#.}
	var=$( echo $var0 | tr [a-z] [A-Z] )
	
	# external data: configin rulesin prefix 
	# global variables: onchoice render

	# var name and description
	case "$kind" in
		choice)
			# new choice?
			[ "$onchoice" -a "$onchoice" != "$var" ] && onchoice=

			desc=$( tgt_mnemosyne_parser Description $file "${var0//_/ } (${option//_/ })" )

			if [ -z "$onchoice" ]; then
				onchoice=$var

				cat <<-EOT >> $rulesin
				  CFGTEMP_TRG_${prefix}_${var}=0
				EOT
				cat <<-EOT >> $configin
				  if [ "\$CFGTEMP_TRG_${prefix}_${var}" == 1 ]; then
				    choice SDECFG_TRG_${prefix}_${var} \${CFGTEMP_TRG_${prefix}_${var}_DEFAULT:-$option} \\
				       \${CFGTEMP_TRG_${prefix}_${var}_LIST}
				  fi
				EOT
			fi
			;;
		ask|all)
			var=$( tgt_mnemosyne_parser Variable $file $var )
			desc=$( tgt_mnemosyne_parser Description $file "${var0//_/ }" )
			[ "$onchoice" ] && onchoice=
			;;
		*)
			continue
			;;
	esac
	var=SDECFG_TRG_${prefix}_${var}

	# dependencies
	# NOTE: don't use spaces on the pkgsel file, only to delimite different dependencies
	deps=
	for x in $( tgt_mnemosyne_parser Dependencies $file ); do
		case "$x" in
			*!=*)	x=${x/!=/ != }	;;
			*==*)	x=${x/==/ == }	;;
			*=*)	x=${x/=/ == }	;;
			*)	x="$x == '1'"	;;
		esac
		if [ "$deps" ]; then
			if [[ "$x" == SDECFG_* ]]; then
				deps="$deps -a \$$x"
			else
				deps="$deps -a \$SDECFG_TRG_${prefix}_$x"
			fi
		else
			if [[ "$x" == SDECFG_* ]]; then
				deps="\$$x"
			else
				deps="\$SDECFG_TRG_${prefix}_$x"
			fi
		fi
	done

	forced=
	# forced options
	for x in $( tgt_mnemosyne_parser Forced $file ); do
		[[ $x != *=* ]] && x="$x='1'"
		forced="$forced SDECFGSET_TRG_${prefix}_${x}"
	done

	# config script file
	conffile=
	if [ -f ${file%.$kind}.conf ]; then
		conffile="${file%.$kind}.conf"
	fi

	# pkgsel files
	pkgselfiles=$file
	if [ "$kind" = "choice" ]; then
		for x in $( tgt_mnemosyne_parser Imply $file ); do
			y=`echo $dir/*$var0.$x.choice`
			if [ -f "$y" ]; then
				pkgselfiles="$pkgselfiles $y"
			fi
		done
	fi

	# content
	case "$kind" in
		ask)	val=$( tgt_mnemosyne_parser Default $file 0 )	;;
		choice)	val=$( tgt_mnemosyne_parser Default $file )	;;
		*)	val=1	;;
	esac

	#
	# output to rules file
	#
	{
	if [ "$deps" -a "$kind" != "choice" ]; then
		echo "CFGTEMP${var#SDECFG}=\${CFGTEMP${var#SDECFG}:-0}"
	fi

	# dependencies
	[ "$deps" ] && echo "if [ $deps ]; then"
	echo -e "  CFGTEMP${var#SDECFG}=1"

	# choice option
	if [ "$kind" == "choice" ]; then
		echo "  var_append CFGTEMP${var#SDECFG}_LIST ' ' '$option ${desc// /_}'"
		if [ "$val" ]; then
			echo "  CFGTEMP${var#SDECFG}_DEFAULT=$val"
		fi
	fi

	# forced
	if [ "$forced" ]; then
		if [ "$kind" == "choice" ]; then
			if [ "$val" ]; then
				cat <<-EOT
				  if [ "\${$var:-$val}" == "$option" ]; then
				EOT
			else
				cat <<-EOT
				  if [ "\$$var" == "$option" ]; then
				EOT
			fi
		elif [ "$val" ]; then
			cat <<-EOT
			  if [ "\${$var:-$val}" == 1 ]; then
			EOT
		else
			cat <<-EOT
			  if [ "\$$var" == 1 ]; then
			EOT
		fi

		for x in $forced; do
			echo "    $x"
		done
		echo "  fi"
	fi

	[ "$deps" ] && echo "fi"
	} >> $rulesin


	#
	# output to config file
	#
	{
	echo "if [ \$CFGTEMP${var#SDECFG} == 1 ]; then"
	
	case "$kind" in
		ask)	echo "   bool '$desc' $var $val"	;;
		choice)	true	;;
		*)	echo "   $var=1"	;;
	esac

	if [ "$kind" == "choice" ]; then
		cat <<-EOT
		  if [ "\$$var" == "$option" ]; then
		EOT
	else
		cat <<-EOT
		   if [ "\$$var" == 1 ]; then
		EOT
	fi
	cat <<-EOT
	      var_append CFGTEMP_TRG_${prefix}_PKGLST ' ' "$pkgselfiles"
	EOT

	# conffiles
	for x in $conffile; do
		echo "      . $x"
	done

	cat <<-EOT
	   fi
	fi
	EOT
	} >> $configin

	if [ "$deps" ]; then
		case "$kind" in
			ask|choice)
				# TODO: add rule: this directory will be shown if these deps are meet
				true	;;
		esac
	else
		case "$kind" in
			ask)	render=1	;;
			choice)	render=1
				# TODO: add rule: always display this choice
				;;
		esac
	fi
=cut
}

sub trg_mnemosyne_filter {
=for comment
	echo "# generated for $SDECFG_TARGET target"
	pkgsel_init
	echo '{ $1="O"; }'
	for file; do
		pkgsel_parse < $file
	done
	pkgsel_finish
=cut
}

if ($#ARGV != 3) {
	print "Usage mnemosyne.pl: <pkgseldir> <prefix> <configin> <rulesin>\n";
	exit (1);
	}

($pkgseldir,$prefix,$configin,$rulesin) = @ARGV;

open($CONFIGIN,'>',$configin);
open($RULESIN,'>',$rulesin);
tgt_mnemosyne_render($pkgseldir,$pkgseldir,$prefix);
close($CONFIGIN);
close($RULESIN);
