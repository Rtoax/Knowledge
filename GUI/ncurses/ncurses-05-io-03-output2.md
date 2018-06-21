Copyright(C) NCURSES Programming HOWTO

## 输出修饰

我们已经通过一些例子看到了文字修饰（Attributes）的效果。给某些文字加上修饰会使文字更加醒目和美观。在某些程度上也会增加输出信息的可读性。下面这个程序将会把一个C语言的源程序文件的注释部分用```粗体（BOLD）```输出。

例：一个简单的文字修饰的例子：

```c
/*
Compile: gcc main.c -lncurses
*/
#include <ncurses.h>                    /* ncurses.h 已经包含了stdio.h */
#include <stdlib.h>
#include <string.h>

//只能读取一个单行的类似包含以下内容的文件：
//adsfadf/*aaaaaaaaa*/ adsfadf
//那么中间的aaaaa就会被加粗显示

int main(int argc, char *argv[])
{
    int ch, prev;
    FILE *fp;
    int goto_prev = FALSE, y, x;
    if(argc != 2)
    {
        printf("Usage: %s <a c file name>\n", argv[0]);
        exit(1);
    }
    fp = fopen(argv[1],"r");            /* 在这里检测文件是否成功打开*/
    if(fp == NULL)
    {
        perror("Cannotopen input file");
        exit(1);
    }
    initscr();                          /* 初始化并进入curses 模式*/
    prev = EOF;
    while((ch = fgetc(fp)) != EOF)
    {
        if(prev == '/' && ch == '*')    /* 当读到字符“/”和“*”的时候开启修饰*/
        {
            attron(A_BOLD);             /* 将“/”和“*”及以后输出的文字字体加粗*/
            goto_prev = TRUE;
        }
        if(goto_prev == TRUE)           /* 回到“/”和“*”之前开始输出*/
        {
            getyx(stdscr, y, x);
            move(y, x-1);
            printw("%c%c", '/', ch);    /* 打印实际内容的部分*/
            ch = 'a';                   /* 避免下次读取变量错误，这里赋一个任意值*/
            goto_prev = FALSE;          /* 让这段程序只运行一次*/
        }
        else 
            printw("%c", ch);
        
        refresh();                      /* 将缓冲区的内容刷新到屏幕上*/
        
        if(prev == '*' && ch == '/')
            attroff(A_BOLD);            /* 当读到字符“*”和“/”的时候关闭修饰*/
        
        prev = ch;
    }
    getch();
    endwin();                           /* 结束并退出curses 模式*/
    return 0;
}
```

我们把注意集中在上面这段代码的while 循环体中。这个循环体读取文件中的每个字符并寻找有```“/*”```（注释起始处标志）的地方。一旦找到，就会调用attron()函数开始启动文字加粗的修饰。当找到```“*/”```（注释结束处标志）的地方，就会调用attroff()函数停止为后续文字继续添加修饰。
这个程序介绍了两个十分有用的函数： ```getyx()```和```move()```。getyx()函数其实是一个定义在ncurses.h 中的宏，它会给出当前光标的位置，需要注意的是我们不能用指针作为参数，只能传递一对整型变量（前文提到过）。函数move()将光标移动到指定位置。（译者注：在这里再次强调——所有这些函数中使用行列坐标的时候是先行后列，即先写y 坐标，再写x坐标。）很多初学者因为数学上的使用习惯而使用了先列后行的方式。（```在这里一定要注意！```）
这个程序执行的任务非常简单，无需作过多的说明。这个程序对于分析C 语言源代码十分有帮助。你也可以试着将输出文字的颜色改变为其它颜色。也可以将这个程序扩展为分析其它语言程序的工具。

## 详细介绍

让我们来更多的了解一下输出修饰。```attron()```函数、```attroff()```函数和```attrset()```函数以及他们的姊妹函数（sister functions）比如```attr_get()```等等。可以用这些函数创造出生动有趣的显示效果。
```attron()```函数和```attroff()```函数分别用来开启（on）或关闭（off）输出修饰。以下这些修饰属性已经定义在头文件```curses.h``` 中,可以在函数中使用：

```
A_NORMAL        普通字符输出(不加亮显示)
A_STANDOUT      终端字符最亮
A_UNDERLINE     下划线
A_REVERSE       字符反白显示
A_BLINK         闪动显示
A_DIM           半亮显示
A_BOLD          加亮加粗
A_PROTECT       保护模式
A_INVIS         空白显示模式
A_ALTCHARSET    字符交替
A_CHARTEXT      字符掩盖
COLOR_PAIR(n)   前景、背景色设置
```

