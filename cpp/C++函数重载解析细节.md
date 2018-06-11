* Copyright（C）《C++从入门到精通-经典完整版》

## 函数重载解析细节

# 函数重载解析过程有三个步骤这些步骤可以总结如下:

* 1 确定为该调用而考虑的候选函数以及函数调用中的实参表属性
* 2 从候选函数中选出可行函数也就是说根据调用中指定的实参实参数目和类型选择可以被调用的函数
* 3 对于被用来将实参转换成可行函数参数类型的转换划分等级以便选出与调用最匹配的函数

## 9.4.1 候选函数

候选函数与被调用的函数具有同样的名字可以用下面两种方式找到候选函数.

* 该函数的声明在调用点上可见给出下列例子:

```cpp
void f();
void f( int );
void f( double, double = 3.4 );
void f( char*, char* );
int main() {
    f( 5.6 ); // 这个调用有四个候选函数
    return 0;
}
```

因为在全局域中声明的四个f()在调用点上都可见所以它们都是候选函数集的一部分.

* 2 如果函数实参的类型是在一个名字空间中被声明的则该名字空间中与被调用函数同名的成员函数也将被加入到候选函数集中例如:

```cpp
namespace NS {
    lass C { /* ... */ };
    oid takeC( C& );
}
// cobj 的类型是在名字空间NS 中被声明的类C
NS::C cobj;
int main() {
    // 在调用点没有takeC()可见
    takeC( cobj ); // ok: 调用 NS::takeC( C& )
    // 因为实参类型是 NS::C
    // 所以考虑在名字空间NS 中声明的函数takeC()
    return 0;
}
```

因此候选函数是在调用点上可见的函数以及在实参类型所在的名字空间中声明的同名函数的集合.
当我们确定在调用点上可见的重载函数集合时我们在前面看到的关于怎样生成重载函数集的规则仍然适用.
在嵌套的域中被声明的函数隐藏了而不是重载了外围域中的同名函数这种情况下的候选函数是在嵌套域中被声明的函数即没有被该函数调用隐藏的函数在下面的例子中在
调用点上可见的候选函数是format(double)和format(char*).

```cpp
char* format( int );
void g() {
    char* format( double );
    char* format( char* );
    format(3); // 调用 format( double )
}
```

因为在全局域中声明的函数format(int)被隐藏所以它没有被包含在候选函数集中在调用点上可见的using 声明也可以引入候选函数考虑下列例子:

```cpp
namespace libs_R_us {
    int max( int, int );
    double max( double, double );
}
char max( char, char );
void func()
{
    // 名字空间的函数不可见
    // 这三个调用分别调用全局函数 max( char, char )
    max( 87, 65 );
    max( 35.5, 76.6);
    max( 'J', 'L' );
}
```

名字空间libs_R_us 中定义的函数max()在调用点上不可见惟一可见的是全局域中声明的函数max(). 该函数是候选函数集中惟一的一个函数它是func()中三个调用所调用的函数.我们可以用using 声明使名字空间libs_R_us 中声明的函数max()变为可见那么using 声明应该放在哪儿呢? 如果把using 声明放在全局域中

```cpp 
char max( char, char );
using libs_R_us::max; // using 声明
```

那么来自名字空间libs_R_us 中的函数max()就将被加到重载函数集中该集合同时还包含全局域中声明的函数max() 现在三个函数在func()中都可见并且都成为侯选函数集中的一部分随着三个函数在调用点上可见func()中的调用被解析如下

```cpp 
void func()
{
    max( 87, 65 ); // 调用 libs_R_us::max( int, int )
    max( 35.5, 76.6 ); // 调用 libs_R_us::max( double, double )
    max( 'J', 'L' ); // 调用 max( char, char )
}
```

但是如果我们在函数func()的局部域中如下引入了using 声明又会怎么样呢

```cpp 
void func()
{
    // using 声明
    using libs_R_us::max;
    // 函数调用如上
}
```

