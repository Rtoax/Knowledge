## 安装PostgreSQL

在Windows下的安装就位无脑安装，选择好安装路径就好了，我的安装目录为```D:\PostgreSQL\10```，需要注意一下几点：

* 安装过程中需要一个数据库的目录，我的为```D:\PostgreSQL\10\data```；

* 安装后在安装目录总会有一个环境变量的文件```pg_env.bat```，这个文件中的内容为：

```bat
@ECHO OFF
REM The script sets environment variables helpful for PostgreSQL

@SET PATH="D:\PostgreSQL\10\bin";%PATH%
@SET PGDATA=D:\PostgreSQL\10\data
@SET PGDATABASE=postgres
@SET PGUSER=postgres
@SET PGPORT=5432
@SET PGLOCALEDIR=D:\PostgreSQL\10\share\locale
```

* 这里我们不用这个环境变量设置文件，新建一个名为```env.vbs```的批处理文件，文件内容如下：

```vbs
on error resume next
set sysenv=CreateObject("WScript.Shell").Environment("system") 'system environment array
Path = CreateObject("Scripting.FileSystemObject").GetFolder(".").Path 'add variable
sysenv("PGHOME")="D:\PostgreSQL\10"
sysenv("PGHOST")="localhost"
sysenv("Path")=sysenv("PGHOME")+"\bin;"+sysenv("Path")
sysenv("PGLIB")=sysenv("PGHOME")+"\lib"
sysenv("PGDATA")=sysenv("PGHOME")+"\data"
 
wscript.echo "PostgreSQL Success"
```

* 注意修改里面对应的安装目录，然后双击一下，跳出```PostgreSQL Success```的窗口表明环境变量设置成功。

## 初始化数据库

打开Windows的```CMD```，进入目录```D:\PostgreSQL\10\bin```，并在```CMD```下输入：

```
D:\PostgreSQL\10\bin>initdb.exe -D D:\PostgreSQL\10\data -E UTF-8  -U postgres -W

输入新的超级用户口令:
再输入一遍:

initdb: 目录"D:/PostgreSQL/10/data"已存在，但不是空的
如果您想创建一个新的数据库系统, 请删除或清空
目录 "D:/PostgreSQL/10/data" 或者运行带参数的 initdb
而不是 "D:/PostgreSQL/10/data".

D:\PostgreSQL\10\bin>
```

* 由于data是已经创建的，所以会有如上的提示，如果我们改为```data1```，就会有如下的结果：

```
Success. You can now start the database server using:

    pg_ctl -D ^"D^:^\PostgreSQL^\10^\data1^" -l logfile start
```

## 启动刚才创建的```data1```数据库

```
D:\PostgreSQL\10\bin>pg_ctl -D ^"D^:^\PostgreSQL^\10^\data1^" -l logfile start
等待服务器进程启动 .... 完成
服务器进程已经启动
```

## 进入数据库

```
D:\PostgreSQL\10\bin>psql -U postgres
psql (10.4)
输入 "help" 来获取帮助信息.

postgres=#
```

## 创建一个```TABLE```

```sql
postgres=# create table temp(
postgres(# name text,
postgres(# age integer);
CREATE TABLE
postgres=#
```

## 从文件中读取SQL程序常见一个```TABLE```

文件```create-table.sql```内容如下：

```sql
CREATE TABLE item ( 
    item_id serial , 
    description varchar(64) NOT NULL, 
    cost_price numeric(7,2) , 
    sell_price numeric(7,2) , 
    CONSTRAINT item_pk PRIMARY KEY(item_id) 
);
```

创建```TABLE```

```
D:\PostgreSQL\10\bin>psql -U postgres -d postgres -f create-table.sql
CREATE TABLE
```

显示刚才创建的表

```
postgres=# table item;
 item_id | description | cost_price | sell_price
---------+-------------+------------+------------
(0 行记录)
```

## 删除一个```TABLE```

```
postgres=# drop table item;
DROP TABLE
```
