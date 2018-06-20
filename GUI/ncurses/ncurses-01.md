* Copyright(C) NCURSES Programming HOWTO

## NCURSES 是什么？

你可能会疑惑，引入的这些技术术语是什么。假设在使用termcap 或者terminfo 的情况下，每个应用程序都在访问terminfo 数据库并且做一些必要的处理（比如发送控制字符等等）。不久这些操作的复杂度将会变得难以控制。于是，curses 诞生了。curses 的命名是来自一个叫做“```cursor optimization```”（光标最优化）的双关语（译者注：curses 本身有诅咒的意思）。curses 构成了一个工作在底层终端代码之上的封装，并向用户提供了一个灵活高效的```API```（Application Programming Interface 应用程序接口）。它提供了移动光标，建立窗口，产生颜色，处理鼠标操作等功能。使程序员编写应用程序不需要关心那些底层的终端操作。
那么ncurses 又是什么？ncurses是最早的```System V Release 4.0 (SVr4)```中```CURSES ```的一个克隆。这是一个可自由配置的库，完全兼容旧版本的curses。简而言之，它是一个管理应用程序在字符终端显示的函数库。当后面提到curses 的时候，同时也可以和NCURSES互换。
关于ncurses 详细的更新历史可以查阅ncurses 源代码分发包中的NEWS 文件。ThomasDickey 是目前的维护人员。你可以通过```bugncurses@gnu.org```联系维护人员

## 我们可以用NCURSES 做什么？

ncurses 不仅仅封装了底层终端功能，而且提供了一个相当稳固的工作框架（ Framework）可以在字符模式下产生美观的界面。它提供了一些创建窗口的函数。而它的姊妹库Menu、Panel 和Form 则对curses 基础库及进行了扩展。这些扩展库通常都随同curses 一起发行。
我们可以建立一个同时包含多个窗口（multiple windows）、菜单（menus）、面板（panels）和表单（forms）的应用程序。窗口可以被独立管理，例如让它滚动或者隐藏。菜单（Menus）可以让用户建立命令选项，方便用户执行命令。而表单（ Forms）允许用户建立一些简单的数据输入和输出的窗口。面板（Panels）是ncurses 窗口管理功能的扩展，可以用它覆盖或堆积窗口。
以上这些就是ncurses 的简单介绍。在以后的章节里，我们将详细的介绍这些库。

## 在哪能得到它

http://ftp.gnu.org/gnu/ncurses/

## 如何编译ncurses源代码

```shell
tar zxvf ncurses<version>.tar.gz  # 解压缩并且释放文件包
cd ncurses<version>               # 进入解压缩的目录（注意版本）
./configure                       # 按照你的系统环境制作安装配置文件
make                              # 编译源代码并且编译ncurses 库
su root                           # 获得root 权限
make install                      # 安装编译好的NCURSES 库
```