候选函数集中会包含哪些max() 请回忆一下using 声明的嵌套由于局部域中的using声明全局函数max(char, char)被隐藏在调用点上可见的函数只是

```cpp
libs_R_us::max( int, int )
libs_R_us::max( double, double )
```

这两个函数是候选函数集中的函数func()中的调用被解析如下

```cpp 
void func()
{
    // using 声明
    // 全局 max( char, char ) 被隐藏
    using libs_R_us::max;
    max( 87, 65 ); // 调用 libs_R_us::max( int, int )
    max( 35.5, 76.6 ); // 调用 libs_R_us::max( double, double )
    max( 'J', 'L' ); // 调用 libs_R_us::max( int, int )
}
```

using 指示符也会影响候选函数集的构成假设我们决定用using 指示符而不是using 声明使名字空间lib_R_us 中的函数max()在func()中可见例如使用下面全局域中的using指示符候选函数集就将包含全局函数max(char,char)以及在名字空间libs_R_us 中声明的函数max(int, int)和max(double, double)

```cpp 
namespace libs_R_us {
    int max( int, int );
    double max( double, double );
}
char max( char, char );
using namespace libs_R_us; // using 指示符
void func()
{
    max( 87, 65 ); // 调用 libs_R_us::max( int, int )
    max( 35.5, 76.6 ); // 调用 libs_R_us::max( double, double )
    max( 'J', 'L' ); // 调用 ::max( char, char )
}
```

假若像下面这样将using 指示符放到func()的局部域内又会怎么样呢

```cpp 
void func()
{
    // using 指示符
    using namespace libs_R_us;
    // 函数调用如上
}
```

哪些max()会成为候选函数记住using 指示符使名字空间成员可见就好像它们是在名字空间之外在定义名字空间的位置上被声明的一样在我们的例子中名字空间libs_R_us的成员在func()的局部域内可见就好像该成员已经在名字空间之外全局域内被声明的样这暗示着在func()内可见的重载函数集与前面包含下列三个函数的一样

```cpp 
max( char, char )
libs_R_us::max( int, int )
libs_R_us::max( double, double )
```

无论using 指示符出现在全局域还是func()的局部域内都不会影响func()中的调用的解析过程

```cpp 
void func()
{
    using namespace libs_R_us;
    max( 87, 65 ); // 调用 libs_R_us::max( int, int )
    max( 35.5, 76.6 ); // 调用 libs_R_us::max( double, double )
    max( 'J', 'L' ); // 调用 ::max( char, char )
}
```

所以候选函数集是在调用点上可见的函数包括using 声明和using 指示符引入的函数以及在与实参类型相关的名字空间内被声明的成员函数例如

```cpp 
namespace basicLib {
    int print( int );
    double print( double );
}
namespace matrixLib {
    class matrix { /* ... */ };
    void print( const matrix & );
}
void display()
{
    using basicLib::print;
    matrixLib::matrix mObj;
    print( mObj ); // 调用 matrixLib::print( const matrix& )
    print( 87 ); // 调用 basicLib::print( int )
}
```

哪些函数是调用print(mObj)的候选函数因为由函数display()中的using 声明引入的函数basicLib::print(int)和basicLib::print(double)在调用点上可见所以它们都是候选函数因为函数调用实参的类型是matrixLib::matrix 所以在名字空间matrixLib 中声明的函数print()也是个候选函数调用print(87)的候选函数是哪些呢在调用点上只有函数basicLib::print(int)和basicLib::print(double)可见所以它们是候选函数因为实参的类型是int 所以编译器不会在其他名字空间中寻找其他候选函数

## 9.4.2 可行函数

可行函数是候选函数集合中的函数它的参数表或者与调用中的实参数目相同或者有更多的参数在后一种情况下额外的参数会被给出缺省实参以便可以用实参表中指定的实参调用该函数可行函数是这样的函数对于每个实参都存在到函数参数表中相应的参数类型之间的转换
在下面的例子中对调用f(5.6)来说有两个可行函数它们是f(int)和f(double)

