/* ROCK Linux Wrapper for getting a list of created files
 *
 * --- ROCK-COPYRIGHT-NOTE-BEGIN ---
 * 
 * This copyright note is auto-generated by ./scripts/Create-CopyPatch.
 * Please add additional copyright information _after_ the line containing
 * the ROCK-COPYRIGHT-NOTE-END tag. Otherwise it might get removed by
 * the ./scripts/Create-CopyPatch script. Do not edit this copyright text!
 * 
 * ROCK Linux: rock-src/misc/tools-source/fl_wrapper.c.sh
 * Copyright (C) 1998 - 2003 ROCK Linux Project
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
 *
 * gcc -Wall -O2 -ldl -shared -o fl_wrapper.so fl_wrapper.c
 *
 * !!! THIS FILE IS AUTO-GENERATED BY fl_wrapper.c.sh !!!
 *
 * ELF Dynamic Loading Documentation:
 *  - http://www.linuxdoc.org/HOWTO/GCC-HOWTO-7.html
 *  - http://www.educ.umu.se/~bjorn/mhonarc-files/linux-gcc/msg00576.html
 *  - /usr/include/dlfcn.h
 */


/* Headers and prototypes */

#define DEBUG 0
#define DLOPEN_LIBC 1
#ifndef FLWRAPPER_LIBC
#  define FLWRAPPER_LIBC "libc.so.6"
#endif

#define _GNU_SOURCE
#define _REENTRANT

#define open   xxx_open
#define open64 xxx_open64
#define mknod  xxx_mknod

#  include <dlfcn.h>
#  include <errno.h>
#  include <fcntl.h>
#  include <stdio.h>
#  include <stdlib.h>
#  include <string.h>
#  include <sys/stat.h>
#  include <sys/types.h>
#  include <unistd.h>
#  include <utime.h>
#  include <stdarg.h>

#undef mknod
#undef open
#undef open64

static void * get_dl_symbol(char *);

struct status_t {
	ino_t   inode;
	off_t   size;
	time_t  mtime;
	time_t  ctime;
};

static void handle_file_access_before(const char *, const char *, struct status_t *);
static void handle_file_access_after(const char *, const char *, struct status_t *);

char *wlog = 0, *rlog = 0, *cmdname = "unkown";

/* Wrapper Functions */

extern int open(const char* f, int a, ...);
int (*orig_open)(const char* f, int a, ...) = 0;

int open(const char* f, int a, ...)
{
	struct status_t status;
	int old_errno=errno;
	int rc;
	mode_t b = 0;

	handle_file_access_before("open", f, &status);
	if (!orig_open) orig_open = get_dl_symbol("open");
	errno=old_errno;

#if DEBUG == 1
	fprintf(stderr, "fl_wrapper.so debug [%d]: going to run original open() at %p (wrapper is at %p).\n",
		getpid(), orig_open, open);
#endif

	if (a & O_CREAT) {
	  va_list ap;

	  va_start(ap, a);
	  b = va_arg(ap, mode_t);
	  va_end(ap);

	  rc = orig_open(f, a, b);
	}
	else
	  rc = orig_open(f, a);

	old_errno=errno;
	handle_file_access_after("open", f, &status);
	errno=old_errno;

	return rc;
}

extern int open64(const char* f, int a, ...);
int (*orig_open64)(const char* f, int a, ...) = 0;

int open64(const char* f, int a, ...)
{
	struct status_t status;
	int old_errno=errno;
	int rc;
	mode_t b = 0;

	handle_file_access_before("open64", f, &status);
	if (!orig_open64) orig_open64 = get_dl_symbol("open64");
	errno=old_errno;

#if DEBUG == 1
	fprintf(stderr, "fl_wrapper.so debug [%d]: going to run original open64() at %p (wrapper is at %p).\n",
		getpid(), orig_open64, open64);
#endif

	if (a & O_CREAT) {
	  va_list ap;

	  va_start(ap, a);
	  b = va_arg(ap, mode_t);
	  va_end(ap);

	  rc = orig_open64(f, a, b);
	}
	else
	  rc = orig_open64(f, a);

	old_errno=errno;
	handle_file_access_after("open64", f, &status);
	errno=old_errno;

	return rc;
}

