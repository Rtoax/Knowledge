* Copyright(C) NCURSES Programming HOWTO

# 关于颜色系统

## 基础知识

如果生命中没有颜色将会单调无趣。curses 有一个非常不错的颜色处理机制。让我们通过以下程序来了解一下颜色系统：
例：一个简单的颜色使用例子

```c
/*
Compile: gcc main.c -lncurses
*/
#include <ncurses.h>
#include <stdlib.h>
#include <string.h>

void print_in_middle(WINDOW *win, int starty, int startx, int width, char *string);

int main(int argc, char *argv[])
{
    initscr();      /*启动curses 模式*/
    if(has_colors() == FALSE)
    { 
        endwin();
        printf("You terminal does not support color\n");
        exit(1);
    }
    start_color();  /*启动color 机制*/
    init_pair(1, COLOR_RED, COLOR_BLACK);
    
    attron(COLOR_PAIR(1));
    
    print_in_middle(stdscr,LINES / 2, 0, 0, "Viola !!! In color ...");
    
    attroff(COLOR_PAIR(1));
    
    getch();
    endwin();
}
void print_in_middle(WINDOW *win, int starty, int startx, int width, char *string)
{
    int length, x, y;
    float temp;
    
    if(win == NULL)
        win = stdscr;
    
    getyx(win, y, x);
    
    if(startx != 0)
        x = startx;
    if(starty != 0)
        y = starty;
    if(width == 0)
        width = 80;
    
    length = strlen(string);
    temp = (width-length)/2;
    x = startx + (int)temp;
    
    mvwprintw(win, y, x, "%s", string);
    
    refresh();
}
```

通过这个例子你可以看到，要启动彩色机制，必须先调用```start_color()```函数，之后就可以在终端屏幕上调用其它处理颜色的函数。如果要检测当前屏幕是否支持彩色显示，可以调用```has_colors()```函数，如果终端屏幕不支持彩色显示，那么该函数将返回```FLASE```。
在调用```start_color()```函数后，curses 就初始化了当前终端支持的所有颜色。然后就可通过像```COLOR_BLACK``` 这样的宏调用各种颜色。你现在如果要使用颜色，就必须成对定义前景色和背景色。所有的颜色都是这样使用的。这意味着你必须用```init_pair()```函数给每一对颜色编号并为其设置前景色和背景色。之后这个编号就作为调用颜色对的参数， 传递给```COLOR_PAIR()```函数，用来调用你已定义的颜色对。也许一开始你会觉得这样做很麻烦，但它会让你很轻松管理颜色对。```“dialog”```就使用了这种管理颜色的方法。你可以通过源代码了解这个用Shell 脚本编写的对话框。开发者应该在程序开始的部分定义并且初始化所需要使用的颜色对常量。这样做会让我们更容易的设置颜色属性。
以下的这些颜色已经被预定义在```ncurses.h``` 里，你可以将它们当作颜色参数传递给相应的颜色函数。

```
COLOR_BLACK     0   黑色
COLOR_RED       1   红色
COLOR_GREEN     2   绿色
COLOR_YELLOW    3   黄色
COLOR_BLUE      4   蓝色
COLOR_MAGENTA   5   洋红色
COLOR_CYAN      6   蓝绿色, 青色
COLOR_WHITE     7   白色
```

## 改变颜色定义

```init_color()```函数可以用来在初始化颜色的时候改变某个颜色的```RGB``` 值。比如你想减弱预定的红色设置。你就可以这样调用此函数：

```c
init_color(COLOR_RED, 700, 0, 0);
/* 参数1 : 颜色名称
/* 参数2, 3, 4 : 分别为R(red),G(green),B(blue)的数值（最小值：0 最大值：1000）*/
```

如果你的显示终端无法改变颜色设置，函数将返回```ERR```。```can_change_color()```函数可以用来监测你的终端是否支持这样的颜色改变。```RGB``` 参数的值是```0``` 到```1000``` 的整数。默认的```红色(COLOR_RED)```的定义是```R：1000，G：0，B：0``` 。

## 颜色定义内容

```color_content()```函数和```pair_content()```函数可以用来查看当前颜色的设置。
