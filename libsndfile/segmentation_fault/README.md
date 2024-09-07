## Title
Segmentation fault error in ogg_vorbis.c:417 vorbis_analysis_wrote() [#1035](https://github.com/libsndfile/libsndfile/issues/1035)

## Description
The latest version of libsndfile was discovered to contain  a memory corruption vulnerability in ogg_vorbis.c:417 vorbis_analysis_wrote() when parsing a specially crafted input file. This vulnerability leads to Denial of Service (DoS). 

## ASAN Log
```c
Summary: CRASH detected in vorbis_analysis_wrote due to a fault at or near 0x0000000000000030 leading to SIGSEGV (si_signo=11) / SEGV_MAPERR (si_code=1)
Command line: ./sndfile-convert @@ /tmp/Master.ogg
Testcase: out/cpu03/crashes/id:000047,sig:11,src:001542,time:8004993,execs:855790,op:quick,pos:84
Crash bucket: 8b83505d9a486363d6fe62258b78fea5

Crashing thread backtrace:
#0  0x00007ffff7df044b in vorbis_analysis_wrote (/lib/x86_64-linux-gnu/libvorbis.so.0)
#1  0x00005555557ce546 in vorbis_close (/home/user/fuzzing_targets/libsndfile/CMakeBuild/sndfile-convert)
                       402: int vorbis_close(psf = (SF_PRIVATE *)0x625000002900) {
                       |||:
                       |||: /* Local reference: SF_PRIVATE * psf = 0x625000002900; */
                       |||: /* Local reference: VORBIS_PRIVATE * vdata = 0x615000000080; */
                       415: 			vorbis_write_header (psf, 0) ;
                       416: 
                       417: 		vorbis_analysis_wrote (&vdata->vdsp, 0) ;
                       |||:
                       ---: }
                       at /home/user/fuzzing_targets/libsndfile/src/ogg_vorbis.c:417

#2  0x00005555556863f4 in psf_close (/home/user/fuzzing_targets/libsndfile/CMakeBuild/sndfile-convert)
                       2964: int psf_close(psf = (SF_PRIVATE *)0x625000002900) {
                       ||||:
                       ||||: /* Local reference: SF_PRIVATE * psf = 0x625000002900; */
                       ||||: /* Local reference: int error = 0; */
                       2967: 
                       2968: 	if (psf->codec_close)
                       2969: 	{	error = psf->codec_close (psf) ;
                       ||||:
                       ----: }
                       at /home/user/fuzzing_targets/libsndfile/src/sndfile.c:2969

#3  0x0000555555683219 in main (/home/user/fuzzing_targets/libsndfile/CMakeBuild/sndfile-convert)
                       134: int main(argc = (int)<optimized out>, argv = (char **)<optimized out>) {
                       |||:
                       |||: /* Local reference: SNDFILE * infile = 0x625000000100; */
                       |||: /* Local reference: SNDFILE * outfile = 0x625000002900; */
                       368: 
                       369: 	sf_close (infile) ;
                       370: 	sf_close (outfile) ;
                       |||:
                       ---: }
                       at /home/user/fuzzing_targets/libsndfile/programs/sndfile-convert.c:370

Crash context:
/* Register reference: r14 - 0x0000625000000100 (108095736905984) */
/* Register reference: r13 - 0x0000000000000000 (0) */
Execution stopped here ==> 0x00007ffff7df044b: mov    r14,QWORD PTR [r13+0x30]

Register info:
    rax - 0x0000000000000000 (0)
    rbx - 0x00006150000000e0 (106996225278176)
    rcx - 0x0000555556259180 (93825005883776)
    rdx - 0x0000000000000002 (2)
    rsi - 0x0000000000000000 (0)
    rdi - 0x00006150000000e0 (106996225278176)
    rbp - 0x00007fffffff5af0 (0x7fffffff5af0)
    rsp - 0x00007fffffff5ab0 (0x7fffffff5ab0)
     r8 - 0x0000000000001698 (5784)
     r9 - 0x00007ffff5c00b60 (140737316391776)
    r10 - 0x00007ffff7de5548 (140737351931208)
    r11 - 0x00007ffff7df0420 (140737351975968)
    r12 - 0x0000627000000100 (108233175859456)
    r13 - 0x0000000000000000 (0)
    r14 - 0x0000625000000100 (108095736905984)
    r15 - 0x0000625000002900 (108095736916224)
    rip - 0x00007ffff7df044b (0x7ffff7df044b <vorbis_analysis_wrote+43>)
 eflags - 0x00010246 ([ PF ZF IF RF ])
     cs - 0x00000033 (51)
     ss - 0x0000002b (43)
     ds - 0x00000000 (0)
     es - 0x00000000 (0)
     fs - 0x00000000 (0)
     gs - 0x00000000 (0)
fs_base - 0x00007ffff79fd800 (140737347835904)
gs_base - 0x0000000000000000 (0)
```
## sndfile-info
```yaml
File : /REDACTED/poc
Length : 284
RF64 : 0x45564157 (should be 0xFFFFFFFF)
  W
fmt  : 50
  Format        : 0x1 => WAVE_FORMAT_PCM
  Channels      : 1
  Sample Rate   : 11025
  Block Align   : 256
  Bit Width     : 4
  Bytes/sec     : 5645 (should be 2822400)
fmt  : 50
  Format        : 0x1 => WAVE_FORMAT_PCM
  Channels      : 1
  Sample Rate   : 11938577
  Block Align   : 256
  Bit Width     : 28
  Bytes/sec     : 5645 (should be -1238691584)
*** fact : 4 (unknown marker)
data : 0x1700
**** Weird, RF64 file without a 'ds64' chunk and no valid 'data' size.
End
*** Calculated frame count 34 does not match value from 'ds64' chunk of 0.

----------------------------------------
Sample Rate : 11938577
Frames      : 34
Channels    : 1
Format      : 0x00220004
Sections    : 1
Seekable    : TRUE
Duration    : 00:00:00.000
Signal Max  : 9.89862e+08 (-6.73 dB)
```

## Proof-of-Concept Files
[poc](https://github.com/4n0nym4u5/CVE/raw/main/libsndfile/segmentation_fault/poc)


## Reproduction
```sh
git clone https://github.com/libsndfile/libsndfile
mkdir CMakeBuild
cd CMakeBuild
CC=clang CXX=clang++  cmake .. 
make
./sndfile-convert poc a.ogg
```

## Results
```sh
➜  CMakeBuild git:(master) ✗ ./sndfile-convert poc /tmp/a.ogg                                                                                    
AddressSanitizer:DEADLYSIGNAL
=================================================================
==1208976==ERROR: AddressSanitizer: SEGV on unknown address 0x000000000030 (pc 0x7ffff7ded44b bp 0x7fffffff5d10 sp 0x7fffffff5cd0 T0)
==1208976==The signal is caused by a READ memory access.
==1208976==Hint: address points to the zero page.
    #0 0x7ffff7ded44b in vorbis_analysis_wrote (/lib/x86_64-linux-gnu/libvorbis.so.0+0xc44b) (BuildId: 58a44b2feaebf749cc199712b9da8b0a72529304)
    #1 0x5555557ce545 in vorbis_close /home/user/fuzzing_targets/libsndfile/src/ogg_vorbis.c:417:3
    #2 0x5555556863f3 in psf_close /home/user/fuzzing_targets/libsndfile/src/sndfile.c:2969:12
    #3 0x555555683218 in main /home/user/fuzzing_targets/libsndfile/programs/sndfile-convert.c:370:2
    #4 0x7ffff7a2a1c9 in __libc_start_call_main csu/../sysdeps/nptl/libc_start_call_main.h:58:16
    #5 0x7ffff7a2a28a in __libc_start_main csu/../csu/libc-start.c:360:3
    #6 0x5555555c1e84 in _start (/home/user/fuzzing_targets/libsndfile/CMakeBuild/sndfile-convert+0x6de84) (BuildId: cbada87c9425ff09ce9f7616c3a774b7f2e3be61)

AddressSanitizer can not provide additional info.
SUMMARY: AddressSanitizer: SEGV (/lib/x86_64-linux-gnu/libvorbis.so.0+0xc44b) (BuildId: 58a44b2feaebf749cc199712b9da8b0a72529304) in vorbis_analysis_wrote
==1208976==ABORTING

```

## Environment
```
Linux Mint 22 Wilma 
Ubuntu clang version 18.1.3 (1ubuntu1)
gcc (Ubuntu 13.2.0-23ubuntu4) 13.2.0
```