extern FILE* fopen(const char* f, const char* g);
FILE* (*orig_fopen)(const char* f, const char* g) = 0;

FILE* fopen(const char* f, const char* g)
{
	struct status_t status;
	int old_errno=errno;
	FILE* rc;

	handle_file_access_before("fopen", f, &status);
	if (!orig_fopen) orig_fopen = get_dl_symbol("fopen");
	errno=old_errno;

#if DEBUG == 1
	fprintf(stderr, "fl_wrapper.so debug [%d]: going to run original fopen() at %p (wrapper is at %p).\n",
		getpid(), orig_fopen, fopen);
#endif
	rc = orig_fopen(f, g);

	old_errno=errno;
	handle_file_access_after("fopen", f, &status);
	errno=old_errno;

	return rc;
}

extern FILE* fopen64(const char* f, const char* g);
FILE* (*orig_fopen64)(const char* f, const char* g) = 0;

FILE* fopen64(const char* f, const char* g)
{
	struct status_t status;
	int old_errno=errno;
	FILE* rc;

	handle_file_access_before("fopen64", f, &status);
	if (!orig_fopen64) orig_fopen64 = get_dl_symbol("fopen64");
	errno=old_errno;

#if DEBUG == 1
	fprintf(stderr, "fl_wrapper.so debug [%d]: going to run original fopen64() at %p (wrapper is at %p).\n",
		getpid(), orig_fopen64, fopen64);
#endif
	rc = orig_fopen64(f, g);

	old_errno=errno;
	handle_file_access_after("fopen64", f, &status);
	errno=old_errno;

	return rc;
}

extern int creat(const char* f, mode_t m);
int (*orig_creat)(const char* f, mode_t m) = 0;

int creat(const char* f, mode_t m)
{
	struct status_t status;
	int old_errno=errno;
	int rc;

	handle_file_access_before("creat", f, &status);
	if (!orig_creat) orig_creat = get_dl_symbol("creat");
	errno=old_errno;

#if DEBUG == 1
	fprintf(stderr, "fl_wrapper.so debug [%d]: going to run original creat() at %p (wrapper is at %p).\n",
		getpid(), orig_creat, creat);
#endif
	rc = orig_creat(f, m);

	old_errno=errno;
	handle_file_access_after("creat", f, &status);
	errno=old_errno;

	return rc;
}

extern int creat64(const char* f, mode_t m);
int (*orig_creat64)(const char* f, mode_t m) = 0;

int creat64(const char* f, mode_t m)
{
	struct status_t status;
	int old_errno=errno;
	int rc;

	handle_file_access_before("creat64", f, &status);
	if (!orig_creat64) orig_creat64 = get_dl_symbol("creat64");
	errno=old_errno;

#if DEBUG == 1
	fprintf(stderr, "fl_wrapper.so debug [%d]: going to run original creat64() at %p (wrapper is at %p).\n",
		getpid(), orig_creat64, creat64);
#endif
	rc = orig_creat64(f, m);

	old_errno=errno;
	handle_file_access_after("creat64", f, &status);
	errno=old_errno;

	return rc;
}

extern int mkdir(const char* f, mode_t m);
int (*orig_mkdir)(const char* f, mode_t m) = 0;

int mkdir(const char* f, mode_t m)
{
	struct status_t status;
	int old_errno=errno;
	int rc;

	handle_file_access_before("mkdir", f, &status);
	if (!orig_mkdir) orig_mkdir = get_dl_symbol("mkdir");
	errno=old_errno;

#if DEBUG == 1
	fprintf(stderr, "fl_wrapper.so debug [%d]: going to run original mkdir() at %p (wrapper is at %p).\n",
		getpid(), orig_mkdir, mkdir);
#endif
	rc = orig_mkdir(f, m);

	old_errno=errno;
	handle_file_access_after("mkdir", f, &status);
	errno=old_errno;

	return rc;
}

