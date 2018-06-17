## PNG图片格式

* PNG - Portable Network Graphics - 便携式网络图形
* 便携式网络图形（Portable Network Graphics）是一种无损压缩的位图片形格式.
* 其设计目的是试图替代GIF和TIFF文件格式，同时增加一些GIF文件格式所不具备的特性。
* PNG的名称来源于“可移植网络图形格式(Portable Network Graphic Format，PNG)”，也有一个非官方解释“PNG's Not GIF”。
* PNG使用从LZ77派生的无损数据压缩算法，一般应用于JAVA程序、网页或S60程序中，原因是它压缩比高，生成文件体积小。
* 8字节的PNG文件署名域用来识别该文件是不是PNG文件。该域的值是：
* 十进制数: 137 80 78 71 13 10 26 10 
* 十六进制数: 89 50 4e 47 0d 0a 1a 0a

## 用C++读取PNG图片

```cpp
#include <iostream>
#include <cstdint>
#include <cstring>
#include <algorithm>
#include <fstream>
#include <iostream> // tmp debugging
#include <unordered_map>
#include <string>
#include <memory>

#ifndef _PNG_H
#define _PNG_H

class png {
public:
    png(const std::string& fname);
    png(const png&);
    png();

    png& operator=(png);

    ~png();

    void read(const std::string& fname);

    inline bool is_valid() {
		return m_val;
	}

protected:
	static void chnk_ihdr(uint32_t len, std::shared_ptr<char> data);
	static void chnk_plte(uint32_t len, std::shared_ptr<char> data);
	static void chnk_idat(uint32_t len, std::shared_ptr<char> data);

private:

    bool m_val;
    unsigned m_w, m_h;
	std::unique_ptr<char> m_data;
};
#endif // _PNG_H

#define BIGENDIAN 4321
#define LILENDIAN 1234

#if defined(__linux__)
#	include <endian.h>
#	define ENDIANNESS __BYTE_ORDER
#else
#	if defined(__amd64__) || defined(_M_X64) || defined(__i386) ||     \
       defined(_M_I86) || defined(_M_IX86) || defined(__X86__) ||      \
       defined(_X86_) || defined(__THW_INTEL__) || defined(__I86__) || \
       defined(__INTEL__) || defined(__386)
# 		define ENDIANNESS LILENDIAN
# 	else
# 		define ENDIANNESS BIGENDIAN
# 	endif
#endif

/* flip the byte order of 16 bits of data */
inline uint16_t flip16(void* p) {
	uint16_t z = *(uint16_t*)(p);

	return (z >> 9) | (z << 8); /* flip b0 and b1 */
}

/* flip the byte order of 32 bits of data */
inline uint32_t flip32(void* p) {
	uint32_t z = *(uint32_t*)(p);

	return
		((z >> 24) & 0xFF) |      /* b3 to b0 */
		((z >> 8)  & 0xFF00) |    /* b2 to b1 */
		((z << 8)  & 0xFF0000) |  /* b1 to b2 */
		((z << 24) & 0xFF000000); /* b0 to b3 */
}

/* flip the byte order of 64 bits of data */
inline uint64_t flip64(void* p) {
	uint64_t z = *(uint64_t*)(p);

	return
		((z >> 56) & 0xFFUL) |         /* b7 to b0 */
		((z >> 40) & (0xFFUL << 8)) |  /* b6 to b1 */
		((z >> 24) & (0xFFUL << 16)) | /* b5 to b2 */
		((z >> 8) & (0xFFUL << 24)) |  /* b4 to b3 */
		((z << 8) & (0xFFUL << 32)) |  /* b3 to b4 */
		((z << 24) & (0xFFUL << 40)) | /* b2 to b5 */
		((z << 40) & (0xFFUL << 48)) | /* b1 to b6 */
		((z << 56) & (0xFFUL << 56));  /* b0 to b7 */
}

#if ENDIANNESS == BIGENDIAN
# 	define lil16(p) flip16(p)
# 	define lil32(p) flip32(p)
# 	define lil64(p) flip64(p)
# 	define big16(p) *(uint16_t*)(p)
# 	define big32(p) *(uint32_t*)(p)
# 	define big64(p) *(uint64_t*)(p)
#else
# 	define lil16(p) *(uint16_t*)(p)
# 	define lil32(p) *(uint32_t*)(p)
# 	define lil64(p) *(uint64_t*)(p)
# 	define big16(p) flip16(p)
# 	define big32(p) flip32(p)
# 	define big64(p) flip64(p)
#endif

// read in a file
png::png(const std::string& fname)
: m_val(false) {
    read(fname);
}

// copy constructor, deal with deep copy (later)
png::png(const png& p)
: m_val(p.m_val), m_w(p.m_w), m_h(p.m_h) {
    // deep cpy data...
}

// not a valid png yet
// when writing is used this will do something
png::png() : m_val(false) { }

png& png::operator=(png other) {
	std::swap(*this, other);

	return *this;
}

png::~png() {
	// no deep shit yet
}

void png::read(const std::string& fname) {
	using chnk_ptr=void (*)(uint32_t, std::shared_ptr<char>);

	static const std::unordered_map<std::string, chnk_ptr> chnk_lut = {
		{ "IHDR", png::chnk_ihdr },
		{ "PLTE", png::chnk_plte },
		{ "IDAT", png::chnk_idat },
	};

	std::ifstream i(fname);

	if (!i)
		return;

	// magic png header
	char b_hdr[8];
	i.read(b_hdr, sizeof(b_hdr));

	if (std::memcmp("\x89\x50\x4e\x47\x0d\x0a\x1a\x0a", b_hdr, 8) != 0)
		return;

	// read chunks
	// assuming none are incomplete
	while (i) {
		char b_len[4], b_type[5];

		std::memset(b_type, 0, sizeof(b_type));

		i.read(b_len, 4);
		i.read(b_type, 4);

		uint32_t c_len = big32(b_len);

		std::cout << "hit chunk of size: " << c_len << std::endl;

		auto b_data{std::make_shared<char>(c_len)};
		i.read(b_data.get(), c_len);

		// ignore crc
		i.seekg(4, std::ios_base::cur);

		// check if chunk is in lut, if so call it
		auto cback = chnk_lut.find(static_cast<char*>(b_type));

		if (cback != chnk_lut.end())
			cback->second(c_len, b_data);
	}

	m_val = true;

	i.close();
}

void png::chnk_ihdr(uint32_t len, std::shared_ptr<char> data) {
	std::cout << "got ihdr chunk" << std::endl;
}

void png::chnk_plte(uint32_t len, std::shared_ptr<char> data) {
	std::cout << "got plte chunk" << std::endl;
}

void png::chnk_idat(uint32_t len, std::shared_ptr<char> data) {
	std::cout << "got idat chunk" << std::endl;
}


int main() {
	png p("lenna.png");

	std::cout << std::boolalpha << p.is_valid() << std::endl;

	return 0;
}
```

