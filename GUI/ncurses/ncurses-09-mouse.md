* Copyright(C) ```NCURSES Programming HOWTO```

# 使用鼠标

你现在已经知道如何取得键盘的输入了，那现在让我们也来取得鼠标的输入。因为很多用户界面程序都支持使用键盘和鼠标的共同操作。

## 基础知识

在使用鼠标之前，首先要调用```mousemask( )```这个函数来激活你想要接收的鼠标事件。

```c
mousemask( mmask_t newmask, /* 你想要监听的鼠标事件掩码*/
mmask_t *oldmask ) /* 旧版本使用的鼠标事件掩码*/
```

上述函数中的第一个参数，就是你所要监听的事件的```位掩码```，默认情况下，在使用该函数之前，所有鼠标事件的接收状态都是未激活的。位掩码```ALL_MOUSE_EVENTS``` 可以让鼠标接收所有的事件。
下面是NCURSES 定义的位掩码清单：（注意：不同的鼠标按键号码设置不同，使用前需要测试。一般情况下左键为1 号，右键为2 号）

```
掩码                      对应事件
BUTTON1_PRESSED         鼠标1 号键      按下
BUTTON1_RELEASED        鼠标1 号键      释放
BUTTON1_CLICKED         鼠标1 号键      单击
BUTTON1_DOUBLE_CLICKED  鼠标1 号键      双击
BUTTON1_TRIPLE_CLICKED  鼠标1 号键      三击
BUTTON2_PRESSED         鼠标2 号键      按下
BUTTON2_RELEASED        鼠标2 号键      释放
BUTTON2_CLICKED         鼠标2 号键      单击
BUTTON2_DOUBLE_CLICKED  鼠标2 号键      双击
BUTTON2_TRIPLE_CLICKED  鼠标2 号键      三击
BUTTON3_PRESSED         鼠标3 号键      按下
BUTTON3_RELEASED        鼠标3 号键      释放
BUTTON3_CLICKED         鼠标3 号键      单击
BUTTON3_DOUBLE_CLICKED  鼠标3 号键      双击
BUTTON3_TRIPLE_CLICKED  鼠标3 号键      三击
BUTTON4_PRESSED         鼠标4 号键      按下
BUTTON4_RELEASED        鼠标4 号键      释放
BUTTON4_CLICKED         鼠标4 号键      单击
BUTTON4_DOUBLE_CLICKED  鼠标4 号键      双击
BUTTON4_TRIPLE_CLICKED  鼠标4 号键      三击
BUTTON_SHIFT            在鼠标事件发生时，伴随Shift 键按下
BUTTON_CTRL             在鼠标事件发生时，伴随Ctrl 键按下
BUTTON_ALT              在鼠标事件发生时，伴随Alt 键按下
ALL_MOUSE_EVENTS        报告所有的鼠标事件
REPORT_MOUSE_POSITION   报告鼠标移动位置
```

## 取得鼠标事件

当所有的鼠标监听事件被激活后。```getch()```一类的函数在每次接收到的鼠标事件时可以返回```KEY_MOUSE```。然后通过```getmouse()```函数可以取得这些事件。
代码大概看起来是这样：

```c
MEVENT event;
ch = getch();
if(ch == KEY_MOUSE)
if(getmouse(&event)== OK)
{
    /* 处理这个事件的代码*/
}
```

```getmouse()```函数将这个事件返回一个相应的指针。这个指针结构是这样的：

```c
typedef struct
{
    short id; /* ID 用来辨别不同的设备*/
    int x, y, z; /* 事件发生的坐标*/
    mmask_t bstate; /* 鼠标按键状态*/
}
```

```Bstate``` 是我们关注的最主要变量，它返回了当前鼠标按键的状态。下面的这段代码可以让我们看看按下鼠标左键会出现什么：

```c
if(event.bstate & BUTTON1_PRESSED)
    printw("Left Button Pressed");
```

## 把它们放在一起

能够使用鼠标操作的程序是非常棒的，让我们做用鼠标操作的菜单程序。为了让例子看起来更有针对性，这个程序中去掉了键盘操作：

* 这个代码是书中的代码，可能有些问题，在文章最后添加了另外一个网友的代码。

