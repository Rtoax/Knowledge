* Copyright(C) ```NCURSES Programming HOWTO```

## 窗口机制

窗口（```Window```）机制是整个curses 系统的核心。通过前面的例子我们看到了基于```“标准窗口”（stdscr）```的一些操作函数。即使设计一个最简单的图形用户界面（ ```GUI```），都需要用到窗口。你可能需要将屏幕分成几个部分并分别处理，然而，将屏幕拆分成各个窗口，然后独立处理每个窗口是比较高效的方法。使用窗口的另外一个重要原因是：你应当始终在你的程序中追求一种更好的、更易于管理的设计方式。如果你要设计一个大型的、复杂的用户界面，事先设计好各个部分将会提高你的编程效率。

## 基本概念

一个窗口是通过调用```newwin()```函数建立的。但当你调用这个函数后屏幕上并不会有任何变化。因为这个函数的实际作用是给用来操作窗口的结构体分配内存，这个结构体包含了窗口的大小、起始坐标等信息。可见，在curses 里，窗口是一个假想的概念，用来独立处理屏幕上的各个部分。```newwin()```函数返回一个指向窗口结构的指针，像```wprintw()```等函数都需要以窗口指针作为参数。```delwin()```函数可以删除一个窗口，并释放用来存储窗口结构的内存和信息。

## 显示窗口

可惜的是，当我们创建了一个窗口之后却无法看见它，所以我们现在要做的就是让窗口显示出来。```box()```函数可以在已定义的窗口外围画上边框。现在让我们看看下面程序中的函数：

例：带边框的窗口：

```c
/*
Compile: gcc main.c -lncurses
*/
#include <ncurses.h>

WINDOW *create_newwin(int height, int width, int starty, int startx);
void destroy_win(WINDOW *local_win);

int main(int argc, char *argv[])
{
    WINDOW *my_win;
    int startx, starty, width, height;
    int ch;
    initscr(); /* 初始化并进入curses 模式*/
    cbreak(); /* 行缓冲禁止，传递所有控制信息*/
    keypad(stdscr, TRUE); /* 程序需要使用F1 功能键*/
    height = 3;
    width = 10;
    starty = (LINES-height)/ 2; /*计算窗口中心位置的行数*/
    startx = (COLS-width)/ 2; /*计算窗口中心位置的列数*/
    printw("Press F1 to exit");
    refresh();
    my_win = create_newwin(height, width, starty, startx);
    while((ch = getch()) != KEY_F(1))
    { 
        switch(ch)
        { 
            case KEY_LEFT:
                    destroy_win(my_win);
                    my_win = create_newwin(height, width, starty,--startx);
                    break;
            case KEY_RIGHT:
                    destroy_win(my_win);
                    my_win = create_newwin(height, width, starty,++startx);
                    break;
            case KEY_UP:
                    destroy_win(my_win);
                    my_win = create_newwin(height, width, --starty,startx);
                    break;
            case KEY_DOWN:
                    destroy_win(my_win);
                    my_win = create_newwin(height, width, ++starty,startx);
                    break;
        }
    }
    endwin(); /*结束curses 模式*/
    return 0;
}
    
WINDOW *create_newwin(int height, int width, int starty, int startx)
{
    WINDOW *local_win;
    local_win = newwin(height, width, starty, startx);
    box(local_win, 0 , 0);      /* 0, 0 是字符默认的行列起始位置*/
    wrefresh(local_win);        /*刷新窗口缓冲，显示box */
    return local_win;
}

void destroy_win(WINDOW *local_win)
{
    /* box(local_win, ' ', ' ');不会按照预期的那样清除窗口边框。
    而是在窗口的四个角落留下残余字符*/
    wborder(local_win, '1', '2', '3','4','5','6','7','8');
    /*参数注解9.3：
    * 1. win:当前操作的窗口
    * 2. ls:用于显示窗口左边界的字符
    * 3. rs:用于显示窗口右边界的字符
    * 4. ts:用于显示窗口上边界的字符
    * 5. bs:用于显示窗口下边界的字符
    * 6. tl:用于显示窗口左上角的字符
    * 7. tr:用于显示窗口右上角的字符
    * 8. bl:用于显示窗口左下角的字符
    * 9. br:用于显示窗口右下角的字符
    */
    wrefresh(local_win);
    delwin(local_win);
}
/**
结果：
                 ┌────────┐66666666666666666666666666666
                 │        │22222222222222222222222222222
                 └────────┘88888888888888888888888888888
                                              7444444448
                 53333333366666666666666      7444444448
                 53333333362222222222222      7444444448
                 53333333368888888888888      7444444448
                 5333333336   7444444448      7444444448
                 5333333336   7444444448      7444444448
                 5333333336   7444444448      7444444448
                 5333333336   7444444448      7444444448
                 5333333336   7444444448      7444444448
                 5333333336   7444444448      7444444448
                 5333333336   7444444448      7444444448
                 5333333336                   7444444448
                 5333333336                   7444444448
                 5333333336                   7444444448
                 555555555555555555555555555557444444448
                 111111111111111111111111111117444444448
                 777777777777777777777777777777444444448
*/
```

## 程序解析

别害怕，这的确是一个很大的程序，但它确实讲解了一些很重要的东西：它创建了一个窗口，并且可以使用方向键来移动它。当用户按下方向健的时候，它会删除现有的窗口并在下一个位置建立新窗口，这样就实现了窗口移动的效果。注意：移动窗口时不能超过窗口行列的限制。下面就让我们逐行的分析这个程序：