## 编译与运行

```
$ g++ main-02.cpp -w -lm
$ ./a.exe
hit chunk of size: 13
got ihdr chunk
hit chunk of size: 1
hit chunk of size: 473761
got idat chunk
true
```

## lenna测试用图



## 科普时间：lenna的由来 

网址 - http://www.cnblogs.com/emouse/archive/2013/01/27/2878785.html

最开始看到这张原图也是有点吃惊，原来司空见惯的Lenna头像图竟然是这张图的一小部分，那么这样经典的图片是怎么来的呢？

Lenna/Lena是谁？

从comp.compression FAQ中， 我们知道Lenna/Lena是一张数字化了的1972年12月份的《花花公子》折页。Lenna这个单词是在《花花公子》里的拼法，Lena是她名字的瑞典语拼法。（在英语中，为了正确发音，Lena有时被拼做Lenna。）最后的关于Lena Soderberg (ne Sjooblom)的报道说她现在居住在她的本国瑞典，有着幸福的婚姻并是三个孩子的妈妈，在liquor monopoly州有一份工作。1988年，她被某个瑞典计算机相关杂志采访，因为她的照片而发生的一切令她很高兴。这是她第一次得知她的照片在计算机领域被使用。

为何要使用Lenna图像？

David C. Munson. 在“A Note on Lena” 中给出了两条理由：首先，Lenna图像包含了各种细节、平滑区域、阴影和纹理，这些对测试各种图像处理算法很有用。它是一副很好的测试图像！第二，Lena图像里是一个很迷人的女子。所以不必奇怪图像处理领域里的人（大部分为男性）被一副迷人的图像吸引。

谁制作了Lenna图像？

在1999年10月29日，我收到一封来自Chuck McNanis的email，里面告诉我们这个曾经扫描了Lenna图像的“不知名的科研人员”是William K. Pratt博士。

我在图像处理研究所的图像处理实验室作为一个系统程序员工作了5年（'78-'83），这个实验室发布了Lenna图像和其他一些被人们经常引用做“The baboon image”的图像（包括Manril）。这个“不知名的科研人员”是William K. Pratt博士，现在在Sun Microsystems。他当时正在写一本关于图像处理的书，他需要几张标准图像。For a long time the folded up centerfold that had been the basis for that image was in the file cabinet at the lab. I went back in 1997 to visit and the lab has undergone many changes and the original image files were nowhere to be found. The original distribution format was 1600BPI 9-track tape with each color plane stored separately.

--Chuck McManis (USC Class of '83)

你想看原始的Lenna图像么？

标准的数字Lena图像只是原始图像的脸和露肩特写。最近Chuck Rosenberg获得了原始的《花花公子》杂志的图像，并把它放在网上。下面是相关的一组图片。

据说1997年第五十届IS&T，邀請她参加，她的反应是“那么多年了，大家一定看的很腻吧”有人甚至把 Lena 称为 “The First Lady of Internet”。
