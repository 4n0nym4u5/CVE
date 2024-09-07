## Title

Segmentation fault error in grid.cc:486 in get_luma_bits_per_pixel() [#1284](https://github.com/strukturag/libheif/issues/1284)

## Description

libheif version: 1.18.2 was discovered to contain a memory corruption vulnerability in libheif/codecs/grid.cc:486 get_luma_bits_per_pixel(). This vulnerability can lead to Denial of Service (DoS) or possible code execution.

## ASAN Log

heif-convert poc.heic

```
Summary: CRASH detected in 0x00000bd000000031 due to a fault at or near 0x00000bd000000031 leading to SIGSEGV (si_signo=11) / SEGV_MAPERR (si_code=1)
Command line: /usr/local/bin/heif-convert @@
Testcase: crashes/id:000001,sig:11,src:000033+000152,time:2534890,execs:130836,op:splice,rep:14
Crash bucket: e543378b6b8e562ee91379d81e8b1134

Crashing thread backtrace:
#0  0x00000bd000000031 in ??
#1  0x00007ffff7da033e in ImageItem_Grid::get_luma_bits_per_pixel (r-xp   /usr/local/lib/libheif.so.1.18.2)
                       477: int ImageItem_Grid::get_luma_bits_per_pixel(this = (const ImageItem_Grid *)<optimized out>) {
                       |||:
                       |||: /* Local reference: std::shared_ptr<ImageItem const> image = std::shared_ptr<const ImageItem> (use count 50, weak count -1) = {get() = 0x55555579a180}; */
                       |||: /* Local reference: heif_item_id child = <optimized out>; */
                       484: 
                       485:   auto image = get_context()->get_image(child);
                       486:   return image->get_luma_bits_per_pixel();
                       |||:
                       ---: }
                       at /dev/shm/afl-ramdisk/libheif/libheif/codecs/grid.cc:486

#2  0x00005555555642b5 in main (/usr/local/bin/heif-dec)
                       231: int main(argc = (int)<optimized out>, argv = (char **)<optimized out>) {
                       |||:
                       |||: /* Local reference: int bit_depth = <optimized out>; */
                       |||: /* Local reference: heif_image_handle * handle = 0x55555579a180; */
                       501:     }
                       502: 
                       503:     int bit_depth = heif_image_handle_get_luma_bits_per_pixel(handle);
                       |||:
                       ---: }
                       at /dev/shm/afl-ramdisk/libheif/examples/heif_dec.cc:503

Register info:
    rax - 0x00005555557a62f0 (93824994665200)
    rbx - 0x0000000000000009 (9)
    rcx - 0x0000000000001401 (5121)
    rdx - 0x0000000000000000 (0)
    rsi - 0x0000555555571220 (93824992350752)
    rdi - 0x000055555579a180 (93824994615680)
    rbp - 0x00005555557a6788 (0x5555557a6788)
    rsp - 0x00007fffffffd678 (0x7fffffffd678)
     r8 - 0x0000555555772010 (93824994451472)
     r9 - 0x0000000000000007 (7)
    r10 - 0x00005555557a67b0 (93824994666416)
    r11 - 0x43d26187db10823a (4887075781774180922)
    r12 - 0x00007fffffffd7a0 (140737488344992)
    r13 - 0x00007fffffffd828 (140737488345128)
    r14 - 0x000055555579a1a0 (93824994615712)
    r15 - 0x000055555556fca0 (93824992345248)
    rip - 0x00000bd000000031 (0xbd000000031)
 eflags - 0x00010202 ([ IF RF ])
     cs - 0x00000033 (51)
     ss - 0x0000002b (43)
     ds - 0x00000000 (0)
     es - 0x00000000 (0)
     fs - 0x00000000 (0)
     gs - 0x00000000 (0)
fs_base - 0x00007ffff7e727c0 (140737352509376)
gs_base - 0x0000000000000000 (0)
```

## Reproduction

```
git clone https://github.com/strukturag/libheif
mkdir build
cd build
cmake --preset=release ..
make && sudo make install
heif-convert poc.heic
```

## Proof-of-Concept Files

[poc.heic](https://github.com/4n0nym4u5/CVE/blob/main/libheif_poc/poc.heic)

## Environment

```
Linux Mint 22 Wilma 
Ubuntu clang version 18.1.3 (1ubuntu1)
gcc (Ubuntu 13.2.0-23ubuntu4) 13.2.0
```

## GDB Crash Output

```
LEGEND: STACK | HEAP | CODE | DATA | WX | RODATA
────────────────────────────────────────────────────[ REGISTERS / show-flags off / show-compact-regs off ]─────────────────────────────────────────────────────
*RAX  0x5555557a6310 —▸ 0x7ffff7e3d990 (vtable for ImageItem_Grid+16) —▸ 0x7ffff7da0090 (ImageItem_Grid::~ImageItem_Grid()) ◂— push rbx
 RBX  9
 RCX  0x8101
 RDX  0
 RDI  0x55555579a9a0 —▸ 0x5555557a6310 —▸ 0x7ffff7e3d990 (vtable for ImageItem_Grid+16) —▸ 0x7ffff7da0090 (ImageItem_Grid::~ImageItem_Grid()) ◂— push rbx
 RSI  0x555555571220 (__afl_area_initial) ◂— 0
 R8   0x555555772010 ◂— 0x1000000020001
 R9   7
 R10  0x5555557a67d0 ◂— 0x5555557a6
 R11  0x99747ffdfd978397
 R12  0x7fffffffd820 ◂— 0x2e /* '.' */
 R13  0x7fffffffd8a8 ◂— 0x4f /* 'O' */
 R14  0x55555579a9b0 —▸ 0x5555557a6590 —▸ 0x7ffff7e3ce48 (vtable for ImageItem_HEVC+16) —▸ 0x7ffff7d4d1f0 (ImageItem::~ImageItem()) ◂— push rbp
 R15  0x55555556fca0 (__afl_area_ptr) —▸ 0x555555571220 (__afl_area_initial) ◂— 0
 RBP  0x5555557a67a8 ◂— 0
 RSP  0x7fffffffd700 ◂— 1
*RIP  0x7ffff7da033b (ImageItem_Grid::get_luma_bits_per_pixel() const+411) ◂— call qword ptr [rax + 0x38]
─────────────────────────────────────────────────────────────[ DISASM / x86-64 / set emulate on ]──────────────────────────────────────────────────────────────
   0x7ffff7da02cd <ImageItem_Grid::get_luma_bits_per_pixel() const+301>    adc    cl, 0
   0x7ffff7da02d0 <ImageItem_Grid::get_luma_bits_per_pixel() const+304>    mov    byte ptr [rax + 0x7145], cl     [__afl_area_initial+28997] => 1
   0x7ffff7da02d6 <ImageItem_Grid::get_luma_bits_per_pixel() const+310>    add    dword ptr [r14 + 8], 1          [0x55555579a9b8] => 0x557a6581 (0x557a6580 + 0x1)
   0x7ffff7da02db <ImageItem_Grid::get_luma_bits_per_pixel() const+315>    jmp    ImageItem_Grid::get_luma_bits_per_pixel() const+408 <ImageItem_Grid::get_luma_bits_per_pixel() const+408>
    ↓
   0x7ffff7da0338 <ImageItem_Grid::get_luma_bits_per_pixel() const+408>    mov    rax, qword ptr [rdi]            RAX, [0x55555579a9a0] => 0x5555557a6310 —▸ 0x7ffff7e3d990 (vtable for ImageItem_Grid+16) ◂— 0x7ffff7da0090
 ► 0x7ffff7da033b <ImageItem_Grid::get_luma_bits_per_pixel() const+411>    call   qword ptr [rax + 0x38]      <0xbd000000031>
 
   0x7ffff7da033e <ImageItem_Grid::get_luma_bits_per_pixel() const+414>    mov    ebp, eax
   0x7ffff7da0340 <ImageItem_Grid::get_luma_bits_per_pixel() const+416>    test   r14, r14
   0x7ffff7da0343 <ImageItem_Grid::get_luma_bits_per_pixel() const+419>    je     ImageItem_Grid::get_luma_bits_per_pixel() const+492 <ImageItem_Grid::get_luma_bits_per_pixel() const+492>
 
   0x7ffff7da0345 <ImageItem_Grid::get_luma_bits_per_pixel() const+421>    mov    rax, qword ptr [r14 + 8]
   0x7ffff7da0349 <ImageItem_Grid::get_luma_bits_per_pixel() const+425>    movabs rcx, 0x100000001             RCX => 0x100000001
───────────────────────────────────────────────────────────────────────[ SOURCE (CODE) ]───────────────────────────────────────────────────────────────────────
In file: /dev/shm/afl-ramdisk/libheif/libheif/codecs/grid.cc:486
   481   if (err) {
   482     return -1;
   483   }
   484 
   485   auto image = get_context()->get_image(child);
 ► 486   return image->get_luma_bits_per_pixel();
   487 }
   488 
   489 
   490 int ImageItem_Grid::get_chroma_bits_per_pixel() const
   491 {
───────────────────────────────────────────────────────────────────────────[ STACK ]───────────────────────────────────────────────────────────────────────────
00:0000│ rsp 0x7fffffffd700 ◂— 1
01:0008│     0x7fffffffd708 ◂— 0x810155785370
02:0010│     0x7fffffffd710 ◂— 0
03:0018│     0x7fffffffd718 —▸ 0x7fffffffd728 ◂— 0
04:0020│     0x7fffffffd720 ◂— 0
... ↓        2 skipped
07:0038│     0x7fffffffd738 —▸ 0x555555785370 ◂— 0x5550002c0005
─────────────────────────────────────────────────────────────────────────[ BACKTRACE ]─────────────────────────────────────────────────────────────────────────
 ► 0   0x7ffff7da033b ImageItem_Grid::get_luma_bits_per_pixel() const+411
   1   0x5555555642b5 main+11397
   2   0x7ffff742a1ca __libc_start_call_main+122
   3   0x7ffff742a28b __libc_start_main+139
   4   0x55555555d665 _start+37
───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
pwndbg> 
```