最后一个修饰是最吸引人的，它可以设置输出的字符的颜色以及背景的颜色。
我们可以给一段输出同时设定多种修饰。这样可以得到多种结合的效果。如果你想反白显示字符并同时让字符闪烁。只需要在两种修饰属性间加一个“|”字符就可以了：

```c
attron(A_REVERSE | A_BLINK);
```

## ```attron()```函数和```attrset()```函数之比较

现在我们该讨论讨论```attron()```函数和```attrset()```函数之间的区别了。attrset()为整个窗口设置一种修饰属性。而attron()函数只从被调用的地方开始设置。所以```attrset()会覆盖掉你先前为整个窗口设置的所有修饰属性```。就像在窗口的开始处开启修饰，在窗口结尾处关闭修饰属性一样。这两种方法为我们管理输出修饰属性提供了更简单、更富有弹性的方法。但是，如果你粗心的话，可能会让整个屏幕变得十分杂乱无章，使得函数之间的调用会难以管理。这种情况，尤其在某些用到菜单系统的程序中十分普遍。所以，事先做好设计，然后按照设计去实施效果会好得多。另外，你可以经常使用```standend()```函数关闭所有设置的修饰。这个函数和```attrset(A_NORMAL)```函数的作用是相同的。

## ```attr_get()```函数

```attr_get()```函数用来取得当前窗口的修饰属性设置以及背景、文字颜色。虽然这个函数不像上面的那些函数常用。但它却对检测屏幕区域的修饰属性设置很有用。当我们在屏幕输出一些混合的复杂修饰效果时，这个函数可以告诉我们每一个字符关联的修饰。注意：这个函数必须在调用了```attrset()```或者```attron()```之后才能使用。

## ```attr_``` 类函数

这些函数都有attr_前缀，比如：attr_set()、attr_on()等等，它们的作用和上面的函数一样，只不过要在调用时添加一定的参数。

## ```wattr_``` 类函数

这些函数的作用范围是某一个指定的窗口。而上面的函数只作用在默认的stdscr 上。

## ```chgat()``` 函数

```chgat()```函数被列在```curs_attr``` 的```man_page``` 的最末尾。事实上它是一个很有用的函数。它可以在不移动光标位置的情况下修改已输出的字符的修饰效果。它从光标当前位置处开始，以一个整型参数作为修改字符的个数。给这些字符设置某一种修饰属性。
当我们给整型参数赋值为1时，它代表一行修饰。如果你想从当前光标位置使整个一行的输出修饰变为反白显示时，可以这样使用：

```c
chgat(1, A_REVERSE, 0, NULL);
```

这个函数经常被用来修改已输出的字符的修饰。当然，你也可以根据自己的需要选择要修改的起始点和终止点。

这一类的函数还包括```wchgat()```, ```mvchgat()```。它们的使用方法和```chgat()```差不多，只不过```wchgat()```要指定一个窗口，而mvchgat()将光标先移动到指定位置，然后才执行剩下的修饰部分。同样的，chgat()是一个宏，只不过用stdscr 替代了指定的窗口（大部分不带w 前缀的函数都是以stdscr 作为默认窗口的宏）。

例：```mvchgat()```用法示例：

```c
/*
Compile: gcc main.c -lncurses
*/
#include <ncurses.h>
int main(int argc, char *argv[])
{
    initscr();          /* 进入curses 模式*/
    start_color();      /* 开启颜色管理功能*/
    init_pair(1, COLOR_CYAN, COLOR_BLACK);
    printw("A Big string which i didn't care to type fully ");
    mvchgat(0, 0, 1, A_BLINK, 1, NULL);
    mvchgat(0, 5, 10, A_BLINK, 1, NULL);
    mvchgat(0, 35, 10, A_BLINK, 1, NULL);
    /*
    *第一、二个参数表明了函数开始的位置。
    *第三个参数是被改变修饰的字符的数目，1
    表示一整行。
    *第四个参数是被改变的修饰名。
    *第五个参数是颜色索引。颜色索引已经在init_pair()中被初试化了。
    *如果用０表示不使用颜色。
    *最后一个总是NULL，没什么特殊含义。
    */
    refresh();
    getch();
    endwin();       /* 结束curses 模式*/
    return 0;
}
```
