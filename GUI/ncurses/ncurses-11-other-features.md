* Copyright(C) NCURSES Programming HOWTO

# 其它特色

现在你所掌握的函数可以写出一个非常不错的curses 程序了。这里还有一些很有趣的函数可以为你的程序增色。

## ```curs_set()```函数

这个函数用来设制光标是否可见。它的参数可以是：```0```（不可见），```1```（可见），```2```（完全可见）

## 临时离开Curses 模式

有时候你也许会想暂时离开curses 模式，回到行缓冲模式下做些其它的事。在这种情况下，你首先要调用```def_prog_mode()```函数存储```tty``` 模式下的信息，然后使用```end_win()```函数退出```curses``` 模式，让你回到最初的```tty``` 模式。如果你结束了```tty``` 模式下的工作，想要返回curses模式，就需要调用```reset_prog_mode()```函数，它会将```def_prog_mode()```函数保存的信息重新读入到虚拟的屏幕上。之后必须通过```refresh()```函数刷新屏幕，才可以返回到原先保存的curses 模式。让我们通过一个小例子了解一下这些函数的用法：

例：临时离开模式

```c
/*
Compile: gcc main.c -lncurses
*/
#include <ncurses.h>

int main()
{
    initscr();                      /* 启动CURSES 模式*/
    printw("Hello World !!!\n");    /* 打印Hello World!!! */
    refresh();                      /* 让虚拟显示器的内容显示到屏幕上*/
    def_prog_mode();                /* 存储当前tty 模式*/
    endwin();                       /* 临时退出CURSES 模式*/
    system("sh");                   /* 返回普通的行缓冲模式*/
    reset_prog_mode();              /* 返回到def_prog_mode()存储的tty 模式*/
    refresh();                      /* 使用refresh() 函数恢复屏幕的内容*/
    printw("Another String\n");     /* 完全返回CURSES 模式*/
    refresh();                      /* 别忘了刷新屏幕*/
    endwin();                       /* 退出CURSES 模式*/
    return 0;
}
```

## ```ACS_```常量

如果你曾经在```DOS``` 下编写过程序，就应该知道```扩展字符集```。但是这些字符集中的字符只能在少数的终端上显示。例如NCURSES 的```box()```函数（译者注：这个函数用来绘制一个矩形框）就使用了这些扩展字符。所有这些字符都是以```ACS_```作为前缀的常量，所谓```ACS```，就是```Alternative Character Set（可选字符集）```的缩写。你可以注意到在以前的程序中多多少少都用到了这些有意思的字符。下面这个程序分别介绍这些字符：

例：```ACS``` 常量介绍例子

```c
/*
Compile: gcc main.c -lncurses
*/
#include <ncurses.h>
int main()
{
    initscr();
    printw("Upper left corner ");           addch(ACS_ULCORNER);    printw("\n");
    printw("Lower left corner ");           addch(ACS_LLCORNER);    printw("\n");
    printw("Lower right corner ");          addch(ACS_LRCORNER);    printw("\n");
    printw("Tee pointing right ");          addch(ACS_LTEE);        printw("\n");
    printw("Tee pointing left ");           addch(ACS_RTEE);        printw("\n");
    printw("Tee pointing up ");             addch(ACS_BTEE);        printw("\n");
    printw("Tee pointing down ");           addch(ACS_TTEE);        printw("\n");
    printw("Horizontal line ");             addch(ACS_HLINE);       printw("\n");
    printw("Vertical line ");               addch(ACS_VLINE);       printw("\n");
    printw("Large Plus or cross over ");    addch(ACS_PLUS);        printw("\n");
    printw("Scan Line 1 ");                 addch(ACS_S1);          printw("\n");
    printw("Scan Line 3 ");                 addch(ACS_S3);          printw("\n");
    printw("Scan Line 7 ");                 addch(ACS_S7);          printw("\n");
    printw("Scan Line 9 ");                 addch(ACS_S9);          printw("\n");
    printw("Diamond ");                     addch(ACS_DIAMOND);     printw("\n");
    printw("Checker board (stipple) ");     addch(ACS_CKBOARD);     printw("\n");
    printw("Degree Symbol ");               addch(ACS_DEGREE);      printw("\n");
    printw("Plus/Minus Symbol ");           addch(ACS_PLMINUS);     printw("\n");
    printw("Bullet ");                      addch(ACS_BULLET);      printw("\n");
    printw("Arrow Pointing Left ");         addch(ACS_LARROW);      printw("\n");
    printw("Arrow Pointing Right ");        addch(ACS_RARROW);      printw("\n");
    printw("Arrow Pointing Down ");         addch(ACS_DARROW);      printw("\n");
    printw("Arrow Pointing Up ");           addch(ACS_UARROW);      printw("\n");
    printw("Board of squares ");            addch(ACS_BOARD);       printw("\n");
    printw("LanternSymbol ");               addch(ACS_LANTERN);     printw("\n");
    printw("Solid Square Block ");          addch(ACS_BLOCK);       printw("\n");
    printw("Less/Equal sign ");             addch(ACS_LEQUAL);      printw("\n");
    printw("Greater/Equalsign ");           addch(ACS_GEQUAL);      printw("\n");
    printw("Pi ");                          addch(ACS_PI);          printw("\n");
    printw("Not equal ");                   addch(ACS_NEQUAL);      printw("\n");
    printw("UK pound sign ");               addch(ACS_STERLING);    printw("\n");
    refresh();
    getch();
    endwin();
    return 0;
}
```

## 扩展库

curses 函数除了主函数库外，还有一些具有很多新功能和特性的字符文本模式的扩展库。以下章节将分别介绍与curses 一起发布的三个扩展库（```panel```（面板扩展库）、```menu```（菜单扩展库）、```form```（表单扩展库））。
