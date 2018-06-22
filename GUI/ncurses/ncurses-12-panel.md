* Copyright(C) ```NCURSES Programming HOWTO```

# 面板库

在精通curses 库后，你可能会想尝试着做一些更大的项目。为了让界面看起来更专业，你可能会创建许多重叠的窗口，但不幸的是，你很快会发现它们变得难以管理，多次的更新窗口使开发变得异常困难。如果你没有按照适当的顺序刷新那些窗口的话，它们就会给你带来很多麻烦。

不过别失望，面板库（```Panel Library```）提供了一个很好的解决方案。用ncureses 的开发者的话来说就是：

如果你的界面设计需要使窗口在运行时置底或者置顶，虽然会为此付出很大代价，但是想要显示正确的结果仍然很困难。这时候Panels 库就可以派上用场了。
如果你要处理重叠的窗口，panels 库就派上用场了。它使程序员避免使用大量的```wnoutrefresh()```和```doupdate()```函数来处理这个问题，并且减轻了由底向上正确处理这些信息的负担。这个库维持着窗口重叠关系以及窗口顺序，并在适当的时候更新它们。

那么还等什么呢？让我们开始吧！

## 基础知识

面板对象实际上是一个窗口，和其它窗口一样被隐含地处理为容器的一部分。这个容器实际上是一个```栈```，栈顶的面板是完全可见的。而其它面板在栈中所处的位置，决定了它们是否可见。其```基本思想```是：```创建一个栈来保存那些重叠的面板，然后使用面板库来正确的显示它们```。
例如调用一个类似于```refresh（）```函数就按正确的顺序来显示这些面板。面板库提供了一系列隐藏、显示、移动、改变大小等面板操作的函数，使操作重叠的窗口变得更加简单。
通常，一个面板程序的设计流程如下：

* 使用```newwin()```函数创建一个窗口，它将添加到面板里。
* 创建面板（利用所创建的窗口）并将面板依据用户指定的可见顺序压进栈。调用```new_panel()```函数即可创建该面板。
* 调用```update_panels()```函数就可将面板按正确的顺序写入虚拟屏幕，调用```doupdate()```函数就能让面板显示出来。
* ```show_panel()```, ```hide_panel()```, ```move_panel()```等函数分别用来对面板进行显示、隐藏、移动等操作时，可以使用```panel_hidden()```和```panel_window()```这两个辅助函数。你也可以使用用户指针来存储面板的数据，```set_panel_userptr()``` 和```panel_userptr()```函数分别用来设置和取得一个面板的用户指针。
* 当一个面板使用完毕后，用```del_panel()```函数就可删除指定的面板。

现在让我们通过一些程序来加深对这些概念的理解。下面将要看到的程序创建了3 个重叠的面板并把它们按次序显示在屏幕上。

## 编译包含面板库的程序

要使用面板库里的函数，你首先要把```panel.h``` 这个头文件包含到你的代码中，同时编译并连接与面板库相关的程序必须添加```-lpanel```和```–lncurses``` 两个参数。

```c
#include <panel.h>
```

编译和连接: ```gcc <program file> -lpanel –lncurses```

## 例．一个有关面板库的基础例子

```c
/*
Compile: gcc main.c -lncurses -lpanel
*/
#include <ncurses.h>
#include <panel.h>

int main()
{
    WINDOW *my_wins[3];
    PANEL *my_panels[3];
    int lines = 10, cols = 40, y = 2, x = 4, i;
    
    initscr();
    cbreak();
    noecho();
    
    /* 为每个面板创建窗口*/
    my_wins[0] = newwin(lines, cols, y, x);
    my_wins[1] = newwin(lines, cols, y + 1, x + 5);
    my_wins[2] = newwin(lines, cols, y + 2, x + 10);
    
    /* 为窗口添加创建边框以便你能看到面板的效果*/
    for(i = 0; i < 3; ++i)
        box(my_wins[i], 0, 0);
    /* 按自底向上的顺序，为每一个面板关联一个窗口*/
    my_panels[0] = new_panel(my_wins[0]);
    /* 把面板0 压进栈, 叠放顺序: stdscr0*/
    my_panels[1] = new_panel(my_wins[1]);
    /* 把面板1 压进栈, 叠放顺序: stdscr01*/
    my_panels[2] = new_panel(my_wins[2]);
    /* 把面板2 压进栈, 叠放顺序: stdscr012*/
    /* 更新栈的顺序。把面板2 置于栈顶*/
    update_panels();
    /* 在屏幕上显示*/
    doupdate();
    getch();
    endwin();
}
/**
结果：
    ┌──────────────────────────────────────┐
    │    ┌──────────────────────────────────────┐
    │    │    ┌──────────────────────────────────────┐
    │    │    │                                      │
    │    │    │                                      │
    │    │    │                                      │
    │    │    │                                      │
    │    │    │                                      │
    │    │    │                                      │
    └────│    │                                      │
         └────│                                      │
              └──────────────────────────────────────┘
*/
```