```creat_newwin()```函数使用```newwin()```函数创建了一个窗口，并且使用```box()```函数给窗口添加了边框。```destory_win()```函数首先使用空白字符填充窗口，从而起到清除屏幕的作用。之后调用```delwin()```函数回收分配给窗口的内存。随着用户按下方向键， ```startx``` 和```starty``` 的值就会不断改变并以新坐标为起点建立一个新窗口。
在```destory_win()```中，我们使用了```wborder``` 来替代```box```。这样做的原因已经写到程序注释里了（我知道你刚才忽略了，现在赶紧去看看！）。```wborder()```函数可以用字符来绘制窗口的边框。这些边框是由四条线和四个角组成的。为了理解得更明白一些，你可以试着这样调用```wborader()```函数：

```c
wborder(win, '|', '|', '-','-','+', '+', '+', '+');
```

他所绘制的窗口会是以下这样子：

```
+--------------+
|              |
|              |
|              |
|              |
|              |
|              |
+--------------+
```

## 更多的说明

从上面的例子中还可以看到，函数使用了```COLS``` 和```LINES``` 作为变量名。在```initscr()```函数初始化屏幕以后，这两个变量分别存储屏幕初始化后的行数和列数。这样做是为了方便标记窗口尺寸和计算出屏幕的中心位置坐标。```getch()```函数依然用来处理用户的键盘输入。同时，根据用户的输入做出程序中定义的操作。这种做法在交互式的图形界面应用程序中非常普遍。

## 其它的边框函数

上面这个例子所使用的方式是通过按下键盘上相应的按钮撤消一个窗口并建立一个新的窗口，但是这样的工作方式效率太低。现在让我们来写一些可以使窗口边框的使用更加有效率的程序。
下面这个程序使用```mvhline()```和```mvvline()```函数完成同样的效果。这两个函数非常简单，它们将在指定的位置绘制出指定大小的窗口。

```c
/*
Compile: gcc main.c -lncurses
*/
#include <ncurses.h>
//#define _DEBUG

typedef struct _win_border_struct{
    chtype ls, rs, ts, bs,
    tl, tr, bl, br;
}WIN_BORDER;

typedef struct _WIN_struct {
    int startx, starty;
    int height, width;
    WIN_BORDER border;
}WIN;

void init_win_params(WIN *p_win);
void print_win_params(WIN*p_win);
void create_box(WIN *win, int boolean);

int main(int argc, char *argv[])
{ 
    WIN win;
    int ch;
    initscr();              /* 初始化并进入curses 模式*/
    start_color();          /* 开启彩色显示功能*/
    cbreak();               /* 行缓冲禁止，传递所有控制信息*/
    keypad(stdscr, TRUE);   /* 程序需要使用F1 功能键*/
    noecho();
    init_pair(1, COLOR_CYAN, COLOR_BLACK);
    /* 以下代码初始化窗口的参数*/
    init_win_params(&win);
    print_win_params(&win);
    attron(COLOR_PAIR(1));
    printw("Press F1 to exit");
    refresh();
    attroff(COLOR_PAIR(1));
    create_box(&win, TRUE);
    while((ch = getch()) != KEY_F(1))
    {
        switch(ch)
        { 
            case KEY_LEFT:
                    create_box(&win, FALSE);
                    --win.startx;
                    create_box(&win, TRUE);
                    break;
            case KEY_RIGHT:
                    create_box(&win, FALSE);
                    ++win.startx;
                    create_box(&win, TRUE);
                    break;
            case KEY_UP:
                    create_box(&win, FALSE);
                    --win.starty;
                    create_box(&win, TRUE);
                    break;
            case KEY_DOWN:
                    create_box(&win, FALSE);
                    ++win.starty;
                    create_box(&win, TRUE);
                    break;
        }
    }
    endwin(); /* 结束curses 模式*/
    return 0;
}
void init_win_params(WIN *p_win)
{
    p_win->height = 3;
    p_win->width = 10;
    p_win->starty = (LINES-p_win->height)/2;
    p_win->startx = (COLS-p_win->width)/2;
    p_win->border.ls = '|';
    p_win->border.rs = '|';
    p_win->border.ts = '-';
    p_win->border.bs = '-';
    p_win->border.tl = '+';
    p_win->border.tr = '+';
    p_win->border.bl = '+';
    p_win->border.br= '+';
}
void print_win_params(WIN*p_win)
{
    #ifdef _DEBUG
    mvprintw(25, 0, "%d %d %d %d", p_win->startx, p_win->starty,
                                   p_win->width,  p_win->height);
    refresh();
    #endif
}
void create_box(WIN *p_win, int boolean)
{ 
    int i, j;
    int x, y, w, h;
    
    x = p_win->startx;
    y = p_win->starty;
    w = p_win->width;
    h = p_win->height;
    
    if(boolean == TRUE)
    {
        mvaddch(y, x, p_win->border.tl);
        mvaddch(y, x + w, p_win->border.tr);
        mvaddch(y + h, x, p_win->border.bl);
        mvaddch(y + h, x + w, p_win->border.br);
        mvhline(y, x + 1, p_win->border.ts, w-1);
        mvhline(y + h, x + 1, p_win->border.bs, w-1);
        mvvline(y + 1, x, p_win->border.ls, h-1);
        mvvline(y + 1, x + w, p_win->border.rs,h-1);
    }
    else
        for(j = y; j <= y + h; ++j)
            for(i = x; i <= x + w; ++i)
                mvaddch(j, i, ' ');
        
    refresh();
}
/**
结果：
    +---------+
    |         |
    |         |
    +---------+
*/
```
