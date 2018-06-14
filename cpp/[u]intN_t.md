## ```uint8_t, uint16_t, uint32_t, uint64_t```

在c/c++中，很多以```_t```结尾的数据类型，如```uint8_t```,```size_t```等等，乍一看什么鬼，实际上```_t```的意思就是```typedef```的后缀缩写。具体如下：

## C99标准中```inttypes.h```的内容

```cpp
/*
   inttypes.h: C99标准中inttypes.h的内容

   Contributors:
     Createdby Marek Michalkiewicz <marekm@linux.org.pl>

   THISSOFTWARE IS NOT COPYRIGHTED

   Thissource code is offered for use in the public domain.  You may
   use,modify or distribute it freely.

   Thiscode is distributed in the hope that it will be useful, but
   WITHOUTANY WARRANTY.  ALLWARRANTIES, EXPRESS OR IMPLIED ARE HEREBY
   DISCLAIMED.  This includes but is not limited towarranties of
   MERCHANTABILITYor FITNESS FOR A PARTICULAR PURPOSE.
 */

#ifndef __INTTYPES_H_
#define __INTTYPES_H_

/* Use [u]intN_t if you need exactly N bits.
  XXX- doesn't handle the -mint8 option.  */

typedef signed char int8_t;
typedef unsigned char uint8_t;

typedef int int16_t;
typedef unsigned int uint16_t;
 
typedef long int32_t;
typedef unsigned long uint32_t;

typedef long long int64_t;
typedef unsigned long long uint64_t;

typedef int16_t intptr_t;
typedef uint16_t uintptr_t;
 
#endif
```

## C99标准另一个文件```/usr/include/stdint.h```内如下：

```cpp
/*在C99标准中定义了这些数据类型，
  具体定义在：/usr/include/stdint.h
  参考：https://blog.csdn.net/Mary19920410/article/details/71518130?locationNum=4&fps=1*/
#ifndef __int8_t_defined    
#define __int8_t_defined    
typedef signed char             int8_t;     
typedef short int               int16_t;    
typedef int                     int32_t;    
#   if __WORDSIZE == 64    
typedef long int                int64_t;    
#   else    
__extension__    
typedef long long int           int64_t;    
#   endif    
#endif    
    
typedef unsigned char           uint8_t;    
typedef unsigned short int      uint16_t;    
#ifndef __uint32_t_defined    
typedef unsigned int            uint32_t;    
# define __uint32_t_defined    
#endif    
#if __WORDSIZE == 64    
typedef unsigned long int       uint64_t;    
#else    
__extension__    
typedef unsigned long long int  uint64_t;    
#endif  
```
