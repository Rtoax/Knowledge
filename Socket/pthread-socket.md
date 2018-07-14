## pthreat socket

three file in one directory

* ```config.h```
* ```server.c```
* ```client.c```

## ```config.h```

```c
/*
 * config.h 包含该tcp/ip套接字编程所需要的基本头文件，与server.c client.c位于同
一目录下
*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/socket.h>
#include <sys/types.h>
#include <unistd.h>
#include <errno.h>
#include <netinet/in.h>
#include <netdb.h>
#include <arpa/inet.h>
#include <pthread.h>

const int MAX_LINE = 2048;
const int PORT = 6001;
const int BACKLOG = 10;
const int LISTENQ = 6666;
const int MAX_CONNECT = 20;
```

## ```server.c```

```c
/*
*  服务器端代码实现
*/

#include "config.h"

/*处理接收客户端消息函数*/
void *recv_message(void *fd)
{
	int sockfd = *(int *)fd;
	while(1)
	{
		char buf[MAX_LINE];
		memset(buf , 0 , MAX_LINE);
		int n;
		if((n = recv(sockfd , buf , MAX_LINE , 0)) == -1)
		{
			perror("recv error.\n");
			exit(1);
		}//if
		buf[n] = '\0';		
		//若收到的是exit字符，则代表退出通信
		if(strcmp(buf , "byebye.") == 0)
		{
			printf("Client closed.\n");
			close(sockfd);
			exit(1);
		}//if

		printf("\nClient: %s\n", buf);
	}//while
}

int main()
{

	//声明套接字
	int listenfd , connfd;
	socklen_t clilen;
	//声明线程ID
	pthread_t recv_tid , send_tid;

	//定义地址结构
	struct sockaddr_in servaddr , cliaddr;
	
	/*(1) 创建套接字*/
	if((listenfd = socket(AF_INET , SOCK_STREAM , 0)) == -1)
	{
		perror("socket error.\n");
		exit(1);
	}//if

	/*(2) 初始化地址结构*/
	bzero(&servaddr , sizeof(servaddr));
	servaddr.sin_family = AF_INET;
	servaddr.sin_addr.s_addr = htonl(INADDR_ANY);
	servaddr.sin_port = htons(PORT);

	/*(3) 绑定套接字和端口*/
	if(bind(listenfd , (struct sockaddr *)&servaddr , sizeof(servaddr)) < 0)
	{
		perror("bind error.\n");
		exit(1);
	}//if

	/*(4) 监听*/
	if(listen(listenfd , LISTENQ) < 0)
	{
		perror("listen error.\n");
		exit(1);
	}//if

	/*(5) 接受客户请求，并创建线程处理*/

	clilen = sizeof(cliaddr);
	if((connfd = accept(listenfd , (struct sockaddr *)&cliaddr , &clilen)) < 0)
	{
		perror("accept error.\n");
		exit(1);
	}//if

	printf("server: got connection from %s\n", inet_ntoa(cliaddr.sin_addr));

	/*创建子线程处理该客户链接接收消息*/
	if(pthread_create(&recv_tid , NULL , recv_message, &connfd) == -1)
	{
		perror("pthread create error.\n");
		exit(1);
	}//if

	/*处理服务器发送消息*/
	char msg[MAX_LINE];
	memset(msg , 0 , MAX_LINE);
	while(fgets(msg , MAX_LINE , stdin) != NULL)	
	{	
		if(strcmp(msg , "exit\n") == 0)
		{
			printf("byebye.\n");
			memset(msg , 0 , MAX_LINE);
			strcpy(msg , "byebye.");
			send(connfd , msg , strlen(msg) , 0);
			close(connfd);
			exit(0);
		}//if

		if(send(connfd , msg , strlen(msg) , 0) == -1)
		{
			perror("send error.\n");
			exit(1);
		}//if		
	}//while
}
```

## ```client.c```

```c
/*
* 客户端代码
*/
#include "config.h"

/*处理接收服务器消息函数*/
void *recv_message(void *fd)
{
	int sockfd = *(int *)fd;
	while(1)
	{
		char buf[MAX_LINE];
		memset(buf , 0 , MAX_LINE);
		int n;
		if((n = recv(sockfd , buf , MAX_LINE , 0)) == -1)
		{
			perror("recv error.\n");
			exit(1);
		}//if
		buf[n] = '\0';
		
		//若收到的是exit字符，则代表退出通信
		if(strcmp(buf , "byebye.") == 0)
		{
			printf("Server is closed.\n");
			close(sockfd);
			exit(0);
		}//if

		printf("\nServer: %s\n", buf);
	}//while
}


int main(int argc , char **argv)
{
	/*声明套接字和链接服务器地址*/
    int sockfd;
	pthread_t recv_tid , send_tid;
    struct sockaddr_in servaddr;

    /*判断是否为合法输入*/
    if(argc != 2)
    {
        perror("usage:tcpcli <IPaddress>");
        exit(1);
    }//if

    /*(1) 创建套接字*/
    if((sockfd = socket(AF_INET , SOCK_STREAM , 0)) == -1)
    {
        perror("socket error");
        exit(1);
    }//if

    /*(2) 设置链接服务器地址结构*/
    bzero(&servaddr , sizeof(servaddr));
    servaddr.sin_family = AF_INET;
    servaddr.sin_port = htons(PORT);
    if(inet_pton(AF_INET , argv[1] , &servaddr.sin_addr) < 0)
    {
        printf("inet_pton error for %s\n",argv[1]);
        exit(1);
    }//if

    /*(3) 发送链接服务器请求*/
    if( connect(sockfd , (struct sockaddr *)&servaddr , sizeof(servaddr)) < 0)
    {
        perror("connect error");
        exit(1);
    }//if	

	/*创建子线程处理该客户链接接收消息*/
	if(pthread_create(&recv_tid , NULL , recv_message, &sockfd) == -1)
	{
		perror("pthread create error.\n");
		exit(1);
	}//if	

	/*处理客户端发送消息*/
	char msg[MAX_LINE];
	memset(msg , 0 , MAX_LINE);
	while(fgets(msg , MAX_LINE , stdin) != NULL)	
	{
		if(strcmp(msg , "exit\n") == 0)
		{
			printf("byebye.\n");
			memset(msg , 0 , MAX_LINE);
			strcpy(msg , "byebye.");
			send(sockfd , msg , strlen(msg) , 0);
			close(sockfd);
			exit(0);
		}//if
		if(send(sockfd , msg , strlen(msg) , 0) == -1)
		{
			perror("send error.\n");
			exit(1);
		}//if
	
		
	}//while
}
```

## complied

```
$ gcc server.c -o server -pthread
$ gcc client.c -o client -pthread
```

## run

```
$ ./server &
$ ./client 127.0.0.1
```
