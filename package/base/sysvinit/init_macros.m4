dnl
dnl Macros for creating the SysV init scripts with nice or raw output
dnl
dnl --- T2-COPYRIGHT-NOTE-BEGIN --- 
dnl This copyright note is auto-generated by ./scripts/Create-CopyPatch.
dnl 
dnl T2 SDE: package/.../sysvinit/init_macros.m4
dnl Copyright (C) 2004 - 2018 The T2 SDE Project
dnl Copyright (C) 1998 - 2003 ROCK Linux Project
dnl 
dnl More information can be found in the files COPYING and README.
dnl 
dnl This program is free software; you can redistribute it and/or modify
dnl it under the terms of the GNU General Public License as published by
dnl the Free Software Foundation; version 2 of the License. A copy of the
dnl GNU General Public License can be found in the file COPYING.
dnl --- T2-COPYRIGHT-NOTE-END ---
dnl
divert(-1)

initstyle = sysv_nice ....... Nice colored output
initstyle = sysv_text ....... Raw text output

ifelse(initstyle, `sysv_nice',
	`define(`IT', `dnl')
	define(`IN', `')'
,
	`define(`IT', `')
	define(`IN', `dnl')'
)

define(`this_is_not_the_first_option', `')
define(`default_restart', `    restart)
	`$'0 stop; `$'0 start
	;;

')

define(`end_restart', ` | restart')

ifelse(initstyle, `sysv_nice', `
	define(`main_begin', `title() {
	local x w="`$'(stty size 2>/dev/null </dev/tty | cut -d" " -f2)"
	[ -z "`$'w" ] && w="`$'(stty size </dev/console | cut -d" " -f2)"
	printf "%0$((w-1))s"| tr \  .
	echo -e "\e[255G\e[4D v  \r\e[36m`$'* \e[0m"
	error=0
}

status() {
	if [ `$'error -eq 0 ]
	then
		echo -e "\e[1A\e[255G\e[7D\e[32m [ OK ]\e[0m"
	else
		echo -e "\e[1A\e[255G\e[7D\a\e[1;31m [FAIL]\e[0m"
	fi
}

case "`$'1" in')
' , `
	define(`main_begin', `case "`$'1" in')
')
define(`main_end', `default_restart    *)
	echo "Usage: `$'0 { undivert(1)end_restart }"
	exit 1 ;;

esac

exit 0')

ifelse(initstyle, `sysv_nice', `

	define(`echo_title', `ifelse(`$1', `', `define(`dostatus', 0)dnl', `define(`dostatus', 1)	title "$1"')')

	define(`echo_status', `ifelse(dostatus, 1, `	status', `dnl')')

	define(`check', `ifelse(dostatus, 1, `$* || error=$?', `$*')')

' , `

	define(`echo_title', `ifelse(`$1', `', `dnl', `	echo "$1"')')
	define(`echo_status', `dnl')
	define(`check', `$*')
')

define(`block_begin', `$1)
divert(1)dnl
this_is_not_the_first_option`$1'dnl
define(`this_is_not_the_first_option',` | ')dnl
define(`default_$1', `')dnl
define(`end_$1', `')dnl
divert(0)dnl
echo_title(`$2')')

define(`block_split', `echo_status

echo_title(`$1')')

define(`block_end', `echo_status
	;;')

divert(0)dnl