如你所见，这个程序就是按照16.1 所介绍的流程进行的。用```newwin()```函数来创建窗口，然后通过```new_panel()```函数把窗口添加到panels 栈里面，当那些面板一个一个压进栈的时候，栈就随之更新了。最后调用```update_panels()```函数和```doupdate()```函数就可以让它们在屏幕上显示出来。

## 面板浏览

下面给出一个较复杂的例子。它创建了3 个窗口，通过```<TAB>``` 键可以使它们循环置顶显示。让我们来看一下代码：

## 例 一个面板窗口浏览的例子

```c
/*
Compile: gcc main.c -lncurses -lpanel
*/
#include <ncurses.h>
#include <panel.h>
#include <string.h>

#define NLINES 10
#define NCOLS 40

void init_wins(WINDOW **wins, int n);
void win_show(WINDOW *win, char *label, int label_color);
void print_in_middle(WINDOW *win, int starty, int startx, 
                     int width, char *string, chtype color);
int main()
{ 
    WINDOW *my_wins[3];
    PANEL *my_panels[3];
    PANEL *top;
    int ch;
    
    /*初始化curses */
    initscr();
    start_color();
    cbreak();
    noecho();
    keypad(stdscr, TRUE);
    
    /* 初始化所有的颜色*/
    init_pair(1, COLOR_RED, COLOR_WHITE);
    init_pair(2, COLOR_GREEN, COLOR_BLACK);
    init_pair(3, COLOR_BLUE, COLOR_BLACK);
    init_pair(4, COLOR_CYAN, COLOR_BLACK);
    init_wins(my_wins, 3);
    
    /* 按自底向上的顺序，把每个窗口添加进一个面板*/
    my_panels[0] = new_panel(my_wins[0]);
    /* 把面板0 压入栈， 顺序: stdscr0*/
    my_panels[1] = new_panel(my_wins[1]);
    /* 把面板1 压入栈，顺序: stdscr01*/
    my_panels[2] = new_panel(my_wins[2]);
    /* 把面板2 压入栈，顺序: stdscr012*/
    /* 为下一个面板建立用户指针*/
    set_panel_userptr(my_panels[0],my_panels[1]);
    set_panel_userptr(my_panels[1],my_panels[2]);
    set_panel_userptr(my_panels[2],my_panels[0]);
    /* 更新面板栈的顺序。把面板2 置于栈顶*/
    update_panels();
    /* 在屏幕上显示*/
    attron(COLOR_PAIR(4));
    mvprintw(LINES-2, 0, "Use tab to browse through the windows (F1 to Exit)");
    attroff(COLOR_PAIR(4));
    doupdate();
    top = my_panels[2];
    while((ch = getch()) != KEY_F(1))
    { 
        switch(ch)
        { 
            case 9:
                top = (PANEL *)panel_userptr(top);
                top_panel(top);
                break;
        }
        update_panels();
        doupdate();
    }
    endwin();
    return 0;
}
/* 显示所有的窗口*/
void init_wins(WINDOW **wins, int n)
{ 
    int x, y, i;
    char label[80];
    
    y = 2;
    x = 10;
    
    for(i = 0; i < n; ++i)
    { 
        wins[i] = newwin(NLINES, NCOLS, y, x);
        sprintf(label, "Window Number %d", i + 1);
        win_show(wins[i], label, i + 1);
        y += 3;
        x += 7;
    }
}
/* 用一个边框和控件显示所有的窗口*/
void win_show(WINDOW *win, char *label, int label_color)
{ 
    int startx, starty, height, width;
    getbegyx(win, starty, startx);
    getmaxyx(win, height, width);
    box(win, 0, 0);
    mvwaddch(win, 2, 0, ACS_LTEE);
    mvwhline(win, 2, 1, ACS_HLINE, width-2);
    mvwaddch(win, 2, width-1,ACS_RTEE);
    print_in_middle(win, 1, 0, width, label, COLOR_PAIR(label_color));
}
void print_in_middle(WINDOW *win, int starty, int startx, 
                                  int width, char *string, chtype color)
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
    temp = (width - length)/2;
    x = startx + (int)temp;
    wattron(win, color);
    mvwprintw(win, y, x, "%s", string);
    wattroff(win, color);
    refresh();
}
/**
结果：
          ┌──────────────────────────────────────┐
          │           Window Number 1            │
          ├──────────────────────────────────────┤
          │      ┌──────────────────────────────────────┐
          │      │           Window Number 2            │
          │      ├──────────────────────────────────────┤
          │      │      ┌──────────────────────────────────────┐
          │      │      │           Window Number 3            │
          │      │      ├──────────────────────────────────────┤
          └──────│      │                                      │
                 │      │                                      │
                 │      │                                      │
                 └──────│                                      │
                        │                                      │
                        │                                      │
                        └──────────────────────────────────────┘
Use tab to browse through the windows (F1 to Exit)

*/
```