```c
/*
Compile: gcc main.c -lncurses
*/
#include <stdio.h>
#include <ncurses.h>
#include <string.h>
#include <stdlib.h>

#define WIDTH 30
#define HEIGHT 10

int startx = 0;
int starty = 0;

char *choices[] = {
            "Choice 1",
            "Choice 2",
            "Choice 3",
            "Choice 4",
            "Exit",};
            
int n_choices = sizeof(choices) / sizeof(char *);
void print_menu(WINDOW *menu_win, int highlight);
void report_choice(int mouse_x, int mouse_y, int *p_choice);

int main()
{ 
    int c, choice = 0;
    WINDOW *menu_win;
    MEVENT event;
    
    /* 初始化curses */
    initscr();
    clear();
    noecho();
    cbreak();   /* 禁用行缓冲，直接传递所有的信号*/
    
    /* 将窗口放在屏幕中央*/
    //startx = (80-WIDTH)/ 2;
    //starty = (24-HEIGHT)/ 2;
    
    attron(A_REVERSE);
    
    mvprintw(23, 1, "Click on Exit to quit (Works best in a virtual console)");
    
    refresh();
    attroff(A_REVERSE);
    
    /* 首先显示菜单*/
    menu_win = newwin(HEIGHT, WIDTH, starty, startx);
    print_menu(menu_win,1);
    
    /* 监听所有的鼠标事件*/
    mousemask(ALL_MOUSE_EVENTS, 0);
        
        
    while(1)
    { 
        c = wgetch(menu_win);
        
        switch(c)
        { 
            case KEY_MOUSE:
                getmouse(&event);
                if (!wenclose(menu_win, event.y, event.x)) 
                    break; /*do nothing if not in window*/
                
                report_choice(event.x, event.y, &choice);
                if(choice == -1)
                    /* 退出选项*/
                    goto end;
                mvprintw(22, 1, "%d, %d", event.x, event.y);
                refresh();
                
                print_menu(menu_win,choice);
                break;
                
            case 'q' :
                goto end;
                break;
                
            case 'a':
                print_menu(menu_win,2);
                break;
                
            default :
                break;
        }
    }
    
end:
    endwin();
    return 0;
}

void print_menu(WINDOW *menu_win, int highlight)
{
    int x, y, i;
    
    x = 2;
    y = 2;
    
    box(menu_win, 0, 0);
    
    for(i = 0; i < n_choices; ++i)
    { 
        if(highlight == i + 1)
        { 
            wattron(menu_win,A_REVERSE);
            mvwprintw(menu_win, y, x, "%s", choices[i]);
            wattroff(menu_win,A_REVERSE);
        }
        else
            mvwprintw(menu_win, y, x, "%s", choices[i]);
        
        ++y;
    }
    wrefresh(menu_win);
}
/* 报告鼠标所在位置的菜单选项*/
void report_choice(int mouse_x, int mouse_y, int *p_choice)
{ 
    int choice;

    
    for(choice = 0; choice < n_choices; ++choice)
        if(mouse_y == choice 
            && mouse_x >= 0 
            && mouse_x <= strlen(choices[choice]))
        {
            if(choice == n_choices-1)
                *p_choice = -1;
            else
                *p_choice = choice + 1;
            break;
        }
}
```

## 一些辅助函数说明

```mouse_trafo()``` 函数和```wmouse_trafo()```函数用来转换鼠标坐标到相对应的屏幕坐标。想得到详细资料可以阅读```curs_mouse(3X)```的联机```man``` 文档。
```mouseinterval()```函数用来设置识别鼠标单击的间隔时间（即按键按下和弹起的时间，按千分之一秒计）， 并返回上一次设置的间隔时间， 默认的间隔时间是五分之一秒， 即```mouseinterval(200)```。

## 另一位网友的代码，内附网址

```c
/*
https://blog.csdn.net/ccccce/article/details/51096167
Compile: gcc main.c -lncurses
*/
#include <curses.h>
#include <unistd.h>

void showstar(WINDOW * win, const int line);

int main(void)
{
    int key;
    int quit = 0;
    MEVENT mouse;
    WINDOW * win;

    initscr();
    raw();
    win = newwin(10, 50, 5, 3);     /*this must do before keypad*/
    keypad(win, TRUE);              /*then use win.*/
    mousemask(BUTTON1_CLICKED | BUTTON2_CLICKED, 0);    /*set actions*/
    box(win, '|', '-');
    mvwaddch(win, 1, 48, 'X');
    mvwaddstr(win, 3, 3, "Test 1");
    mvwaddstr(win, 4, 3, "Test 2");
    mvwaddstr(win, 5, 3, "Test 3");
    wrefresh(win);

    while (!quit)
    {
        key = wgetch(win);
        switch(key)
        {
            case KEY_MOUSE : 
                getmouse(&mouse); /*get mouse action*/

                if (!wenclose(win, mouse.y, mouse.x)) 
                    break; /*do nothing if not in window*/

                wmouse_trafo(win, &mouse.y, &mouse.x, FALSE);

                if ((3 <= mouse.x && mouse.x <= 8) 
                 && (3 <= mouse.y && mouse.y <= 5))
                    showstar(win, mouse.y);

                if (1 == mouse.y && 48 == mouse.x) /*Clicked 'X'*/
                    quit = 1;

                break;
            case 'q' :
                quit = 1;
                break;
            default :
                break;
        }
    }

    delwin(win);
    endwin();
    return 0;
}

void showstar(WINDOW * win, const int line)
{
    mvwaddch(win, line, 2, '*');
    wrefresh(win);
}
```