extern int mknod(const char* f, mode_t m, dev_t d);
int (*orig_mknod)(const char* f, mode_t m, dev_t d) = 0;

int mknod(const char* f, mode_t m, dev_t d)
{
	struct status_t status;
	int old_errno=errno;
	int rc;

	handle_file_access_before("mknod", f, &status);
	if (!orig_mknod) orig_mknod = get_dl_symbol("mknod");
	errno=old_errno;

#if DEBUG == 1
	fprintf(stderr, "fl_wrapper.so debug [%d]: going to run original mknod() at %p (wrapper is at %p).\n",
		getpid(), orig_mknod, mknod);
#endif
	rc = orig_mknod(f, m, d);

	old_errno=errno;
	handle_file_access_after("mknod", f, &status);
	errno=old_errno;

	return rc;
}

extern int link(const char* s, const char* f);
int (*orig_link)(const char* s, const char* f) = 0;

int link(const char* s, const char* f)
{
	struct status_t status;
	int old_errno=errno;
	int rc;

	handle_file_access_before("link", f, &status);
	if (!orig_link) orig_link = get_dl_symbol("link");
	errno=old_errno;

#if DEBUG == 1
	fprintf(stderr, "fl_wrapper.so debug [%d]: going to run original link() at %p (wrapper is at %p).\n",
		getpid(), orig_link, link);
#endif
	rc = orig_link(s, f);

	old_errno=errno;
	handle_file_access_after("link", f, &status);
	errno=old_errno;

	return rc;
}

extern int symlink(const char* s, const char* f);
int (*orig_symlink)(const char* s, const char* f) = 0;

int symlink(const char* s, const char* f)
{
	struct status_t status;
	int old_errno=errno;
	int rc;

	handle_file_access_before("symlink", f, &status);
	if (!orig_symlink) orig_symlink = get_dl_symbol("symlink");
	errno=old_errno;

#if DEBUG == 1
	fprintf(stderr, "fl_wrapper.so debug [%d]: going to run original symlink() at %p (wrapper is at %p).\n",
		getpid(), orig_symlink, symlink);
#endif
	rc = orig_symlink(s, f);

	old_errno=errno;
	handle_file_access_after("symlink", f, &status);
	errno=old_errno;

	return rc;
}

extern int rename(const char* s, const char* f);
int (*orig_rename)(const char* s, const char* f) = 0;

int rename(const char* s, const char* f)
{
	struct status_t status;
	int old_errno=errno;
	int rc;

	handle_file_access_before("rename", f, &status);
	if (!orig_rename) orig_rename = get_dl_symbol("rename");
	errno=old_errno;

#if DEBUG == 1
	fprintf(stderr, "fl_wrapper.so debug [%d]: going to run original rename() at %p (wrapper is at %p).\n",
		getpid(), orig_rename, rename);
#endif
	rc = orig_rename(s, f);

	old_errno=errno;
	handle_file_access_after("rename", f, &status);
	errno=old_errno;

	return rc;
}

extern int utime(const char* f, const struct utimbuf* t);
int (*orig_utime)(const char* f, const struct utimbuf* t) = 0;

int utime(const char* f, const struct utimbuf* t)
{
	struct status_t status;
	int old_errno=errno;
	int rc;

	handle_file_access_before("utime", f, &status);
	if (!orig_utime) orig_utime = get_dl_symbol("utime");
	errno=old_errno;

#if DEBUG == 1
	fprintf(stderr, "fl_wrapper.so debug [%d]: going to run original utime() at %p (wrapper is at %p).\n",
		getpid(), orig_utime, utime);
#endif
	rc = orig_utime(f, t);

	old_errno=errno;
	handle_file_access_after("utime", f, &status);
	errno=old_errno;

	return rc;
}

extern int utimes(const char* f, struct timeval* t);
int (*orig_utimes)(const char* f, struct timeval* t) = 0;

