#!/bin/sh
#
# --- T2-COPYRIGHT-NOTE-BEGIN ---
# This copyright note is auto-generated by ./scripts/Create-CopyPatch.
# 
# T2 SDE: misc/tools-source/fl_wrapper_test.sh
# Copyright (C) 2004 - 2005 The T2 SDE Project
# Copyright (C) 1998 - 2003 ROCK Linux Project
# 
# More information can be found in the files COPYING and README.
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; version 2 of the License. A copy of the
# GNU General Public License can be found in the file COPYING.
# --- T2-COPYRIGHT-NOTE-END ---

for x in exec{l,v}{,p,e} ; do
touch fltest_$x ; done

sh fl_wrapper.c.sh > fl_wrapper.c
gcc -Wall -O2 -ldl -shared -o fl_wrapper.so fl_wrapper.c

echo -n > rlog.txt
echo -n > wlog.txt

export FLWRAPPER_RLOG=rlog.txt
export FLWRAPPER_WLOG=wlog.txt

gcc fl_wrapper_test.c -o fltest_bin
LD_PRELOAD=./fl_wrapper.so ./fltest_bin

rm fltest_* fl_wrapper.so

