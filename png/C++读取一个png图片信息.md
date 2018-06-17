
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