int utimes(const char* f, struct timeval* t)
{
	struct status_t status;
	int old_errno=errno;
	int rc;

	handle_file_access_before("utimes", f, &status);
	if (!orig_utimes) orig_utimes = get_dl_symbol("utimes");
	errno=old_errno;

#if DEBUG == 1
	fprintf(stderr, "fl_wrapper.so debug [%d]: going to run original utimes() at %p (wrapper is at %p).\n",
		getpid(), orig_utimes, utimes);
#endif
	rc = orig_utimes(f, t);

	old_errno=errno;
	handle_file_access_after("utimes", f, &status);
	errno=old_errno;

	return rc;
}

extern int execv(const char* f, char* const a[]);
int (*orig_execv)(const char* f, char* const a[]) = 0;

int execv(const char* f, char* const a[])
{
	int old_errno=errno;

	handle_file_access_after("execv", f, 0);
	if (!orig_execv) orig_execv = get_dl_symbol("execv");
	errno=old_errno;

	return orig_execv(f, a);
}

extern int execve(const char* f, char* const a[], char* const e[]);
int (*orig_execve)(const char* f, char* const a[], char* const e[]) = 0;

int execve(const char* f, char* const a[], char* const e[])
{
	int old_errno=errno;

	handle_file_access_after("execve", f, 0);
	if (!orig_execve) orig_execve = get_dl_symbol("execve");
	errno=old_errno;

	return orig_execve(f, a, e);
}

/*
 *  Copyright (C) 1991, 92, 94, 97, 98, 99 Free Software Foundation, Inc.
 *  This file is part of the GNU C Library.
 *
 *  --- NO-ROCK-COPYRIGHT-NOTE ---
 *
 *  glibc-2.2.5/posix/execl.c
 */

/* Execute PATH with all arguments after PATH until
   a NULL pointer and environment from `environ'.  */
int
execl (const char *path, const char *arg, ...)
{
  size_t argv_max = 1024;
  const char **argv = alloca (argv_max * sizeof (const char *));
  unsigned int i;
  va_list args;

  argv[0] = arg;

  va_start (args, arg);
  i = 0;
  while (argv[i++] != NULL)
    {
      if (i == argv_max)
	{
	  const char **nptr = alloca ((argv_max *= 2) * sizeof (const char *));

#ifndef _STACK_GROWS_UP
	  if ((char *) nptr + argv_max == (char *) argv)
	    {
	      /* Stack grows down.  */
	      argv = (const char **) memcpy (nptr, argv,
					     i * sizeof (const char *));
	      argv_max += i;
	    }
	  else
#endif
#ifndef _STACK_GROWS_DOWN
	    if ((char *) argv + i == (char *) nptr)
	    /* Stack grows up.  */
	    argv_max += i;
	  else
#endif
	    /* We have a hole in the stack.  */
	    argv = (const char **) memcpy (nptr, argv,
					   i * sizeof (const char *));
	}

      argv[i] = va_arg (args, const char *);
    }
  va_end (args);

  return execve (path, (char *const *) argv, __environ);
}

/*
 *  Copyright (C) 1991, 92, 94, 97, 98, 99 Free Software Foundation, Inc.
 *  This file is part of the GNU C Library.
 *
 *  glibc-2.2.5/posix/execle.c
 */

/* Execute PATH with all arguments after PATH until a NULL pointer,
   and the argument after that for environment.  */
int
execle (const char *path, const char *arg, ...)
{
  size_t argv_max = 1024;
  const char **argv = alloca (argv_max * sizeof (const char *));
  const char *const *envp;
  unsigned int i;
  va_list args;
  argv[0] = arg;

  va_start (args, arg);
  i = 0;
  while (argv[i++] != NULL)
    {
      if (i == argv_max)
	{
	  const char **nptr = alloca ((argv_max *= 2) * sizeof (const char *));

#ifndef _STACK_GROWS_UP
	  if ((char *) nptr + argv_max == (char *) argv)
	    {
	      /* Stack grows down.  */
	      argv = (const char **) memcpy (nptr, argv,
					     i * sizeof (const char *));
	      argv_max += i;
	    }
	  else
#endif
#ifndef _STACK_GROWS_DOWN
	    if ((char *) argv + i == (char *) nptr)
	    /* Stack grows up.  */
	    argv_max += i;
	  else
#endif
	    /* We have a hole in the stack.  */
	    argv = (const char **) memcpy (nptr, argv,
					   i * sizeof (const char *));
	}

      argv[i] = va_arg (args, const char *);
    }

  envp = va_arg (args, const char *const *);
  va_end (args);

  return execve (path, (char *const *) argv, (char *const *) envp);
}