## 使用用户指针

在上面例子中，使用用户指针在循环里查找下一个要显示的面板。我们可以通过指定一个用户指针给面板添加自定义信息，这个指针可以指向你想要存储的任何信息。在这个例子中，我们用指针存储了循环中下一个要显示的面板。其中，用户指针可以用```set_panel_userptr()```函数设定。要想访问某个面板的用户指针，就必须以该面板作为```panel_userprt()```函数的参数，函数就会返回该面板的用户指针。结束面板的查找后， ```top_panel()```函数就会将其置于面板栈的顶层。要想将任意一个面板置于面板栈的顶层，只需将该面板作为```top_panel()```函数的参数。

## 移动面板和改变面板的大小

```move_panel()```函数可将面板移动到屏幕上指定的位置，而不是改变面板在栈中的位置。确保在移动面板窗口时使用```move_panel()```函数，而不是```mvwin()```函数。改变面板大小有点儿复杂，因为没有一个函数可以直接改变面板所关联窗口的大小。一个可替代的解决方案是按照所需的大小创建一个新窗口，再调用```replace_panel()```函数来替换相应面板上的关联窗口。别忘了替换后删除原窗口，使用```panel_window()``` 函数可以找到与该面板关联的窗口。
下面这个程序就体现了这种思想。你可以像先前那样，用```<Tab>```键循环查看窗口。如果要改变当前面板大小或移动当前面板的位置，就要分别按下```‘r’```或```‘m’```键，然后使用方向键来调节，最后以```<Enter>```键确定大小或者位置.。这个例子利用用户数据保存程序运行的必要数据。

## 例、一个移动和改变面板大小的例子

