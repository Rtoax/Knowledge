* Copyright(C) NCURSES Programming HOWTO

# 键盘管理

## 基础知识

每一个GUI（图形用户界面）都有强大的用户交互界面。一个curses 程序应该对用户的输入（仅通过键盘和鼠标）及时的做出反应。那就让我们从处理键盘开始。就像前面章节中的例子那样，很容易就能取得用户的输入。一个最简单的方法是使用```getch()```函数。如果你喜欢处理单个按键，而不是处理一行的话（经常以回车键作为一行结束标志），你应该在读取按键之前激活```cbreak``` 模式。如果要读取功能键则应该激活```keypad```。这两个函数的用法详见初始化一章。
```getch()```返回一个整数来对应键盘上的按键。如果你输入的是一个普通字符，这个整数就等价于该字符。如果是其它字符，它就返回一个在```curses.h``` 中已定义的常量相匹配的值。例如用户按下了```F1```，返回的整数将是```265```，该值可以通过```curses.h``` 中内定义的宏```KEY_F()```检测。这样可以更方便的管理键盘的输入。

例如，如果你这样调用```getch()```函数：

```c
int ch;
ch = getch();
```

```getch()``` 函数将等待用户输入（除非你规定了延时时间）。当你按下一个键，就会返回相应的整数，之后你可以检测这个值是否是你要按的键。当然，这些相对应的值可以在```curses.h```中找到。
以下这段代码就可以用来监测键盘左方向键：

```c
if(ch == KEY_LEFT)
printw("Left arrow is pressed\n");
```

让我们写一个可以通过上下键操纵的窗口菜单。

## 一个简单的使用键盘的例子

例： 一个读取键盘的例子

```c
/*
Compile: gcc main.c -lncurses
*/
#include <stdio.h>
#include <ncurses.h>
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
int main()
{ 
    WINDOW *menu_win;
    int highlight = 1;
    int choice = 0;
    int c;
    
    initscr();
    clear();
    noecho();
    cbreak(); /*禁用行缓冲，直接传递所有输入*/
    
    startx = (80-WIDTH)/ 2;
    starty = (24-HEIGHT)/ 2;
    
    menu_win = newwin(HEIGHT, WIDTH, starty, startx);
    
    keypad(menu_win,TRUE);
    
    mvprintw(0, 0,"Use arrow keys to go up and down, Press enter to select a choice");
    refresh();
    print_menu(menu_win,highlight);
    
    while(1)
    { 
        c = wgetch(menu_win);
        switch(c)
        { 
            case KEY_UP:
                if(highlight == 1)
                    highlight = n_choices;
                else
                    --highlight;
                break;
                
            case KEY_DOWN:
                if(highlight == n_choices)
                    highlight = 1;
                else
                    ++highlight;
                break;
                
            case 10:
                choice = highlight;
                break;
                
            default:
                mvprintw(24, 0, "Charcter pressed is = %3d \
                                 Hopefully it can be printed as '%c'", c, c);
                refresh();
                break;
        }
        print_menu(menu_win,highlight);
        
        if(choice != 0) /*用户必须要做一个选择*/
        break;
    }
    mvprintw(23, 0, "You chose choice %d with choice string %s\n"
                    , choice,choices[choice-1]);
    clrtoeol();
    
    refresh();
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
        if(highlight == i + 1)  /* 使选择的字符串高亮显示*/
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
/**
结果：
                         ┌────────────────────────────┐
                         │                            │
                         │ Choice 1                   │
                         │ Choice 2                   │
                         │ Choice 3                   │
                         │ Choice 4                   │
                         │ Exit                       │
                         │                            │
                         │                            │
                         └────────────────────────────┘
*/
```
