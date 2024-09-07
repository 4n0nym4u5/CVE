## Title
Reachable assertion in mpeg_l3_encoder_close [#1034](https://github.com/libsndfile/libsndfile/issues/1034)

## Description
The latest version of libsndfile was discovered to contain a reachable assertion vulnerability in mpeg_l3_encode.c:304 mpeg_l3_encoder_close() when parsing a specially crafted input file. This vulnerability can lead to Denial of Service (DoS). 

## ASAN Log
```c
Summary: CRASH detected in __pthread_kill_implementation leading to SIGABRT (si_signo=6) / SI_TKILL (si_code=-6)
Command line: ./sndfile-convert poc.riff /tmp/Master.mp3
Testcase: poc.riff
Crash bucket: a6b209ab91ad396a9d712126e13a30ac

Crashing thread backtrace:
#0  0x00007ffff7a9eb1c in __pthread_kill_implementation (/lib/x86_64-linux-gnu/libc.so.6)
                       at ./nptl/pthread_kill.c:44

#1  0x00007ffff7a9eb1c in __pthread_kill_internal (/lib/x86_64-linux-gnu/libc.so.6)
                       at ./nptl/pthread_kill.c:78

#2  0x00007ffff7a9eb1c in __GI___pthread_kill (/lib/x86_64-linux-gnu/libc.so.6)
                       at ./nptl/pthread_kill.c:89

#3  0x00007ffff7a4526e in __GI_raise (/lib/x86_64-linux-gnu/libc.so.6)
                       at ../sysdeps/posix/raise.c:26

#4  0x00007ffff7a288ff in __GI_abort (/lib/x86_64-linux-gnu/libc.so.6)
                       at ./stdlib/abort.c:79

#5  0x00007ffff7a2881b in __assert_fail_base (/lib/x86_64-linux-gnu/libc.so.6)
                       at ./assert/assert.c:94

#6  0x00007ffff7a3b507 in __assert_fail (/lib/x86_64-linux-gnu/libc.so.6)
                       at ./assert/assert.c:103

#7  0x00007ffff7c5c4b1 in /lib/x86_64-linux-gnu/libmp3lame.so.0
#8  0x00007ffff7c50310 in /lib/x86_64-linux-gnu/libmp3lame.so.0
#9  0x00007ffff7c579cc in /lib/x86_64-linux-gnu/libmp3lame.so.0
#10 0x00007ffff7c59329 in lame_encode_buffer_ieee_double (/lib/x86_64-linux-gnu/libmp3lame.so.0)
#11 0x00005555556287ee in mpeg_l3_encode_write_double_mono (/dev/shm/afl-ramdisk/libsndfile/CMakeBuild/sndfile-convert)
                       694: sf_count_t mpeg_l3_encode_write_double_mono(psf = (SF_PRIVATE *)0x555555870660, ptr = (const double *)0x55555585f7d0 <sfe_copy_data_fp[data]>, len = (sf_count_t)669) {
                       |||:
                       |||: /* Local reference: BUF_UNION ubuf = {dbuf = {4.9888351858755148e-315, 0 <repeats 27 times>, 3.9420429260675648e-56, 8.4615738062968232e-39, 1.1025255896528373e-24, 2.5290907899719777e-10, 5.0872202022209862e-315, 0 <rep... */
                       |||: /* Local reference: sf_count_t total = 576; */
                       |||: /* Local reference: int writecount = 576; */
                       |||: /* Local reference: const double * ptr = 0x55555585f7d0 <sfe_copy_data_fp[data]>; */
                       |||: /* Local reference: int nbytes = <optimized out>; */
                       |||: /* Local reference: MPEG_L3_ENC_PRIVATE * pmpeg = 0x555555872750; */
                       710: 		{	/* Lame lacks non-normalized double writing */
                       711: 			normalize_double (ubuf.dbuf, ptr + total, writecount, 1.0 / (double) 0x8000) ;
                       712: 			nbytes = lame_encode_buffer_ieee_double (pmpeg->lamef, ubuf.dbuf, NULL, writecount, pmpeg->block, pmpeg->block_len) ;
                       |||:
                       ---: }
                       at /home/user/fuzzing_targets/libsndfile/src/mpeg_l3_encode.c:712

#12 0x00005555555aece3 in sf_writef_double (/dev/shm/afl-ramdisk/libsndfile/CMakeBuild/sndfile-convert)
                       2632: sf_count_t sf_writef_double(sndfile = (SNDFILE *)0x555555870660, ptr = (const double *)<optimized out>, frames = (sf_count_t)1245) {
                       ||||:
                       ||||: /* Local reference: SF_PRIVATE * psf = 0x555555870660; */
                       ||||: /* Local reference: sf_count_t count = <optimized out>; */
                       ||||: /* Local reference: const double * ptr = <optimized out>; */
                       ||||: /* Local reference: sf_count_t frames = 1245; */
                       2664: 	psf->have_written = SF_TRUE ;
                       2665: 
                       2666: 	count = psf->write_double (psf, ptr, frames * psf->sf.channels) ;
                       ||||:
                       ----: }
                       at /home/user/fuzzing_targets/libsndfile/src/sndfile.c:2666

#13 0x0000555555584959 in sfe_copy_data_fp (/dev/shm/afl-ramdisk/libsndfile/CMakeBuild/sndfile-convert)
                       ??: int sfe_copy_data_fp(outfile = (SNDFILE *)0x555555870660, infile = (SNDFILE *)0x55555586e2a0, normalize = (int)0, channels = (int)<optimized out>) {
                       ||:
                       ||: /* Local reference: sf_count_t readcount = 1245; */
                       ||: /* Local reference: sf_count_t frames = 4096; */
                       ||: /* Local reference: SNDFILE * infile = 0x55555586e2a0; */
                       ||: /* Local reference: SNDFILE * outfile = 0x555555870660; */
                       62: 	{	while (readcount > 0)
                       63: 		{	readcount = sf_readf_double (infile, data, frames) ;
                       64: 			sf_writef_double (outfile, data, readcount) ;
                       ||:
                       --: }
                       at /home/user/fuzzing_targets/libsndfile/programs/common.c:64

#14 0x0000555555584959 in main (/dev/shm/afl-ramdisk/libsndfile/CMakeBuild/sndfile-convert)
                       134: int main(argc = (int)<optimized out>, argv = (char **)<optimized out>) {
                       |||:
                       |||: /* Local reference: int infileminor = 7; */
                       |||: /* Local reference: int outfileminor = <optimized out>; */
                       |||: /* Local reference: SNDFILE * outfile = 0x555555870660; */
                       |||: /* Local reference: SNDFILE * infile = 0x55555586e2a0; */
                       |||: /* Local reference: SF_INFO sfinfo = {frames = 0, samplerate = 8000, channels = 1, format = 2293890, sections = 0, seekable = 0}; */
                       |||: /* Local reference: int normalize = <optimized out>; */
                       359: 			|| (infileminor == SF_FORMAT_MPEG_LAYER_II)
                       360: 			|| (infileminor == SF_FORMAT_MPEG_LAYER_III) || (outfileminor == SF_FORMAT_MPEG_LAYER_III))
                       361: 	{	if (sfe_copy_data_fp (outfile, infile, sfinfo.channels, normalize) != 0)
                       |||:
                       ---: }
                       at /home/user/fuzzing_targets/libsndfile/programs/sndfile-convert.c:361

Crash context:
Execution stopped here ==> 0x00007ffff7a9eb1c: mov    r14d,eax

Register info:
    rax - 0x0000000000000000 (0)
    rbx - 0x00000000003c6c3c (3959868)
    rcx - 0x00007ffff7a9eb1c (140737348496156)
    rdx - 0x0000000000000006 (6)
    rsi - 0x00000000003c6c3c (3959868)
    rdi - 0x00000000003c6c3c (3959868)
    rbp - 0x00007ffffffe8050 (0x7ffffffe8050)
    rsp - 0x00007ffffffe8010 (0x7ffffffe8010)
     r8 - 0x000055555586e010 (93824995483664)
     r9 - 0x0000000000000007 (7)
    r10 - 0x0000000000000008 (8)
    r11 - 0x0000000000000246 (582)
    r12 - 0x0000000000000006 (6)
    r13 - 0x00007ffff7c7a7e9 (140737350445033)
    r14 - 0x0000000000000016 (22)
    r15 - 0x00007ffff7c7abec (140737350446060)
    rip - 0x00007ffff7a9eb1c (0x7ffff7a9eb1c <__GI___pthread_kill+284>)
 eflags - 0x00000246 ([ PF ZF IF ])
     cs - 0x00000033 (51)
     ss - 0x0000002b (43)
     ds - 0x00000000 (0)
     es - 0x00000000 (0)
     fs - 0x00000000 (0)
     gs - 0x00000000 (0)
fs_base - 0x00007ffff7c421c0 (140737350214080)
gs_base - 0x0000000000000000 (0)
```

## sndfile-info
```yaml
File : /REDACTED/poc
Length : 549
RIFF : 44140 (should be 541)
WAVE
fmt  : 16
  Format        : 0x3 => WAVE_FORMAT_IEEE_FLOAT
  Channels      : 2
  Sample Rate   : 44100
  Block Align   : 8
  Bit Width     : 64
  Bytes/sec     : 352800
data : 16
*** Unknown chunk marker (41570000) at position 60. Exiting parser.
*** Chunk size 1835418966 > file length 549. Exiting parser.
**** All non-PCM format files should have a 'fact' chunk.

----------------------------------------
Sample Rate : 44100
Frames      : 1
Channels    : 2
Format      : 0x00010007
Sections    : 1
Seekable    : TRUE
Duration    : 00:00:00.000
Signal Max  : 2.43528e-196 (-3912.27 dB)
```
## Proof-of-Concept Files
[poc](https://github.com/4n0nym4u5/CVE/raw/main/libsndfile/reachable_assertion/poc)

## Reproduction
```bash
git clone https://github.com/libsndfile/libsndfile
mkdir CMakeBuild
cd CMakeBuild
CC=clang CXX=clang++  cmake .. 
make
./sndfile-convert poc.riff a.mp3
```

## Results
```bash
➜  CMakeBuild git:(master) ./sndfile-convert poc.riff a.mp3
sndfile-convert: psymodel.c:576: calc_energy: Assertion `el >= 0' failed.
[1]    1915847 IOT instruction  ./sndfile-convert poc.riff a.mp3
```

## Environment
```
Linux Mint 22 Wilma 
Ubuntu clang version 18.1.3 (1ubuntu1)
gcc (Ubuntu 13.2.0-23ubuntu4) 13.2.0
```