```c
/*
Compile: gcc main.c -lncurses -lpanel
*/
#include <ncurses.h>
#include <panel.h>
#include <string.h>
#include <stdlib.h>

typedef struct _PANEL_DATA
{
    int x, y, w, h;
    char label[80];
    int label_color;
    PANEL *next;
}PANEL_DATA;

#define NLINES 10
#define NCOLS 40

void init_wins(WINDOW **wins, int n);
void win_show(WINDOW *win, char *label, int label_color);
void print_in_middle(WINDOW *win, int starty, int startx, int width, char *string, chtype color);
void set_user_ptrs(PANEL **panels, int n);

int main()
{ 
    WINDOW *my_wins[3];
    PANEL *my_panels[3];
    PANEL_DATA *top;
    PANEL *stack_top;
    WINDOW *temp_win, *old_win;
    int ch;
    int newx, newy, neww, newh;
    int size = FALSE, move = FALSE;
    /* 初始化curses */
    initscr();
    start_color();
    cbreak();
    noecho();
    keypad(stdscr, TRUE);
    /* 初始化所有的颜色*/
    init_pair(1, COLOR_RED, COLOR_BLACK);
    init_pair(2, COLOR_GREEN, COLOR_BLACK);
    init_pair(3, COLOR_BLUE, COLOR_BLACK);
    init_pair(4, COLOR_CYAN, COLOR_BLACK);
    init_wins(my_wins, 3);
    /* 更新面板栈的顺序。把面板2 置于栈顶*/
    my_panels[0] = new_panel(my_wins[0]); /* 把面板0 压入栈，顺序: stdscr0*/
    my_panels[1] = new_panel(my_wins[1]); /* 把面板1 压入栈。顺序: stdscr01*/
    my_panels[2] = new_panel(my_wins[2]); /* 把面板2 压入栈,顺序: stdscr012*/
    set_user_ptrs(my_panels,3);
    /* 更新面板栈的顺序。把面板2 置于栈顶*/
    update_panels();
    /* 在屏幕上显示出来*/
    attron(COLOR_PAIR(4));
    mvprintw(LINES-3,0, "Use 'm' for moving, 'r' for resizing");
    mvprintw(LINES-2,0, "Use tab to browse through the windows (F1 to Exit)");
    attroff(COLOR_PAIR(4));
    doupdate();
    stack_top = my_panels[2];
    top = (PANEL_DATA *)panel_userptr(stack_top);
    newx = top->x;
    newy = top->y;
    neww = top->w;
    newh = top->h;
    while((ch = getch()) != KEY_F(1))
    { 
        switch(ch)
        { 
            case 9: /* Tab 对应编号*/
                top = (PANEL_DATA *)panel_userptr(stack_top);
                top_panel(top->next);
                stack_top = top->next;
                top = (PANEL_DATA *)panel_userptr(stack_top);
                newx = top->x;
                newy = top->y;
                neww = top->w;
                newh = top->h;
                break;
            case 'r': /* 改变面板大小*/
                size = TRUE;
                attron(COLOR_PAIR(4));
                mvprintw(LINES-4,0, "Entered Resizing :Use Arrow Keys to"\
                                    "resizeand press <ENTER> to end resizing");
                refresh();
                attroff(COLOR_PAIR(4));
                break;
            case 'm':/* 移动面板*/
                attron(COLOR_PAIR(4));
                mvprintw(LINES-4,0, "Entered Moving: Use Arrow Keys to"\
                                    "Move and press <ENTER> to end moving");
                refresh();
                attroff(COLOR_PAIR(4));
                move = TRUE;
                break;
            case KEY_LEFT:
                if(size == TRUE)
                { 
                    --newx;
                    ++neww;
                }
                if(move == TRUE)
                    --newx;
                break;
            case KEY_RIGHT:
                if(size == TRUE)
                { 
                    ++newx;
                    --neww;
                }
                if(move == TRUE)
                    ++newx;
                break;
            case KEY_UP:
                if(size == TRUE)
                { 
                    --newy;
                    ++newh;
                }
                if(move == TRUE) 
                    --newy;
                break;
            case KEY_DOWN:
                if(size == TRUE)
                { 
                    ++newy;
                    --newh;
                }
                if(move == TRUE)
                    ++newy;
                break;
            case 10: /* Enter 对应编号*/
                move(LINES-4,0);
                clrtoeol();
                refresh();
                if(size == TRUE)
                { 
                    old_win = panel_window(stack_top);
                    temp_win = newwin(newh, neww, newy, newx);
                    replace_panel(stack_top,temp_win);
                    win_show(temp_win, top->label, top->label_color);
                    delwin(old_win);
                    size = FALSE;
                }
                if(move == TRUE)
                { 
                    move_panel(stack_top,newy, newx);
                    move = FALSE;
                }
                break;
        }
        attron(COLOR_PAIR(4));
        mvprintw(LINES-3,0, "Use 'm' for moving, 'r' for resizing");
        mvprintw(LINES-2,0, "Use tab to browse through the windows (F1 to Exit)");
        attroff(COLOR_PAIR(4));
        refresh();
        update_panels();
        doupdate();
    }
    endwin();
    return 0;
}
/* 显示所有的窗口*/
void init_wins(WINDOW **wins, int n)
{ 
    int x, y, i;
    char label[80];
    y = 2;
    x = 10;
    for(i = 0; i < n; ++i)
    { 
        wins[i] = newwin(NLINES, NCOLS, y, x);
        sprintf(label, "Window Number %d", i + 1);
        win_show(wins[i], label, i + 1);
        y += 3;
        x += 7;
    }
}
/* 把每个面板设置为PANEL_DATA 结构*/
void set_user_ptrs(PANEL **panels, int n)
{ 
    PANEL_DATA *ptrs;
    WINDOW *win;
    int x, y, w, h, i;
    char temp[80];
    ptrs = (PANEL_DATA *)calloc(n, sizeof(PANEL_DATA));
    for(i = 0;i < n; ++i)
    { 
        win = panel_window(panels[i]);
        getbegyx(win, y, x);
        getmaxyx(win, h, w);
        ptrs[i].x = x;
        ptrs[i].y = y;
        ptrs[i].w = w;
        ptrs[i].h = h;
        sprintf(temp, "Window Number %d", i + 1);
        strcpy(ptrs[i].label,temp);
        ptrs[i].label_color = i + 1;
        if(i + 1 == n)
            ptrs[i].next = panels[0];
        else
            ptrs[i].next = panels[i + 1];
        set_panel_userptr(panels[i],&ptrs[i]);
    }
}
/* 用一个边框和标题栏来显示窗口*/
void win_show(WINDOW *win, char *label, int label_color)
{
    int startx, starty, height, width;
    getbegyx(win, starty, startx);
    getmaxyx(win, height, width);
    box(win, 0, 0);
    mvwaddch(win, 2, 0, ACS_LTEE);
    mvwhline(win, 2, 1, ACS_HLINE, width-2);
    mvwaddch(win, 2, width-1,ACS_RTEE);
    print_in_middle(win, 1, 0, width, label, COLOR_PAIR(label_color));
}
void print_in_middle(WINDOW *win, int starty, int startx, int width, char *string, chtype color)
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
    wattron(win, color);
    mvwprintw(win, y, x, "%s", string);
    wattroff(win, color);
    refresh();
}
```

