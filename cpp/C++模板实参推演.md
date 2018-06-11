* Copyright（C）《C++从入门到精通-经典完整版》

## C++模板实参推演

当函数模板被调用时对函数实参类型的检查决定了模板实参的类型和值这个过程被称为模板实参推演```template argument deduction```
函数模板```min()```的函数参数是一个引用它指向了一个```Type``` 类型的数组:

```cpp
template <class Type, int size>
Type min( Type (&r_array)[size] ) { /* ... */ }
```

为了匹配函数参数函数实参必须也是一个表示数组类型的左值下面的调用是个错误,因为pval 是```int*```类型而不是```int``` 数组类型的左值

```cpp
void f( int pval[9] ) {
    // 错误: Type (&)[] != int*
    int jval = min( pval );
}
```

在模板实参推演期间决定模板实参的类型时编译器不考虑函数模板实例的返回类型.
例如对于如下的```min()```调用

```cpp
double da[8] = { 10.3, 7.2, 14.0, 3.8, 25.7, 6.4, 5.5, 16.8 };
int i1 = min( da );
```

min()的实例有一个参数它是一个指向8 个```double``` 的数组的指针出该实例返回的值的类型是```double ```型该返回值先被转换成int 型然后再用来初始化```i1``` 即使调用```min()```的结果被用来初始化一个```int``` 型的对象也不会影响模板实参的推演过程
要想成功地进行模板实参推演函数实参的类型不一定要严格匹配相应函数参数的类型下列三种类型转换是允许的左值转换限定转换和到一个基类该基类根据一个类模板实例化而来的转换让我们依次来看一看
左值转换包括从左值到右值的转换从数组到指针的转换或从函数到指针的转换,为说明左值转换是怎样影响模板实参推演过程的让我们考虑函数```min2()``` 它有一个名为Type 的模板参数以及两个函数参数```min2()```的第一个函数参数是一个```Type*```型的指针而```size``` 则不再像在```min()```中定义的是个模板参数size 变成一个函数参数,当```min2()```被调用时我们必须显式地为它指定一个函数实参值:

```cpp
template <class Type>
// 第一个参数是 Type*
Type min2( Type* array, int size )
{
    Type min_val = array[0];
    for ( int i = 1; i < size; ++i )
    if ( array[i] < min_val )
    min_val = array[i];
    return min_val;
}
```

我们可以用4 个int 的数组来作为第一个实参调用```min2()``` 如下

```cpp
int ai[4] = { 12, 8, 73, 45 };
int main() {
    int size = sizeof (ai) / sizeof (ai[0]);
    // ok: 从数组到指针的转换
    min2( ai, size );
}
```

函数实参ai 的类型是4 个int 的数组虽然这与相应的函数参数类型```Type*```并不严格匹配但是因为允许从数组到指针的转换所以实参ai 在模板实参Type 被推演之前被转换成```int*```型Type 的模板实参接着被推演为int 最终被实例化的函数模板是```min2(int*,int)```
限定修饰转换把```const``` 或```volatile``` 限定修饰符加到指针上,为说明限定修饰转换是怎样影响模板实参推演过程的我们考虑函数```min3()``` 它的第一个函数参数的类型是```const Type*```

```cpp
template <class Type>
// 第一个参数是 const Type*
Type min3( const Type* array, int size ) {
    // ...
}
```

我们可以用```int*```型的第一个参数调用```min3()``` 如下:

```cpp
int *pi = &ai;
// ok: 到 const int* 的限定修饰转换
int i = min3( pi, 4 );
```

函数实参pi 的类型是int 指针虽然与相应的函数参数类型```const Type*```并不完全匹配但是因为允许限定修饰转换所以函数实参在模板实参被推演之前就先被转换为```const Type*```型了然后```Type``` 的模板实参被椎演为int 被实例化的函数模板是```min3(const int*, int)```
现在再让我们来看看到一个基类该基类根据一个类模板实例化而来的转换如果函数参数的类型是一个类模板且如果实参是一个类它有一个从被指定为函数参数的类模板实例化而来的基类则模板实参的推演就可以进行为说明这个转换我们使用一个新的被称为min4()的函数模板它有一个类型为```Array<Type>&```的参数.

