## UDP简介

* UDP与TCP相比，UDP是没有链接的协议，可以把他比作电子邮件，收信方不需要确认就可以接收邮件（不需要握手），这一点以TCP协议不同。

下面简单介绍GitHub上的开源项目TCP-Socket

结果是这样的

```shell
$ ./server &
$ ./client 127.0.0.1
this is a test
this is a test
```

## 服务器端代码```server.c```

```c
#include <stdio.h>
#include <stdlib.h>
#include <sys/socket.h>
#include <string.h>
#include <sys/types.h>
#include <netinet/ip.h>

const int SERV_PORT = 6000;
const int MAXLINE = 2048;

void dg_echo(int sockfd , struct sockaddr *pcliaddr , socklen_t clilen)
{
	int n;
	socklen_t len;
	char mesg[MAXLINE];

	for( ; ;)
	{
		len = clilen;
		if((n = recvfrom(sockfd , mesg , MAXLINE , 0 , pcliaddr , &len)) <0)
		{
			perror("recvfrom error");
			exit(1);
		}//if

		if((n = sendto(sockfd , mesg , n , 0 , pcliaddr , len)) < 0)
		{
			perror("sendto error");
			exit(1);
		}//if
	}//for

}

int main(int argc , char **argv)
{
	int sockfd;
	struct sockaddr_in servaddr , cliaddr;

	bzero(&servaddr , sizeof(servaddr));
	servaddr.sin_family = AF_INET;
	servaddr.sin_addr.s_addr = htonl(INADDR_ANY);
	servaddr.sin_port = htons(SERV_PORT);

	if((sockfd = socket(AF_INET , SOCK_DGRAM , 0)) < 0)
	{
		perror("socket error");
		exit(1);
	}//if

	if(bind(sockfd , (struct sockaddr *)&servaddr , sizeof(servaddr)))
	{
		perror("bind error");
		exit(1);
	}//if

	dg_echo(sockfd , (struct sockaddr *)&cliaddr , sizeof(cliaddr));	
}
```

## 客户端代码```client.c```

```c
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/socket.h>
#include <netinet/in.h>

const int SERV_PORT = 6000;
const int MAXLINE = 2048;

void dg_cli(FILE *fp , int sockfd , const struct sockaddr *pservaddr , socklen_t servlen)
{
	int n;
	char sendline[MAXLINE] , recvline[MAXLINE+1];
	
	while(fgets(sendline , MAXLINE , fp) != NULL)
	{
		if(sendto(sockfd , sendline , strlen(sendline) , 0 , pservaddr ,  servlen) < 0)
		{
			perror("sendto error");
			exit(1);
		}//if

		if( ( n = recvfrom(sockfd , recvline , MAXLINE , 0 , NULL , NULL)) < 0)
		{
			perror("recvfrom error");
			exit(1);
		}//if

		recvline[n] = '\0';
		fputs(recvline , stdout);

	}//while
}

int main(int argc , char **argv)
{
	int sockfd , t;
	struct sockaddr_in servaddr;
	if(argc != 2)
	{
		perror("usage: udpcli <IPaddress>");
		exit(1);
	}//if

	bzero(&servaddr , sizeof(servaddr));
	servaddr.sin_family = AF_INET;
	servaddr.sin_port = htons(SERV_PORT);
	if((t = inet_pton(AF_INET , argv[1], &servaddr.sin_addr)) <= 0)
	{
		perror("inet_pton error");
		exit(1);
	}//if
	
	if((sockfd = socket(AF_INET , SOCK_DGRAM , 0)) < 0)
	{
		perror("socket error");
		exit(1);
	}//if

	dg_cli(stdin , sockfd , (struct sockaddr *)&servaddr , sizeof(servaddr)) ;
	exit(0);
} 
```

## ```Makefile```

```Makefile
ALL:
	gcc server.c -o server -lm
	gcc client.c -o client -lm
```

* 代码来自GitHub帐号，此为学习笔记，源代码请查看GitHub