## 结果测试

```
原始：
          ┌──────────────────────────────────────┐
          │           Window Number 1            │
          ├──────────────────────────────────────┤
          │      ┌──────────────────────────────────────┐
          │      │           Window Number 2            │
          │      ├──────────────────────────────────────┤
          │      │      ┌──────────────────────────────────────┐
          │      │      │           Window Number 3            │
          │      │      ├──────────────────────────────────────┤
          └──────│      │                                      │
                 │      │                                      │
                 │      │                                      │
                 └──────│                                      │
                        │                                      │
                        │                                      │
                        └──────────────────────────────────────┘
Use 'm' for moving, 'r' for resizing
Use tab to browse through the windows (F1 to Exit)

Tab键功能：
          ┌──────────────────────────────────────┐
          │           Window Number 1            │
          ├──────────────────────────────────────┤
          │                                      │──────┐
          │                                      │      │
          │                                      │──────┤
          │                                      │─────────────┐
          │                                      │3            │
          │                                      │─────────────┤
          └──────────────────────────────────────┘             │
                 │      │                                      │
                 │      │                                      │
                 └──────│                                      │
                        │                                      │
                        │                                      │
                        └──────────────────────────────────────┘
                        
调整大小：
          ┌──────────────────────────────────────┐──────┐
          │           Window Number 1            │      │
          ├──────────────────────────────────────┤──────┤
          │                                      │─────────────┐
          │                                      │3            │
          │                                      │─────────────┤
          └──────────────────────────────────────┘             │
                 │      │                                      │
                 │      │                                      │
                 └──────│                                      │
                        │                                      │
                        │                                      │
                        └──────────────────────────────────────┘

调整位置：
          ┌──────────────────────────────────────┐
          │           Window Number 1            │
          ├──────────────────────────────────────┤
          │   ┌──────────────────────────────────────┐─────────┐
          │   │           Window Number 2            │         │
          │   ├──────────────────────────────────────┤─────────┤
          └───│                                      │         │
              │                                      │         │
              │                                      │         │
              │                                      │         │
              │                                      │         │
              │                                      │         │
              └──────────────────────────────────────┘─────────┘
```