```cpp
template <class Type>
class Array { /* ... */ };
template <class Type>
Type min4( Array<Type>& array )
{
    Type min_val = array[0];
    for ( int i = 1; i < array.size(); ++i )
    if ( array[i] < min_val )
    min_val = array[i];
    return min_val;
}
```

我们可以用类型为```ArrayRC<int>```的第一个实参调用```min4() ArrayRC ```也是类模板.

```cpp
template <class Type>
class ArrayRC : public Array<Type> { /* ... */ };
int main() {
    ArrayRC<int> ia_rc( ia, sizeof(ia)/sizeof(int) );
    min4( ia_rc );
}
```

函数实参ia_rc 的类型是```ArrayRC<int>``` 它与相应的函数参数类型```Array<Type>&```并不完全匹配因为类```ArrayRC<int>```有一个```Array<int>```的基类而Array<int>是一个从被指定为函数参数的类模板实例化而来的类并且派生类类型的函数实参还可以被用来推演一个模板实参所以函数实参ArrayRC<int>在模板实参被推演之前首先被转换成Array<int>型然后Type
的模板实参再被推演为int 被实例化的函数模板是```min4(Array<int>&)```
多个函数实参可以参加同一个模板实参的推演过程如果模板参数在函数参数表中出现多次则每个推演出来的类型都必须与根据模板实参推演出来的第一个类型完全匹配例如

```cpp
template <class T> T min5( T, T ) { /* ... */ }
unsigned int ui;
int main() {
    // 错误: 不能实例化 min5( unsigned int, int )
    // 必须是: min( unsigned int, unsigned int ) 或
    // min( int, int )
    min5( ui, 1024 );
}
```

mins()的函数实参必须类型相同要么都是int 要么都是```unsigned int``` 这是因为模板参数T 必须被绑定在一个类型上从第一个函数实参推演出的T 的模板实参是int 而从第二个函数实参推演出的是unsigned int 因为对于两个函数实参模板实参T 的类型被推演成不同类型所以模板实参推演将失败并且模板实例化也会出错误一种解决办法是在调用min5()时显式指定模板实参我们将在10.4 节介绍怎样实现它
这些可能的类型转换的限制只适用于参加模板实参推演过程的函数实参对于所有其他实参所有的类型转换都是允许的下面的函数模板sum()有两个参数针对第一个参数的实参op1 参与模板实参推演过程而针对第二个参数的实参op2 则没有参与

```cpp
template <class Type>
Type sum( Type op1, int op2 ) { /* ... */ }
```

因为第二个实参不参与模板实参推演过程所以当函数模板```sum()```的实例被调用时可以在第二个实参上应用任何类型转换,例如

```cpp
int ai[] = { ... };
double dd;
int main() {
    // sum( int, int ) 被实例化
    sum( ai[0], dd );
}
```

第一个函数实参dd 的类型与相应的函数参数类型int 不匹配但是对函数模板sum()实例的调用不是错的这是因为第二个实参的类型是固定的不依赖于模板参数对于该调用函数sum(int,int)被实例化实参dd 被通过浮点—有序标准转换转换成类型int所以模板实参推演的通用算法如下

* 1 依次检查每个函数实参以确定在每个函数参数的类型中出现的模板参数
* 2 如果找到模板参数则通过检查函数实参的类型推演出相应的模板实参
* 3 函数参数类型和函数实参类型不必完全匹配下列类型转换可以被应用在函数实参上以便将其转换成相应的函数参数的类型

 左值转换
 限定修饰转换
 从派生类到基类类型的转换假定函数参数具有形式```T<args> T<args>&```或```T<args>*```,则这里的参数表args 至少含有一个模板参数
 
* 4 如果在多个函数参数中找到同一个模板参数则从每个相应函数实参推演出的模板实参必须相同

