## ```server.c```

```c
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>
#include <unistd.h>
#include <time.h>
#include <sys/socket.h>
#include <sys/epoll.h>
#include <sys/types.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <netdb.h>
#include <fcntl.h>


#ifndef CONNECT_SIZE
#define CONNECT_SIZE 256
#endif

#define PORT 7777
#define MAX_LINE 2048
#define LISTENQ 20

void setNonblocking(int sockfd)
{
	int opts;
    opts=fcntl(sockfd,F_GETFL);
    if(opts<0)
    {
        perror("fcntl(sock,GETFL)");
        return;
    }//if

    opts = opts|O_NONBLOCK;
    if(fcntl(sockfd,F_SETFL,opts)<0)
    {
 		perror("fcntl(sock,SETFL,opts)");
        return;
    }//if
}

int main(int argc , char **argv)
{
	int i, listenfd, connfd, sockfd, epfd, nfds;

	ssize_t n, ret;
		
	char buf[MAX_LINE];

	socklen_t clilen;

	struct sockaddr_in servaddr , cliaddr;

	/*声明epoll_event结构体变量，ev用于注册事件，数组用于回传要处理的事件*/
	struct epoll_event ev, events[20];

	/*(1) 得到监听描述符*/
	listenfd = socket(AF_INET , SOCK_STREAM , 0);
	setNonblocking(listenfd);

	/*生成用于处理accept的epoll专用文件描述符*/	
	epfd = epoll_create(CONNECT_SIZE);
	/*设置监听描述符*/
	ev.data.fd = listenfd;
	/*设置处理事件类型*/
	ev.events = EPOLLIN | EPOLLET;
	/*注册事件*/
	epoll_ctl(epfd, EPOLL_CTL_ADD, listenfd, &ev);		

	/*(2) 绑定套接字*/	
	bzero(&servaddr , sizeof(servaddr));
	servaddr.sin_family = AF_INET;
	servaddr.sin_addr.s_addr = htonl(INADDR_ANY);
	servaddr.sin_port = htons(PORT);

	bind(listenfd , (struct sockaddr *)&servaddr , sizeof(servaddr));

	/*(3) 监听*/
	listen(listenfd , LISTENQ);

	/*(4) 进入服务器接收请求死循环*/
	while(1)
	{
		/*等待事件发生*/
		nfds = epoll_wait(epfd , events , CONNECT_SIZE , -1);
		if(nfds <= 0)
			continue;
	
		printf("nfds = %d\n" , nfds);
		/*处理发生的事件*/
		for(i=0 ; i<nfds ; ++i)
		{
			/*检测到用户链接*/
			if(events[i].data.fd == listenfd)
			{	
				/*接收客户端的请求*/
				clilen = sizeof(cliaddr);

				if((connfd = accept(listenfd , (struct sockaddr *)&cliaddr , &clilen)) < 0)
				{
					perror("accept error.\n");
					exit(1);
				}//if		

				printf("accpet a new client: %s:%d\n", inet_ntoa(cliaddr.sin_addr) , cliaddr.sin_port);
			
				/*设置为非阻塞*/
				setNonblocking(connfd);
				ev.data.fd = connfd;
				ev.events = EPOLLIN | EPOLLET;
				epoll_ctl(epfd , EPOLL_CTL_ADD , connfd , &ev);
			}//if
			/*如果是已链接用户，并且收到数据，进行读入*/
			else if(events[i].events & EPOLLIN){

				if((sockfd = events[i].data.fd) < 0)
					continue;
				bzero(buf , MAX_LINE);
				printf("reading the socket~~~\n");
				if((n = read(sockfd , buf , MAX_LINE)) <= 0)
				{
					close(sockfd);
					events[i].data.fd = -1;
				}//if
				else{
					buf[n] = '\0';
					printf("clint[%d] send message: %s\n", i , buf);
				
					/*设置用于注册写操作文件描述符和事件*/
					ev.data.fd = sockfd;
					ev.events = EPOLLOUT| EPOLLET;	
					epoll_ctl(epfd , EPOLL_CTL_MOD , sockfd , &ev);			
				}//else						
			}//else
			else if(events[i].events & EPOLLOUT)
			{
				if((sockfd = events[i].data.fd) < 0)
				continue;
				if((ret = write(sockfd , buf , n)) != n)	
				{
					printf("error writing to the sockfd!\n");
					break;
				}//if
				/*设置用于读的文件描述符和事件*/
				ev.data.fd = sockfd;
				ev.events = EPOLLIN | EPOLLET;
				/*修改*/
				epoll_ctl(epfd , EPOLL_CTL_MOD , sockfd , &ev);
			}//else
		}//for
	}//while
	free(events);
	close(epfd);
	exit(0);
}
```

## ```client.c```

```c
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>
#include <unistd.h>
#include <time.h>
#include <sys/socket.h>
#include <sys/select.h>
#include <sys/types.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <netdb.h>
#include <fcntl.h>

#define PORT 7777
#define MAX_LINE 2048

int max(int a , int b)
{
	return a > b ? a : b;
}

/*readline函数实现*/
ssize_t readline(int fd, char *vptr, size_t maxlen)
{
	ssize_t	n, rc;
	char	c, *ptr;

	ptr = vptr;
	for (n = 1; n < maxlen; n++) {
		if ( (rc = read(fd, &c,1)) == 1) {
			*ptr++ = c;
			if (c == '\n')
				break;	/* newline is stored, like fgets() */
		} else if (rc == 0) {
			*ptr = 0;
			return(n - 1);	/* EOF, n - 1 bytes were read */
		} else
			return(-1);		/* error, errno set by read() */
	}

	*ptr = 0;	/* null terminate like fgets() */
	return(n);
}

/*普通客户端消息处理函数*/
void str_cli(int sockfd)
{
	/*发送和接收缓冲区*/
	char sendline[MAX_LINE] , recvline[MAX_LINE];
	while(fgets(sendline , MAX_LINE , stdin) != NULL)	
	{
		write(sockfd , sendline , strlen(sendline));

		bzero(recvline , MAX_LINE);
		if(readline(sockfd , recvline , MAX_LINE) == 0)
		{
			perror("server terminated prematurely");
			exit(1);
		}//if

		if(fputs(recvline , stdout) == EOF)
		{
			perror("fputs error");
			exit(1);
		}//if

		bzero(sendline , MAX_LINE);
	}//while
}

int main(int argc , char **argv)
{
	/*声明套接字和链接服务器地址*/
    int sockfd;
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
    if(connect(sockfd , (struct sockaddr *)&servaddr , sizeof(servaddr)) < 0)
    {
        perror("connect error");
        exit(1);
    }//if

	/*调用消息处理函数*/
	str_cli(sockfd);	
	exit(0);
}
```

## complied & run

```
$ gcc server.c -o server
$ gcc client.c -o client
$ ./server &
$ ./client 127.0.0.1
```