让我们把注意力集中在主while 循环体上。一旦该循环发现某个键被按下，程序就会执行该键相应的处理。
当按下```‘r’```键时，程序就会执行“更改大小”操作，同时你就可以通过方向键更改面板的大小，然后按```<Enter>```键确定大小。在“更改大小”模式下，程序不会显示窗口是怎样更改大小的。请读者思考一下如何用“点”来打印更改大小后窗口的边框。
当按下```‘m’```键时，程序就会执行“移动面板”操作。这个操作比“更改大小”简单一点。按下方向键的同时，面板的位置随之改变，当按下```<Enter>```键时，程序就会调用move_panel()函数把面板固定到当前光标的位置。
在这个程序中， ```PANEL_DATA``` 就是所谓的用户数据，它在查找面板的相关信息时扮演重要角色，正如说明中所说的那样，```PANEL_DATA ```保存了面板的尺寸，标题，标题颜色以及指向下一个面板的指针。

## 隐藏和显示面板

使用```hide_panel()```函数可以隐藏面板，它仅仅是把面板从面板栈中移走，不会破坏被隐藏面板所关联的结构。而要在屏幕上隐藏面板需要调用```update_panels()```函数和```doupdate()```函数。此外，show_panel()函数可以让显示已隐藏面板。
以下程序展示了面板的隐藏。按下```’a’``` 或```’b’``` 或```‘c’``` 键分别显示或隐藏第一、二、三个窗口。使用了用户数据中一个叫做```hide``` 的变量来跟踪窗口，标记出该窗口是否被隐藏。由于某些原因，```panel_hidden()```函数（它用来告诉用户一个面板是否隐藏）不能够正常工作。```MichaelAndres``` 在这里提供了一个错误报告。

## 例、一个隐藏和显示面板的例子

```c
/*
Compile: gcc main.c -lncurses -lpanel
*/
#include <ncurses.h>
#include <panel.h>
#include <string.h>
#include <stdlib.h>

typedef struct _PANEL_DATA {
    int hide; /* 如果面板是隐藏的时候为真*/
}PANEL_DATA;

#define NLINES 10
#define NCOLS 40

void init_wins(WINDOW **wins, int n);
void win_show(WINDOW *win, char *label, int label_color);
void print_in_middle(WINDOW *win, int starty, int startx, 
                     int width, char *string, chtype color);
int main()
{ 
    WINDOW *my_wins[3];
    PANEL *my_panels[3];
    PANEL_DATA panel_datas[3];
    PANEL_DATA *temp;
    int ch;
    
    /* 初始化curses */
    initscr();
    start_color();
    cbreak();
    noecho();
    keypad(stdscr, TRUE);
    
    /* 初始化所有的颜色*/
    init_pair(1, COLOR_RED, COLOR_BLACK);
    init_pair(2, COLOR_GREEN, COLOR_BLACK);
    init_pair(3, COLOR_BLUE, COLOR_BLACK);
    init_pair(4, COLOR_CYAN, COLOR_BLACK);
    
    init_wins(my_wins, 3);
    
    /* 更新面板栈的顺序。把面板2 置于栈顶*/
    my_panels[0] = new_panel(my_wins[0]);
    /* 把面板0 压入栈，顺序: stdscr0*/
    my_panels[1] = new_panel(my_wins[1]);
    /* 把面板1 压入栈。顺序: stdscr01*/
    my_panels[2] = new_panel(my_wins[2]);
    /* 把面板2 压入栈,顺序: stdscr012*/
    
    /* 初始化所有的面板并都设为非隐藏的*/
    panel_datas[0].hide= FALSE;
    panel_datas[1].hide= FALSE;
    panel_datas[2].hide= FALSE;
    set_panel_userptr(my_panels[0],&panel_datas[0]);
    set_panel_userptr(my_panels[1],&panel_datas[1]);
    set_panel_userptr(my_panels[2],&panel_datas[2]);
    /* 更新面板栈的顺序，第二个面板将置于栈顶*/
    update_panels();
    /* 在屏幕上显示*/
    attron(COLOR_PAIR(4));
    mvprintw(LINES-3,0, "Show or Hide a window with 'a'(first window)"\
                        "'b'(Second Window)'c'(ThirdWindow)");
    mvprintw(LINES-2,0, "F1 to Exit");
    attroff(COLOR_PAIR(4));
    doupdate();
    while((ch = getch()) != KEY_F(1))
    {
        switch(ch)
        { 
            case 'a':
                temp = (PANEL_DATA *)panel_userptr(my_panels[0]);
                if(temp->hide == FALSE)
                { 
                    hide_panel(my_panels[0]);
                    temp->hide = TRUE;
                }
                else
                { 
                    show_panel(my_panels[0]);
                    temp->hide = FALSE;
                }
                break;
            case 'b':
                temp = (PANEL_DATA *)panel_userptr(my_panels[1]);
                if(temp->hide == FALSE)
                { 
                    hide_panel(my_panels[1]);
                    temp->hide = TRUE;
                }
                else
                { 
                    show_panel(my_panels[1]);
                    temp->hide = FALSE;
                }
                break;
            case 'c':
                temp = (PANEL_DATA *)panel_userptr(my_panels[2]);
                if(temp->hide == FALSE)
                { 
                    hide_panel(my_panels[2]);
                    temp->hide = TRUE;
                }
                else
                { 
                    show_panel(my_panels[2]);
                    temp->hide = FALSE;
                }
                break;
        }
        update_panels();
        doupdate();
    }
    endwin();
    return 0;
}
/* 显示所有窗口*/
void init_wins(WINDOW **wins, int n)
{ 
    int x, y, i;
    char label[80];
    y = 2;
    x = 10;
    for(i = 0; i < n; ++i)
    { 
        wins[i] = newwin(NLINES, NCOLS, y, x);
        sprintf(label, "Window Number %d", i + 1);
        win_show(wins[i], label, i + 1);
        y += 3;
        x += 7;
    }
}
/* 通过边框和标题显示窗口*/
void win_show(WINDOW *win, char *label, int label_color)
{
    int startx, starty, height, width;
    getbegyx(win, starty, startx);
    getmaxyx(win, height, width);
    box(win, 0, 0);
    mvwaddch(win, 2, 0, ACS_LTEE);
    mvwhline(win, 2, 1, ACS_HLINE, width-2);
    mvwaddch(win, 2, width-1,ACS_RTEE);
    print_in_middle(win, 1, 0, width, label, COLOR_PAIR(label_color));
}

void print_in_middle(WINDOW *win, int starty, int startx, 
                     int width, char *string, chtype color)
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
    wattron(win, color);
    mvwprintw(win, y, x, "%s", string);
    wattroff(win, color);
    refresh();
}
```

