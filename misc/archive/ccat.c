/* ccat (counting cat)
 *
 * --- T2-COPYRIGHT-NOTE-BEGIN ---
 * --- T2-COPYRIGHT-NOTE-END ---
 */

#define VERSION "2000-06-15"

#include <stdio.h>
#include <string.h>
#include <errno.h>
 
int main(int argc) {
	char s1[]="................................"
	          "................................";
	char buf[10240];
	int c,rc1,rc2;

	if (argc != 1) {
		fprintf(stderr,
"ccat (counting cat) Version " VERSION "\n"
"Copyright (C) 2000  Clifford Wolf, Thomas Baumgartner\n"
"\n"
"     This program is free software; you can redistribute it and/or modify\n"
"     it under the terms of the GNU General Public License as published by\n"
"     the Free Software Foundation; either version 2 of the License, or\n"
"     (at your option) any later version.\n"
"\n"
"     This program is distributed in the hope that it will be useful,\n"
"     but WITHOUT ANY WARRANTY; without even the implied warranty of\n"
"     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the\n"
"     GNU General Public License for more details.\n"
"\n"
"     You should have received a copy of the GNU General Public License\n"
"     along with this program; if not, write to the Free Software\n"
"     Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.\n"
"\n"
"Usage:  `ccat' reads from its stdin and writes to stdout. No command line\n"
"        arguments ar allowed. A status bar is printed to stderr.\n\n"
			); fflush(stderr);
		return 1;
	}

	c=1024; rc1=rc2=0;
	while (1) {
		if (c%1024 == 0) {
			fprintf(stderr,"\r%6d0 MB [%s]\r%6d0 MB [",
			        c/1024,s1,c/1024); fflush(stderr);
		}
		if ( (rc1=read(0,buf,10240)) <= 0 ) { rc2=rc1; break; }
		if (c%16 == 0) {
			fprintf(stderr,"X"); fflush(stderr);
		}
		if ( (rc2=write(1,buf,rc1)) != rc1 ) break;
		c++;
	}

	if (rc1 == -1) {
		fprintf(stderr,"\nRead ERROR: %s\n",strerror(errno));
	} else if (rc2 == -1) {
		fprintf(stderr,"\nWrite ERROR: %s\n",strerror(errno));
	} else if (rc2 != rc1) {
		fprintf(stderr,"\nWrite ERROR: Only %d of %d bytes "
		        "in the last block has been written.\n",rc2,rc1);
	} else
		fprintf(stderr,"\n");

	return 0;
}