```cpp 
void f();
void f( int );
void f( double );
void f( char*, char* );
int main() {
    f( 5.6 ); // 两个可行函数: f( int ) 和 f( double )
    return 0;
}
```

f(int)是可行函数因为它只有一个参数这与函数调用中实参的数目匹配并且存在着把实参从double 型转换成int 型的标准转换f(double)也是个可行函数这个可行函数只有一个参数类型为double 是调用中实参的精确匹配候选函数f()和f(char*, char*)被排除在可行函数集合之外是因为这些函数不能用一个实参调用

在下面的例子中调用format(3)的唯一可行函数是函数format(double) 虽然候选函数format(char*)也可以用一个实参调用但是在int 型的实参和char*型的参数之间不存在转换就因为不存在该类型转换所以该函数被排除在可行函数集合之外

```cpp 
char* format( int );
void g() {
    // 全局函数 format( int ) 被隐藏
    char* format( double );
    char* format( char* );
    format(3); // 只有一个可行函数: format( double )
}
```

在下面的例子中三个候选函数都在func()中max()调用的可行函数集合中这三个函数都可以用两个实参来调用因为实参类型是int 它是libs_R_us::max(int,int)的参数的精确匹配所以这两个实参可以通过浮点—整值标准转换转换成libs_R_us::max(double,double)的参数以及通过整值标准转换转换成max(char,char)的参数

```cpp 
namespace libs_R_us {
    int max( int, int );
    double max( double, double );
}
// using 声明
using libs_R_us::max;
char max( char, char );
void func()
{
    // 这三个 max() 都是可行函数
    max( 87, 65 ); // 调用 libs_R_us::max( int, int )
}
```

注意对于有多个参数的候选函数来说只要函数调用中的一个实参不能被转换成候选函数参数表中相应的参数它就将马上被排除在可行函数集合之外即使其他实参都存在转换在下面的例子中函数min(char*,int)被排除在可行函数之外因为在第一个实参int 类型与相应函数参数char*类型之间不存在转换即使第二个实参是函数的第二个参数的精确匹配该函数也会被排除

```cpp 
extern double min( double, double );
extern int min( char*, int );
void func()
{
    // 候选函数 min( double, double )
    min( 87, 65 ); // 调用 min( double, double )
}
```

如果在去掉参数个数不同的候选函数或去掉不存在合适的类型转换的候选函数之后没有可行函数存在则该调用就会导致编译时刻错误在这种情况下我们就说没有找到匹配

```cpp
void print( unsigned int );
void print( char* );
void print( char );
int *ip;
class SmallInt { /* ... */ };
SmallInt si;
int main() {
    print( ip ); // 错误: 没有可行函数: 没有匹配
    print( si ); // 错误: 没有可行函数: 没有匹配
    return 0;
}
```

## 9.4.3 最佳可行函数

最佳可行函数是具有与实参类型匹配最好的参数的可行函数对于每个可行函数来说每个实参的类型转换都被划分了等级以决定每个实参与其相应参数的匹配程度.最佳可行函数是满足下列条件的可行函数

* 1 用在实参上的转换不比调用其他可行函数所需的转换更差
* 2 在某些实参上的转换要比其他可行函数对该参数的转换更好

将实参转换成相应的函数参数时可能不只应用一种类型转换例如在下面的例子中

```cpp 
int arr[3];
void putValues(const int *);
int main() {
    putValues(arr); // 在转换序列中有2 个转换
    // 数组到指针限定修饰转换
    return 0;
}
```

将实参arr 从三个int 元素的数组转换成const int 指针类型应用了一个转换序列该转换序列由下列转换构成

* 1 从数组到指针的转换将实参从三个int 元素的数组转换成int 型的指针
* 2 限定修饰转换把int 型的指针转换成const int 型的指针

因此说一个转换序列conversion sequence 被用来把实参转换成可行函数参数的类型更为合适因为是一个转换序列而不是单个转换被应用到实参上将其转换成相应参数的类型所以函数重载解析的第三步是将转换序列划分等级

