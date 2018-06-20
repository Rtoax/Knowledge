Copyright(C) NCURSES Programming HOWTO

## 输入函数

如果你的程序只有输出而没有输入，那是非常单调的。让我们来看看处理用户输入的函数。输入函数也被分为三种：

* getch ()系列：读取一个字符的一类函数。
* scanw()系列：按照格式化读取输入的一类函数。
* getstr()系列：读取字符串的一类函数。

## getch()系列函数

这个函数用于从键盘读入一个字符。但是在使用它的时候需要考虑一些微妙的情况：例如你没有事先调用cbreak()函数的话，curses 不会连续读取你输入的字符，除非在输入这些字
符之前遇到了换行符或者文末符（EOF）。为了避免这种情况的出现，在需要即时显示输入字符的程序中，必须先调用cbreak()函数。另外一个比较广泛的做法是使用noecho()函数。
这个函数被调用时，用户输入的字符不会立即显示在屏幕上。cbeak()和noecho()是两个用
来管理键盘输入的典型函数。键盘管理的具体内容将在键盘管理一章中介绍。

## scanw()系列函数

这些函数用法大体上和scanf()函数相似。只不过加入了能够在屏幕的任意位置读入格式化
字符串的功能。

## scanw()函数和mvscanw()函数

scanw()函数的用法和sscanf()函数的用法基本相同。实际上，在调用scanw()函数时，是
调用了wgetstr()函数，并将wgetstr()函数处理的数据结果传送到一个scanw()调用中。
（wgetstr()函数将在本章后半部分介绍，写到这里是为了结构整齐。）

## wscanw()函数和mvwscanw()函数

这两个函数的用法和以上两个函数相似。区别在于它们从一个窗口中读取数据。所以，它们
需要指定窗口的指针作为第一个参数。

## vwscanw()函数（vwscanw()）

这个函数和vprintf()相似。它用于输入变量表中所对应的变量。

## getstr()系列函数

这些函数用于从终端读取字符串。本质上，这个函数执行的任务和连续用getch()函数读取
字符的功能相同：在遇到回车符、新行符和文末符时将用户指针指向该字符串。

## 例子

例：一个简单的使用scanw()函数的例子。

```c
/*
Compile: gcc main.c -lncurses
*/
#include <ncurses.h>                    /* ncurses.h 已经包含了stdio.h */
#include <string.h>
int main()
{
    char mesg[]="Enter a string: ";     /* 将要被打印的字符串信息*/
    char str[80];
    int row,col;                        /* 存储行号和列号的变量，用于指定光标位置*/
    initscr();                          /* 进入curses 模式*/
    getmaxyx(stdscr,row,col);           /* 取得stdscr 的行数和列数*/
    mvprintw(row/2,(col-strlen(mesg))/2,"%s",mesg);
                                        /* 在屏幕的正中打印字符串mesg */
    getstr(str);                        /* 将指针str 指向读取的字符串*/
    mvprintw(LINES-2, 0, "You Entered: %s", str);
    getch();
    endwin();
    return 0;
}
```
