在安装unpv13e的时候遇到问题

## 问题

```
$ cd ../libroute/
$ make
gcc -I../lib -g -O2 -D_REENTRANT -Wall   -c -o get_rtaddrs.o get_rtaddrs.c
In file included from get_rtaddrs.c:1:0:
unproute.h:3:45: 致命错误：net/if_dl.h：没有那个文件或目录
 #include <net/if_dl.h>  /* sockaddr_sdl{} */
                                             ^
编译中断。
make: *** [get_rtaddrs.o] 错误 1
$ 
```

## 出错位置

```
Execute the following from the src/ directory:

    ./configure    # try to figure out all implementation differences

    cd lib         # build the basic library that all programs need
    make           # use "gmake" everywhere on BSD/OS systems

    cd ../libfree  # continue building the basic library
    make

    cd ../libroute # only if your system supports 4.4BSD style routing sockets
    make           # only if your system supports 4.4BSD style routing sockets

    cd ../libxti   # only if your system supports XTI
    make           # only if your system supports XTI

    cd ../intro    # build and test a basic client program
    make daytimetcpcli
    ./daytimetcpcli 127.0.0.1
```

## ```if_dl.h```源代码

```c
/*
* Copyright (c) 1990, 1993
* The Regents of the University of California.  All rights reserved.
*
* Redistribution and use in source and binary forms, with or without
* modification, are permitted provided that the following conditions
* are met:
* 1. Redistributions of source code must retain the above copyright
*    notice, this list of conditions and the following disclaimer.
* 2. Redistributions in binary form must reproduce the above copyright
*    notice, this list of conditions and the following disclaimer in the
*    documentation and/or other materials provided with the distribution.
* 3. All advertising materials mentioning features or use of this software
*    must display the following acknowledgement:
* This product includes software developed by the University of
* California, Berkeley and its contributors.
* 4. Neither the name of the University nor the names of its contributors
*    may be used to endorse or promote products derived from this software
*    without specific prior written permission.
*
* THIS SOFTWARE IS PROVIDED BY THE REGENTS AND CONTRIBUTORS ``AS IS'' AND
* ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
* IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
* ARE DISCLAIMED.  IN NO EVENT SHALL THE REGENTS OR CONTRIBUTORS BE LIABLE
* FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
* DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
* OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
* HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
* LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
* OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
* SUCH DAMAGE.
*
* @(#)if_dl.h 8.1 (Berkeley) 6/10/93
* $FreeBSD: src/sys/net/if_dl.h,v 1.10 2000/03/01 02:46:25 archie Exp $
*/

#ifndef _NET_IF_DL_H_
#define _NET_IF_DL_H_

/*
* A Link-Level Sockaddr may specify the interface in one of two
* ways: either by means of a system-provided index number (computed
* anew and possibly differently on every reboot), or by a human-readable
* string such as "il0" (for managerial convenience).
*
* Census taking actions, such as something akin to SIOCGCONF would return
* both the index and the human name.
*
* High volume transactions (such as giving a link-level ``from'' address
* in a recvfrom or recvmsg call) may be likely only to provide the indexed
* form, (which requires fewer copy operations and less space).
*
* The form and interpretation  of the link-level address is purely a matter
* of convention between the device driver and its consumers; however, it is
* expected that all drivers for an interface of a given if_type will agree.
*/

/*
* Structure of a Link-Level sockaddr:
*/
struct sockaddr_dl {
u_char sdl_len; /* Total length of sockaddr */
u_char sdl_family; /* AF_LINK */
u_short sdl_index; /* if != 0, system given index for interface */
u_char sdl_type; /* interface type */
u_char sdl_nlen; /* interface name length, no trailing 0 reqd. */
u_char sdl_alen; /* link level address length */
u_char sdl_slen; /* link layer selector length */
char sdl_data[12]; /* minimum work area, can be larger;
   contains both if name and ll address */
u_short sdl_rcf; /* source routing control */
u_short sdl_route[16]; /* source routing information */
};

#define LLADDR(s) ((caddr_t)((s)->sdl_data + (s)->sdl_nlen))

#ifndef _KERNEL

#include <sys/cdefs.h>

__BEGIN_DECLS
void link_addr __P((const char *, struct sockaddr_dl *));
char *link_ntoa __P((const struct sockaddr_dl *));
__END_DECLS

#endif /* !_KERNEL */

#endif
```

* 源代码网址：http://www.codeforge.com/read/116933/if_dl.h__html