转换序列的等级是构成该序列最坏转换的等级正如在9.2 节中描述的类型转换的等级划分如下精确匹配好于提升提升好于标准转换在前面的例子中序列中的两个转换都具有精确匹配的等级
一个转换序列潜在地由下列转换以下列顺序构成
        左值转换——提升或者标准转换——限定修饰转换

* 左值转换lvalue transformation 是指精确匹配类别中描述的前三个转换从左值到右值的转换从数组到指针的转换和从函数到指针的转换转换序列的构成是这样的首先是0 个或一个左值转换接着是0 个或一个提升或者0 个或一个标准转换再后面是0 个或一个限定修饰转换至多每种转换会有一个被应用上以将实参转换成相应的参数

这种转换序列被称为标准standard 转换序列还有另外一种转换序列被称为用户定义的user-defined 转换序列用户定义的转换序列包含类成员转换函数类成员转换函数和用户定义的转换序列
下面的例子中实参上的转换序列是什么

```cpp 
namespace libs_R_us {
    int max( int, int );
    double max( double, double );
}
// using 声明
using libs_R_us::max;
void func()
{
    char c1, c2;
    max( c1, c2 ); // 调用 libs_R_us::max( int, int )
}
```

在max()的调用中的实参是char 型的调用函数libs_R_us::max(int, int)的实参上的转换序列如下

* 1a 因为该实参按值传递所以首先是从左值到右值转换它从实参c1 和c2 中抽取值
* 2a 提升转换将实参从char 转换到int

调用函数libs_R_us::max(double,double)的实参上的转换序列如下

* 1b 先应用一个从左值到右值的转换它从实参c1 和c2 抽取值
* 2b 浮点——整值标准转换将实参从char 转换成double

第一个转换序列的等级是提升序列中最差的转换而第二个转换序列的等级是标准转换因为提升比标准转换好所以函数libs_R_us::max(int,int)被选为该调用的最佳可行函数或最佳匹配函数
如果通过对实参上的转换序列划分等级仍然不能够判别出一个可行函数比其他函数更匹配实参的类型则该调用就是二义的在下面的例子中calc()的两个实例都要求下列转换序列

* 1 首先是一个从左值到右值的转换它从实参i 和j 中抽取值
* 2 通过一个标准转换把实参转换成相应的参数

因为每个转换序列都和另一个一样好所以该调用是二义的

```cpp
int i, j;
extern long calc( long, long );
extern double calc( double, double );
void jj() {
    // 错误: 二义, 没有最佳匹配
    calc( i, j );
}
```

限定转换把const 或volatile 修饰符加到指针指向的类型上的转换具有精确匹配的等级但是如果两个转换序列前面都相同只是一个在序列尾部有一个额外的限定转换则另一个没有额外限定转换的序列比较好例如

```cpp 
void reset( int * );
void reset( const int * );
int* pi;
int main() {
    reset( pi ); //没有限定转换的比较好; 选择 reset( int * )
    return 0;
}
```

应用在调用第一个候选函数reset(int*)的实参上的标准转换序列是个精确匹配它只要求一个从左值到右值的转换来抽取实参的值对第二个候选函数reset(const int*) 也应用了一个从左值到右值的转换接着是限定修饰转换把结果值从int 指针转换成const int 指针这两个序列都是精确匹配但是上面的函数调用不是二义的因为这两个转换序列的第一个转换相同但是第二个转换序列末尾有额外的限定修饰转换所以第一个没有限定修饰转换的序列被认为是较好的匹配因此可行函数reset(int*)是最佳可行函数

下面是另一个例子其中限定修饰转换影响了被选择的转换序列:

```cpp 
int extract( void * );
int extract( const void * );
int* pi;
int main() {
    extract( pi ); // 选择 extract( void * )
    return 0;
}
```

