/*
 * --- T2-COPYRIGHT-NOTE-BEGIN ---
 * This copyright note is auto-generated by ./scripts/Create-CopyPatch.
 * 
 * T2 SDE: architecture/share/archtest.c
 * Copyright (C) 2004 - 2005 The T2 SDE Project
 * 
 * More information can be found in the files COPYING and README.
 * 
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; version 2 of the License. A copy of the
 * GNU General Public License can be found in the file COPYING.
 * --- T2-COPYRIGHT-NOTE-END ---
 */
#include <stdio.h>

char * isbigendian () {
	/* Are we little or big endian?  From Harbison&Steele.  */
	union { long l; char c[sizeof (long)]; } u;
	u.l=1; return (u.c[0] == 1)?"no":"yes";
}
                    
int main() {
	printf("arch_sizeof_short=%d\n",sizeof(short));
	printf("arch_sizeof_int=%d\n",sizeof(int));
	printf("arch_sizeof_long=%d\n",sizeof(long));
	printf("arch_sizeof_long_long=%d\n",sizeof(long long));
	printf("arch_sizeof_char_p=%d\n",sizeof(char *));
	printf("arch_bigendian=%s\n",isbigendian());
	printf("arch_machine="); fflush(stdout); system("uname -m");
	system("echo arch_target=`uname -m -p | tr ' ' -`-linux");
	return 0;
}
