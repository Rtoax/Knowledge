* Copyright(C) NCURSES Programming HOWTO

## NCURSES 是什么？

你可能会疑惑，引入的这些技术术语是什么。假设在使用termcap 或者terminfo 的情况下，每个应用程序都在访问terminfo 数据库并且做一些必要的处理（比如发送控制字符等等）。
不久这些操作的复杂度将会变得难以控制。于是，curses 诞生了。curses 的命名是来自一个叫做“cursor optimization”（光标最优化）的双关语（译者注：curses 本身有诅咒的意思）。
curses 构成了一个工作在底层终端代码之上的封装，并向用户提供了一个灵活高效的API（Application Programming Interface 应用程序接口）。它提供了移动光标，建立窗口，产
生颜色，处理鼠标操作等功能。使程序员编写应用程序不需要关心那些底层的终端操作。