该调用有两个可行函数extract(void*)和extract(const void*) 在调用第一个可行函数extract(void*)上应用的转换序列中有一个从左值到右值的转换来抽取实参的值接着是一个标准指针转换它将该值从一个int 指针转换成一个void 指针应用在调用第二个函数extract(const void*)上的转换序列也是如此只不过还应用了一个额外的限定修饰转换它将结果从void 指针转换成const void 指针因为这两个转换序列除了第二个转换序列在尾部是一个额外的限定修饰转换外其余都是相同的所以第一个转换序列被选择为更好的转换序列函数extract(void*)被选为该实参的最佳可行函数
const 或volatile 修饰符也能影响引用参数的初始化的等级如同转换序列的情形一样如果两个引用初始化是相同的只不过其中一个增加了一个额外的const 或volatile 修饰符那么对于函数重载解析来说没有额外修饰符的引用初始化是比较好的引用初始化例如:

```cpp 
#include <vector>
void manip( vector<int> & );
void manip( const vector<int> & );
vector<int> f();
extern vector<int> vec;
int main() {
    manip( vec ); // 选择 manip( vector<int> & ) is selected
    manip( f() ); // 选择 manip( const vector<int> & ) is selected
    return 0;
}
```

在第一个调用中两个调用的引用初始化都是精确匹配但是该调用不是二义的因为两个引用初始化都相同除了第二个加上了const 修饰符所以没有额外限定修饰的初始化被认为是较好的初始化因此可行函数manip(vector<int>&)是第一个调用的最佳可行函数
在第二个调用中该调用只有一个可行函数manip(const vector<int>&) 因为实参是存放函数f()返回值的临时单元所以该实参是一个右值它不能被用来初始化manip(vector<int>&)的非const 引用参数因此对于第二个调用的最佳可行函数编译器只考虑一个可行函数manip(const vector<int>&)
当然函数调用可以有一个以上的实参选择最佳可行函数时必须考虑转换全部实参所需的转换序列的等级我们来看一个例子:

```cpp 
extern int ff( char*, int );
extern int ff( int, int );
int main() {
    ff( 0, 'a' ); // ff( int, int )
    return 0;
}
```

由于下述原因有两个int 型的参数的函数ff()被选为最佳可行函数

* 1 它的第一个实参较好0 是int 型的参数的精确匹配而对于第一个ff(char*,int)函数来说它需要一个指针标准转换序列来匹配char*型的参数
* 2 它们的第二个实参一样好实参a 的类型是char 两个函数的第二个参数的匹配都要求一个提升等级的转换序列

这里还有另外一个例子

```cpp 
int compute( const int&, short );
int compute( int&, double );
extern int iobj;
int main() {
    compute( iobj, 'c' ); // compute( int&, double )
    return 0;
}
```

这两个函数compute(const int&,short)和compute(int&,double)都是可行函数由于下述原因第二个函数被选为最佳可行函数

* 1 它的第一个实参较好第一个可行函数的引用初始化比较差因为它加入了一个const限定修饰符而第二个可行函数的初始化没有加入const 限定修饰符
* 2 它们的第二个实参一样好实参c 的类型是char 要匹配两个函数的第二个参数都要求一个标准转换等级的转换序列

## 9.4.4 缺省实参

缺省实参可以使多个函数进入到可行函数集合中可行函数是指可以用调用中指定的实参进行调用的函数可行函数可以有比函数调用实参表中的实参个数更多的参数只要每个多出来的参数都有相应的缺省实参即可

```cpp 
extern void ff( int );
extern void ff( long, int = 0 );
int main() {
    ff( 2L ); // 匹配 ff( long, 0 );
    ff( 0, 0 ); // 匹配 ff( long, int );
    ff( 0 ); // 匹配 ff( int );
    ff( 3.14 ); // 错误: 二义
}
```

对于第一个和第三个调用即使该实参表中只有一个实参第二个函数ff()仍然是两个调用的可行函数原因如下

* 1 函数的第二个参数有相应的缺省实参
* 2 函数的第一个参数是long 型与第一个调用的实参类型精确匹配通过标准转换等级的转换序列与第三个调用的实参类型也匹配

最后一个调用是二义的这是因为通过在第一个实参上应用标准转换两个实例都可以匹配这里不能选择ff(int)作为更好的函数因为它只有一个实参