/*
 *  Copyright (C) 1991, 92, 94, 97, 98, 99 Free Software Foundation, Inc.
 *  This file is part of the GNU C Library.
 *
 *  glibc-2.2.5/posix/execlp.c
 */

/* Execute FILE, searching in the `PATH' environment variable if
   it contains no slashes, with all arguments after FILE until a
   NULL pointer and environment from `environ'.  */
int
execlp (const char *file, const char *arg, ...)
{
  size_t argv_max = 1024;
  const char **argv = alloca (argv_max * sizeof (const char *));
  unsigned int i;
  va_list args;

  argv[0] = arg;

  va_start (args, arg);
  i = 0;
  while (argv[i++] != NULL)
    {
      if (i == argv_max)
	{
	  const char **nptr = alloca ((argv_max *= 2) * sizeof (const char *));

#ifndef _STACK_GROWS_UP
	  if ((char *) nptr + argv_max == (char *) argv)
	    {
	      /* Stack grows down.  */
	      argv = (const char **) memcpy (nptr, argv,
					     i * sizeof (const char *));
	      argv_max += i;
	    }
	  else
#endif
#ifndef _STACK_GROWS_DOWN
	    if ((char *) argv + i == (char *) nptr)
	    /* Stack grows up.  */
	    argv_max += i;
	  else
#endif
	    /* We have a hole in the stack.  */
	    argv = (const char **) memcpy (nptr, argv,
					   i * sizeof (const char *));
	}

      argv[i] = va_arg (args, const char *);
    }
  va_end (args);

  return execvp (file, (char *const *) argv);
}

/*
 *  Copyright (C) 1991, 92, 94, 97, 98, 99 Free Software Foundation, Inc.
 *  This file is part of the GNU C Library.
 *
 *  glibc-2.2.5/posix/execvp.c
 */

/* The file is accessible but it is not an executable file.  Invoke
   the shell to interpret it as a script.  */
static void
script_execute (const char *file, char *const argv[])
{
  /* Count the arguments.  */
  int argc = 0;
  while (argv[argc++])
    ;

  /* Construct an argument list for the shell.  */
  {
    char *new_argv[argc + 1];
    new_argv[0] = (char *) "/bin/sh";
    new_argv[1] = (char *) file;
    while (argc > 1)
      {
	new_argv[argc] = argv[argc - 1];
	--argc;
      }

    /* Execute the shell.  */
    execve (new_argv[0], new_argv, __environ);
  }
}


/* Execute FILE, searching in the `PATH' environment variable if it contains
   no slashes, with arguments ARGV and environment from `environ'.  */