## 测试结果

```
原始：
          ┌──────────────────────────────────────┐
          │           Window Number 1            │
          ├──────────────────────────────────────┤
          │      ┌──────────────────────────────────────┐
          │      │           Window Number 2            │
          │      ├──────────────────────────────────────┤
          │      │      ┌──────────────────────────────────────┐
          │      │      │           Window Number 3            │
          │      │      ├──────────────────────────────────────┤
          └──────│      │                                      │
                 │      │                                      │
                 │      │                                      │
                 └──────│                                      │
                        │                                      │
                        │                                      │
                        └──────────────────────────────────────┘
Show or Hide a window with 'a'(first window)'b'(Second Window)'c'(ThirdWindow)
F1 to Exit

隐藏window1，press“a”
                 ┌──────────────────────────────────────┐
                 │           Window Number 2            │
                 ├──────────────────────────────────────┤
                 │      ┌──────────────────────────────────────┐
                 │      │           Window Number 3            │
                 │      ├──────────────────────────────────────┤
                 │      │                                      │
                 │      │                                      │
                 │      │                                      │
                 └──────│                                      │
                        │                                      │
                        │                                      │
                        └──────────────────────────────────────┘
同理，隐藏window2和window3按“b”，“c”
          ┌──────────────────────────────────────┐
          │           Window Number 1            │
          ├──────────────────────────────────────┤
          │                                      │
          │                                      │
          │                                      │
          │                                      │─────────────┐
          │                                      │3            │
          │                                      │─────────────┤
          └──────────────────────────────────────┘             │
                        │                                      │
                        │                                      │
                        │                                      │
                        │                                      │
                        │                                      │
                        └──────────────────────────────────────┘
          ┌──────────────────────────────────────┐
          │           Window Number 1            │
          ├──────────────────────────────────────┤
          │      ┌──────────────────────────────────────┐
          │      │           Window Number 2            │
          │      ├──────────────────────────────────────┤
          │      │                                      │
          │      │                                      │
          │      │                                      │
          └──────│                                      │
                 │                                      │
                 │                                      │
                 └──────────────────────────────────────┘
```

## panel_above()和panel_below()类函数

panel_above()和panel_below()函数可以分别用来查看某个面板的上层和下层面板。如果参数为NULL，它们就分别返回面板栈中最上层和最下层面板的指针。





