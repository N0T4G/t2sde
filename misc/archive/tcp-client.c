/*
 * --- ROCK-COPYRIGHT-NOTE-BEGIN ---
 * 
 * This copyright note is auto-generated by ./scripts/Create-CopyPatch.
 * Please add additional copyright information _after_ the line containing
 * the ROCK-COPYRIGHT-NOTE-END tag. Otherwise it might get removed by
 * the ./scripts/Create-CopyPatch script. Do not edit this copyright text!
 * 
 * ROCK Linux: rock-src/misc/archive/tcp-client.c
 * ROCK Linux is Copyright (C) 1998 - 2003 Clifford Wolf
 * 
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version. A copy of the GNU General Public
 * License can be found at Documentation/COPYING.
 * 
 * Many people helped and are helping developing ROCK Linux. Please
 * have a look at http://www.rocklinux.org/ and the Documentation/TEAM
 * file for details.
 * 
 * --- ROCK-COPYRIGHT-NOTE-END ---
 */

#include <arpa/inet.h>
#include <netinet/in.h>
#include <stdio.h>
#include <string.h>
#include <sys/socket.h>
#include <sys/time.h>
#include <sys/types.h>
#include <unistd.h>
#include <termio.h>
#include <stdlib.h>

#define BUFSIZE 1024

int main(int argc, char ** argv) {
	struct sockaddr_in servaddr;
	struct termio tbuf,tbufsav;
	struct timeval tv;
	char buf[BUFSIZE];
	int sockfd,rc,c;
	fd_set rfds;
	
	if (argc != 3) {
		printf("Usage: %s <IP-Address> <TCP-Port>\n",argv[0]);
		return 1;
	}
	
	if ( (sockfd=socket(AF_INET,SOCK_STREAM,0)) < 0 )
		{ perror("socket"); return 1; }
	
	bzero(&servaddr,sizeof(servaddr));
	servaddr.sin_family = AF_INET;
	servaddr.sin_port = htons(atoi(argv[2]));
	if ( inet_pton(AF_INET,argv[1],&servaddr.sin_addr) <= 0 )
		{ printf("Not an IP address: %s\n",argv[1]); return 1; }
	if ( connect(sockfd,&servaddr,sizeof(servaddr)) < 0 )
		{ perror("connect"); return 1; }
	
	if (ioctl(0,TCGETA, &tbuf) == -1) { perror("ioctl1"); return 1; }
	tbufsav=tbuf; tbuf.c_lflag &= ~(ICANON|ECHO);
	if (ioctl(0,TCSETAF, &tbuf) == -1) { perror("ioctl2"); return 1; }
	
	do {
		FD_ZERO(&rfds); FD_SET(sockfd,&rfds); FD_SET(0,&rfds);
		tv.tv_sec=1; tv.tv_usec=0;
		rc=select(sockfd+1, &rfds, NULL, NULL, NULL);
		if (rc == -1) { perror("select"); return 1; }
		if (FD_ISSET(sockfd,&rfds)) {
			rc=read(sockfd,buf,BUFSIZE);
			for (c=0; c<rc; c++)
				if (buf[c]!='\r') write(1,buf+c,1);
		}
		if (FD_ISSET(0,&rfds)) {
			rc=read(0,buf,BUFSIZE);
			for (c=0; c<rc; c+=write(sockfd,buf,rc)) ;
		}
	} while (rc > 0);
	
	if (ioctl(0,TCSETAF, &tbufsav) == -1) { perror("ioctl3"); return 1; }
	return 0;
}
