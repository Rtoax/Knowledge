## ```#pragma pack(1)```

```cpp
struct {
    char c;
    int i;
}S;
int main()
{
    cout<<sizeof(S)<<endl;
}
```

那么，结果为：

```
$ g++ main.cpp
$ ./a.exe
8
```

如果

```cpp
#pragma pack(1)
struct {
    char c;
    int i;
}S;
```

这样的结果为```5```。

## ```#pragma pack(2)```

如果是这样

```cpp
#pragma pack(2)
struct {
    char c;
    int i;
}S;
```

那么输出结果为```6```

## ```#pragma pack(3)```

错误信息

```
$ g++ main.cpp
main.cpp:5:16: 警告：对齐边界必须是 2 的较小次方，而不是 3 [-Wpragmas]
 #pragma pack(64)
                ^
```

## ```#pragma pack(push,1)```与```#pragma pack(1)```的区别

```#pragma pack (n)```C编译器将按照n个字节对齐。
```#pragma pack ()```取消自定义字节对齐方式。
```#pragma pack (push,1)```把原来对齐方式设置压栈，并设新的1个字节对齐
```#pragma pack(pop)```恢复对齐状态

例如：

```cpp
#pragma pack(push) //保存当前对齐状态
#pragma pack(4)    //设定为4字节对齐 
```

相当于 

```cpp
#pragma  pack (push,4)
```

## 例子

```cpp
#include <iostream>

using namespace std;

#pragma pack(1)
struct {
    char c;
    int i;
    double d;
}S1;
#pragma pack() //与上面#pragma pack(4)对应

#pragma pack(4)
struct {
    char c;
    int i;
    double d;
}S2;
#pragma pack()

#pragma pack(push,4)
struct {
    char c;
    int i;
    double d;
}S3;
#pragma pack(pop)


int main()
{
    cout<<sizeof(S1)<<endl;
    cout<<sizeof(S2)<<endl;
    cout<<sizeof(S3)<<endl;
}
```

结果为：

```
$ g++ main.cpp
$ ./a.exe
13
16
16
```
