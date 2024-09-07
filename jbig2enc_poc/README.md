### Title
Error heap-use-after-free jbig2enc.cc:505 jbig2_add_page(jbig2ctx*, Pix*) [#88](https://github.com/agl/jbig2enc/issues/88)

### Description
jbig2enc 0.28 was discovered to contain a heap use-after-free vulnerability in src/jbig2enc.cc:505 jbig2_add_page(jbig2ctx*, Pix*). This vulnerability can lead to a Denial of Service (DoS) or possible code execution.

### ASAN Log
./jbig2 -s -S -p -v -O out.png poc.jpg 
```
Processing "poc.jpg"...
source image: 240 x 180 (32 bits) 300dpi x 300dpi, refcount = 1
thresholded image: 240 x 180 (1 bits) 300dpi x 300dpi, refcount = 1
mask image:  240 x 176 (1 bits) 304dpi x 304dpi, refcount = 1
pixel count of graphics image: 18064
pixel count of binary image: 4
binary mask image: 240 x 176 (32 bits) 304dpi x 304dpi, refcount = 1
graphics image: 240 x 180 (32 bits) 300dpi x 300dpi, refcount = 2
segmented binary text image: NULL pointer!
segmented graphics image: 240 x 176 (32 bits) 304dpi x 304dpi, refcount = 1
graphics image: 240 x 176 (32 bits) 304dpi x 304dpi, refcount = 1
=================================================================
==730457==ERROR: AddressSanitizer: heap-use-after-free on address 0x6060000000e0 at pc 0x561042131a80 bp 0x7ffe97f47bb0 sp 0x7ffe97f47ba8
READ of size 4 at 0x6060000000e0 thread T0
    #0 0x561042131a7f in jbig2_add_page(jbig2ctx*, Pix*) /tmp/jbig2enc-0.29/src/jbig2enc.cc:505:33
    #1 0x5610421231cc in main /tmp/jbig2enc-0.29/src/jbig2.cc:472:5
    #2 0x7f089bdf8d8f in __libc_start_call_main csu/../sysdeps/nptl/libc_start_call_main.h:58:16
    #3 0x7f089bdf8e3f in __libc_start_main csu/../csu/libc-start.c:392:3
    #4 0x56104205e784 in _start (/tmp/jbig2enc-0.29/src/jbig2+0x27784) (BuildId: d94779cb495703fa715b355ee5c70c1ef3f7db07)

0x6060000000e0 is located 0 bytes inside of 64-byte region [0x6060000000e0,0x606000000120)
freed by thread T0 here:
    #0 0x5610420e1322 in __interceptor_free (/tmp/jbig2enc-0.29/src/jbig2+0xaa322) (BuildId: d94779cb495703fa715b355ee5c70c1ef3f7db07)
    #1 0x7f089c3b92d2 in pixDestroy (/lib/x86_64-linux-gnu/liblept.so.5+0x1302d2) (BuildId: 191021553afbb5831ac43117146c6409fd91054c)

previously allocated by thread T0 here:
    #0 0x5610420e17b8 in __interceptor_calloc (/tmp/jbig2enc-0.29/src/jbig2+0xaa7b8) (BuildId: d94779cb495703fa715b355ee5c70c1ef3f7db07)
    #1 0x7f089c3b616e in pixCreateHeader (/lib/x86_64-linux-gnu/liblept.so.5+0x12d16e) (BuildId: 191021553afbb5831ac43117146c6409fd91054c)

SUMMARY: AddressSanitizer: heap-use-after-free /tmp/jbig2enc-0.29/src/jbig2enc.cc:505:33 in jbig2_add_page(jbig2ctx*, Pix*)
Shadow bytes around the buggy address:
  0x0c0c7fff7fc0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
  0x0c0c7fff7fd0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
  0x0c0c7fff7fe0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
  0x0c0c7fff7ff0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
  0x0c0c7fff8000: fa fa fa fa fd fd fd fd fd fd fd fd fa fa fa fa
=>0x0c0c7fff8010: fd fd fd fd fd fd fd fd fa fa fa fa[fd]fd fd fd
  0x0c0c7fff8020: fd fd fd fd fa fa fa fa fd fd fd fd fd fd fd fd
  0x0c0c7fff8030: fa fa fa fa fd fd fd fd fd fd fd fd fa fa fa fa
  0x0c0c7fff8040: fd fd fd fd fd fd fd fd fa fa fa fa fd fd fd fd
  0x0c0c7fff8050: fd fd fd fd fa fa fa fa fd fd fd fd fd fd fd fd
  0x0c0c7fff8060: fa fa fa fa fd fd fd fd fd fd fd fd fa fa fa fa
Shadow byte legend (one shadow byte represents 8 application bytes):
  Addressable:           00
  Partially addressable: 01 02 03 04 05 06 07 
  Heap left redzone:       fa
  Freed heap region:       fd
  Stack left redzone:      f1
  Stack mid redzone:       f2
  Stack right redzone:     f3
  Stack after return:      f5
  Stack use after scope:   f8
  Global redzone:          f9
  Global init order:       f6
  Poisoned by user:        f7
  Container overflow:      fc
  Array cookie:            ac
  Intra object redzone:    bb
  ASan internal:           fe
  Left alloca redzone:     ca
  Right alloca redzone:    cb
==730457==ABORTING
```
### Reproduction
```
wget https://github.com/agl/jbig2enc/archive/refs/tags/0.29.zip
unzip 0.29.zip
cd jbig2enc-0.29
sudo apt install libleptonica-dev
./autogen.sh
CFLAGS="-fsanitize=address -fno-omit-frame-pointer -g" CXXFLAGS=" -fsanitize=address -fno-omit-frame-pointer -g" ./configure --disable-shared
make -j24
./src/jbig2 -s -S -p -v -O out.png poc.jpg 
```
### Proof-of-Concept Files

[poc](https://github.com/4n0nym4u5/CVE/tree/main/jbig2enc_poc)

### Environment
```
Linux Mint 21.2 Victoria
clang version 14.0.0-1ubuntu1.1
gcc (Ubuntu 11.4.0-1ubuntu1~22.04) 11.4.0
```

 