int
execvp (file, argv)
     const char *file;
     char *const argv[];
{
  if (*file == '\0')
    {
      /* We check the simple case first. */
      errno = ENOENT;
      return -1;
    }

  if (strchr (file, '/') != NULL)
    {
      /* Don't search when it contains a slash.  */
      execve (file, argv, __environ);

      if (errno == ENOEXEC)
	script_execute (file, argv);
    }
  else
    {
      int got_eacces = 0;
      char *path, *p, *name;
      size_t len;
      size_t pathlen;

      path = getenv ("PATH");
      if (path == NULL)
	{
	  /* There is no `PATH' in the environment.
	     The default search path is the current directory
	     followed by the path `confstr' returns for `_CS_PATH'.  */
	  len = confstr (_CS_PATH, (char *) NULL, 0);
	  path = (char *) alloca (1 + len);
	  path[0] = ':';
	  (void) confstr (_CS_PATH, path + 1, len);
	}

      len = strlen (file) + 1;
      pathlen = strlen (path);
      name = alloca (pathlen + len + 1);
      /* Copy the file name at the top.  */
      name = (char *) memcpy (name + pathlen + 1, file, len);
      /* And add the slash.  */
      *--name = '/';

      p = path;
      do
	{
	  char *startp;

	  path = p;
	  p = strchrnul (path, ':');

	  if (p == path)
	    /* Two adjacent colons, or a colon at the beginning or the end
	       of `PATH' means to search the current directory.  */
	    startp = name + 1;
	  else
	    startp = (char *) memcpy (name - (p - path), path, p - path);

	  /* Try to execute this name.  If it works, execv will not return.  */
	  execve (startp, argv, __environ);

	  if (errno == ENOEXEC)
	    script_execute (startp, argv);

	  switch (errno)
	    {
	    case EACCES:
	      /* Record the we got a `Permission denied' error.  If we end
		 up finding no executable we can use, we want to diagnose
		 that we did find one but were denied access.  */
	      got_eacces = 1;
	    case ENOENT:
	    case ESTALE:
	    case ENOTDIR:
	      /* Those errors indicate the file is missing or not executable
		 by us, in which case we want to just try the next path
		 directory.  */
	      break;

	    default:
	      /* Some other error means we found an executable file, but
		 something went wrong executing it; return the error to our
		 caller.  */
	      return -1;
	    }
	}
      while (*p++ != '\0');

      /* We tried every element and none of them worked.  */
      if (got_eacces)
	/* At least one failure was due to permissions, so report that
           error.  */
	errno = EACCES;
    }

  /* Return the error from the last attempt (probably ENOENT).  */
  return -1;
}

/* Internal Functions */

static void * get_dl_symbol(char * symname)
{
	void * rc;
#if DLOPEN_LIBC
	static void * libc_handle = 0;

	if (!libc_handle) libc_handle=dlopen(FLWRAPPER_LIBC, RTLD_LAZY);
	if (!libc_handle) {
		fprintf(stderr, "fl_wrapper.so: Can't dlopen libc: %s\n", dlerror()); fflush(stderr);
		abort();
	}

        rc = dlsym(libc_handle, symname);
#  if DEBUG == 1
	fprintf(stderr, "fl_wrapper.so debug [%d]: Symbol '%s' in libc (%p) has been resolved to %p.\n",
		getpid(), symname, libc_handle, rc);
#  endif
	dlclose(libc_handle);
#else
        rc = dlsym(RTLD_NEXT, symname);
#  if DEBUG == 1
	fprintf(stderr, "fl_wrapper.so debug [%d]: Symbol '%s' (RTLD_NEXT) has been resolved to %p.\n",
		getpid(), symname, rc);
#  endif
#endif
	if (!rc) {
		fprintf(stderr, "fl_wrapper.so: Can't resolve %s: %s\n",
		       symname, dlerror()); fflush(stderr);
		abort();
	}

        return rc;
}

static int pid2ppid(int pid)
{
	char buffer[100];
	int fd, rc, ppid = 0;

	sprintf(buffer, "/proc/%d/stat", pid);
	if ( (fd = open(buffer, O_RDONLY, 0)) < 0 ) return 0;
	if ( (rc = read(fd, buffer, 99)) > 0) {
		buffer[rc] = 0;
		/* format: 27910 (bash) S 27315 ... */
		sscanf(buffer, "%*[^ ] %*[^ ] %*[^ ] %d", &ppid);
	}
	close(fd);

	return ppid;
}

/* this is only called from fl_wrapper_init(). so it doesn't need to be
 * reentrant. */
static char *getpname(int pid)
{
	static char p[512];
	char buffer[100]="";
	char *arg=0, *b;
	int i, fd, rc;

	sprintf(buffer, "/proc/%d/cmdline", pid);
	if ( (fd = open(buffer, O_RDONLY, 0)) < 0 ) return "unkown";
	if ( (rc = read(fd, buffer, 99)) > 0) {
		buffer[rc--] = 0;
		for (i=0; i<rc; i++)
			if (!buffer[i]) { arg = buffer+i+1; break; }
	}
	close(fd);

	b = basename(buffer);
	snprintf(p, 512, "%s", b);

	if ( !strcmp(b, "bash") || !strcmp(b, "sh") || !strcmp(b, "perl") )
		if (arg && *arg && *arg != '-')
			snprintf(p, 512, "%s(%s)", b, basename(arg));

	return p;
}

/* invert the order by recursion. there will be only one recursion tree
 * so we can use a static var for managing the last ent */
static void addptree(int *txtpos, char *cmdtxt, int pid, int basepid)
{
	static char l[512] = "";
	char *p;

	if (!pid || pid == basepid) return;

	addptree(txtpos, cmdtxt, pid2ppid(pid), basepid);

	p = getpname(pid);

	if ( strcmp(l, p) )
		*txtpos += snprintf(cmdtxt+*txtpos, 4096-*txtpos, "%s%s",
				*txtpos ? "." : "", getpname(pid));
	else
		*txtpos += snprintf(cmdtxt+*txtpos, 4096-*txtpos, "*");

	strcpy(l, p);
}

void __attribute__ ((constructor)) fl_wrapper_init()
{
	char cmdtxt[4096] = "";
	char *basepid_txt = getenv("FLWRAPPER_BASEPID");
	int basepid = 0, txtpos=0;

	if (basepid_txt)
		basepid = atoi(basepid_txt);

	addptree(&txtpos, cmdtxt, getpid(), basepid);
	cmdname = strdup(cmdtxt);

	wlog = getenv("FLWRAPPER_WLOG");
	rlog = getenv("FLWRAPPER_RLOG");
}

static void handle_file_access_before(const char * func, const char * file,
                               struct status_t * status)
{
	struct stat st;
#if DEBUG == 1
	fprintf(stderr, "fl_wrapper.so debug [%d]: begin of handle_file_access_before(\"%s\", \"%s\", xxx)\n",
		getpid(), func, file);
#endif
	if ( lstat(file,&st) ) {
		status->inode=0;  status->size=0;
		status->mtime=0;  status->ctime=0;
	} else {
		status->inode=st.st_ino;    status->size=st.st_size;
		status->mtime=st.st_mtime;  status->ctime=st.st_ctime;
	}
#if DEBUG == 1
	fprintf(stderr, "fl_wrapper.so debug [%d]: end   of handle_file_access_before(\"%s\", \"%s\", xxx)\n",
		getpid(), func, file);
#endif
}

static void handle_file_access_after(const char * func, const char * file,
                              struct status_t * status)
{
	char buf[512], *buf2, *logfile;
	int fd; struct stat st;

#if DEBUG == 1
	fprintf(stderr, "fl_wrapper.so debug [%d]: begin of handle_file_access_after(\"%s\", \"%s\", xxx)\n",
		getpid(), func, file);
#endif
	if ( wlog != 0 && !strcmp(file, wlog) ) return;
	if ( rlog != 0 && !strcmp(file, rlog) ) return;
	if ( lstat(file, &st) ) return;

	if ( (status != 0) && (status->inode != st.st_ino ||
	     status->size  != st.st_size || status->mtime != st.st_mtime ||
	     status->ctime != st.st_ctime) ) { logfile = wlog; }
	else { logfile = rlog; }

	if ( logfile == 0 ) return;
	fd=open(logfile,O_APPEND|O_WRONLY,0);
	if (fd == -1) return;

	if (file[0] == '/') {
		sprintf(buf,"%s.%s:\t%s\n",
		        cmdname, func, file);
	} else {
		buf2=get_current_dir_name();
		sprintf(buf,"%s.%s:\t%s%s%s\n",
			cmdname, func, buf2,
			strcmp(buf2,"/") ? "/" : "", file);
		free(buf2);
	}
	write(fd,buf,strlen(buf));
	close(fd);
#if DEBUG == 1
	fprintf(stderr, "fl_wrapper.so debug [%d]: end   of handle_file_access_after(\"%s\", \"%s\", xxx)\n",
		getpid(), func, file);
#endif
}
