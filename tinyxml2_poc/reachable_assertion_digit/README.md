## Title
Reachable assertion 'digit == 0 || mult <= UINT_MAX / digit' failed in tinyxml2::XMLUtil::GetCharacterRef [#997](https://github.com/leethomason/tinyxml2/issues/997)

## Description
The latest version of tinyxml2 was discovered to contain a reachable assertion `digit == 0 || mult <= UINT_MAX / digit failed` vulnerability in tinyxml2.cpp:545 tinyxml2::XMLUtil::GetCharacterRef() when parsing a specially crafted XML file. This vulnerability leads to a Denial of Service (DoS). 

## ASAN Log
```c
Summary: CRASH detected in __pthread_kill_implementation leading to SIGABRT (si_signo=6) / SI_TKILL (si_code=-6)
Command line: ./build/xmltest @@
Testcase: crashes/id:000016,sig:06,src:000252,time:303091,execs:1126236,op:MOpt_havoc,rep:4
Crash bucket: 32110997dc013b116690743bf4d34b7b

Crashing thread backtrace:
#0  0x00007ffff789eb1c in __pthread_kill_implementation (/lib/x86_64-linux-gnu/libc.so.6)
                       at ./nptl/pthread_kill.c:44

#1  0x00007ffff789eb1c in __pthread_kill_internal (/lib/x86_64-linux-gnu/libc.so.6)
                       at ./nptl/pthread_kill.c:78

#2  0x00007ffff789eb1c in __GI___pthread_kill (/lib/x86_64-linux-gnu/libc.so.6)
                       at ./nptl/pthread_kill.c:89

#3  0x00007ffff784526e in __GI_raise (/lib/x86_64-linux-gnu/libc.so.6)
                       at ../sysdeps/posix/raise.c:26

#4  0x00007ffff78288ff in __GI_abort (/lib/x86_64-linux-gnu/libc.so.6)
                       at ./stdlib/abort.c:79

#5  0x00007ffff782881b in __assert_fail_base (/lib/x86_64-linux-gnu/libc.so.6)
                       at ./assert/assert.c:94

#6  0x00007ffff783b507 in __assert_fail (/lib/x86_64-linux-gnu/libc.so.6)
                       at ./assert/assert.c:103

#7  0x00007ffff7f99886 in tinyxml2::XMLUtil::GetCharacterRef (/home/user/fuzzing_targets/tinyxml2/build/libtinyxml2.so.10)
                       470: const tinyxml2::XMLUtil::GetCharacterRef(p = (const char *)0x55555579e8ed "&#01%E>0</m:mi> \301\336\322\32200000000006000000001;E>0</m:mi> \301\336\322\32200000&#x1;000000000&#1;", '0' <repeats 13 times>, "\317yle scriptlev=l=\00400", value = (char *)0x7ffffffe01aa "", length = (int *)0x7ffffffe01a4) {
                       |||:
                       |||: /* Local reference: const unsigned int digit = 6; */
                       |||: /* Local reference: const char * q = 0x55555579e90b "6000000001;E>0</m:mi> \301\336\322\32200000&#x1;000000000&#1;", '0' <repeats 13 times>, "\317yle scriptlev=l=\00400"; */
                       |||: /* Local reference: unsigned int mult = 1000000000; */
                       543:                     const unsigned int digit = *q - '0';
                       544:                     TIXMLASSERT( digit < 10 );
                       545:                     TIXMLASSERT( digit == 0 || mult <= UINT_MAX / digit );
                       |||:
                       ---: }
                       at ../tinyxml2.cpp:545

#8  0x00007ffff7f98878 in tinyxml2::StrPair::GetStr (/home/user/fuzzing_targets/tinyxml2/build/libtinyxml2.so.10)
                       281: const tinyxml2::StrPair::GetStr(this = (class tinyxml2::StrPair *)0x55555579fa40) {
                       |||:
                       |||: /* Local reference: char [10] buf = "\000\000\000\000\000\000\000\000\000"; */
                       |||: /* Local reference: const int buflen = 10; */
                       |||: /* Local reference: int len = 0; */
                       |||: /* Local reference: const char * adjusted = 0x7ffff7f9aeeb <tinyxml2::XMLUtil::StringEqual(char const*, char const*, int)+443> "\203", <incomplete sequence \370>; */
                       |||: /* Local reference: const char * p = 0x55555579e8ed "&#01%E>0</m:mi> \301\336\322\32200000000006000000001;E>0</m:mi> \301\336\322\32200000&#x1;000000000&#1;", '0' <repeats 13 times>, "\317yle scriptlev=l=\00400"; */
                       325:                         char buf[buflen] = { 0 };
                       326:                         int len = 0;
                       327:                         const char* adjusted = const_cast<char*>( XMLUtil::GetCharacterRef( p, buf, &len ) );
                       |||:
                       ---: }
                       at ../tinyxml2.cpp:327

#9  0x00007ffff7fa1fb9 in tinyxml2::XMLAttribute::Value (/home/user/fuzzing_targets/tinyxml2/build/libtinyxml2.so.10)
                       1445: const tinyxml2::XMLAttribute::Value(this = (const class tinyxml2::XMLAttribute *)0x55555579fa20) {
                       1446: {
                       1447:     return _value.GetStr();
                       ||||:
                       ----: }
                       at ../tinyxml2.cpp:1447

#10 0x00007ffff7fa3331 in tinyxml2::XMLElement::Attribute (/home/user/fuzzing_targets/tinyxml2/build/libtinyxml2.so.10)
                       1635: const tinyxml2::XMLElement::Attribute(this = (const class tinyxml2::XMLElement *)0x55555579ea70, name = (const char *)0x55555579e95e "style", value = (const char *)0x0) {
                       ||||:
                       ||||: /* Local reference: const class tinyxml2::XMLAttribute * a = 0x55555579fa20; */
                       ||||: /* Local reference: const char * value = 0x0; */
                       1640:     }
                       1641:     if ( !value || XMLUtil::StringEqual( a->Value(), value )) {
                       1642:         return a->Value();
                       ||||:
                       ----: }
                       at ../tinyxml2.cpp:1642

#11 0x00007ffff7fa5ba8 in tinyxml2::XMLElement::ParseAttributes (/home/user/fuzzing_targets/tinyxml2/build/libtinyxml2.so.10)
                       1967: char tinyxml2::XMLElement::ParseAttributes(this = (class tinyxml2::XMLElement *)0x55555579ea70, p = (char *)0x55555579e975 "", curLineNumPtr = (int *)0x55555579d350) {
                       ||||:
                       ||||: /* Local reference: class tinyxml2::XMLAttribute * attrib = 0x55555579fa70; */
                       ||||: /* Local reference: char * p = 0x55555579e975 ""; */
                       ||||: /* Local reference: int * curLineNumPtr = 0x55555579d350; */
                       1986: 
                       1987:             p = attrib->ParseDeep( p, _document->ProcessEntities(), curLineNumPtr );
                       1988:             if ( !p || Attribute( attrib->Name() ) ) {
                       ||||:
                       ----: }
                       at ../tinyxml2.cpp:1988

#12 0x00007ffff7fa6973 in tinyxml2::XMLElement::ParseDeep (/home/user/fuzzing_targets/tinyxml2/build/libtinyxml2.so.10)
                       2083: char tinyxml2::XMLElement::ParseDeep(this = (class tinyxml2::XMLElement *)0x55555579ea70, p = (char *)0x55555579e8db " style", parentEndTag = (class tinyxml2::StrPair *)0x7ffffffe0400, curLineNumPtr = (int *)0x55555579d350) {
                       ||||:
                       ||||: /* Local reference: char * p = 0x55555579e8db " style"; */
                       ||||: /* Local reference: int * curLineNumPtr = 0x55555579d350; */
                       2099:     }
                       2100: 
                       2101:     p = ParseAttributes( p, curLineNumPtr );
                       ||||:
                       ----: }
                       at ../tinyxml2.cpp:2101

#13 0x00007ffff7f9ebb2 in tinyxml2::XMLNode::ParseDeep (/home/user/fuzzing_targets/tinyxml2/build/libtinyxml2.so.10)
                       1080: char tinyxml2::XMLNode::ParseDeep(this = (class tinyxml2::XMLNode *)0x55555579e9f8, p = (char *)0x55555579e8d7 "m:mi style", parentEndTag = (class tinyxml2::StrPair *)0x7ffffffe05c0, curLineNumPtr = (int *)0x55555579d350) {
                       ||||:
                       ||||: /* Local reference: class tinyxml2::StrPair endTag = {_flags = 0, _start = 0x0, _end = 0x0}; */
                       ||||: /* Local reference: class tinyxml2::XMLNode * node = 0x55555579ea70; */
                       ||||: /* Local reference: char * p = 0x55555579e8d7 "m:mi style"; */
                       ||||: /* Local reference: int * curLineNumPtr = 0x55555579d350; */
                       1115: 
                       1116:         StrPair endTag;
                       1117:         p = node->ParseDeep( p, &endTag, curLineNumPtr );
                       ||||:
                       ----: }
                       at ../tinyxml2.cpp:1117

#14 0x00007ffff7fa6a89 in tinyxml2::XMLElement::ParseDeep (/home/user/fuzzing_targets/tinyxml2/build/libtinyxml2.so.10)
                       2083: char tinyxml2::XMLElement::ParseDeep(this = (class tinyxml2::XMLElement *)0x55555579e9f8, p = (char *)0x55555579e844 "\n<!--00\3170000-", '0' <repeats 11 times>, "M", '0' <repeats 17 times>, "U\322>\n<p><mIET:math><m:mstyle sel=\"0\"scmi></m:mst", '\r' <repeats 12 times>, "00000000\377d=\"\"><xht:del t=\"\"><xht:h0 r=000--> <m:mi style", parentEndTag = (class tinyxml2::StrPair *)0x7ffffffe05c0, curLineNumPtr = (int *)0x55555579d350) {
                       ||||:
                       ||||: /* Local reference: char * p = 0x55555579e844 "\n<!--00\3170000-", '0' <repeats 11 times>, "M", '0' <repeats 17 times>, "U\322>\n<p><mIET:math><m:mstyle sel=\"0\"scmi></m:mst", '\r' <repeats 12 times>, "00000000\377d=\"\... */
                       ||||: /* Local reference: class tinyxml2::StrPair * parentEndTag = 0x7ffffffe05c0; */
                       ||||: /* Local reference: int * curLineNumPtr = 0x55555579d350; */
                       2104:     }
                       2105: 
                       2106:     p = XMLNode::ParseDeep( p, parentEndTag, curLineNumPtr );
                       ||||:
                       ----: }
                       at ../tinyxml2.cpp:2106

#15 0x00007ffff7f9ebb2 in tinyxml2::XMLNode::ParseDeep (/home/user/fuzzing_targets/tinyxml2/build/libtinyxml2.so.10)
                       1080: char tinyxml2::XMLNode::ParseDeep(this = (class tinyxml2::XMLNode *)0x55555579e980, p = (char *)0x55555579e83f "body>\n<!--00\3170000-", '0' <repeats 11 times>, "M", '0' <repeats 17 times>, "U\322>\n<p><mIET:math><m:mstyle sel=\"0\"scmi></m:mst", '\r' <repeats 12 times>, "00000000\377d=\"\"><xht:del t=\"\"><xht:h0 r=000--> <m:mi style", parentEndTag = (class tinyxml2::StrPair *)0x7ffffffe0780, curLineNumPtr = (int *)0x55555579d350) {
                       ||||:
                       ||||: /* Local reference: class tinyxml2::StrPair endTag = {_flags = 0, _start = 0x0, _end = 0x0}; */
                       ||||: /* Local reference: class tinyxml2::XMLNode * node = 0x55555579e9f8; */
                       ||||: /* Local reference: char * p = 0x55555579e83f "body>\n<!--00\3170000-", '0' <repeats 11 times>, "M", '0' <repeats 17 times>, "U\322>\n<p><mIET:math><m:mstyle sel=\"0\"scmi></m:mst", '\r' <repeats 12 times>, "00000000\377... */
                       ||||: /* Local reference: int * curLineNumPtr = 0x55555579d350; */
                       1115: 
                       1116:         StrPair endTag;
                       1117:         p = node->ParseDeep( p, &endTag, curLineNumPtr );
                       ||||:
                       ----: }
                       at ../tinyxml2.cpp:1117

#16 0x00007ffff7fa6a89 in tinyxml2::XMLElement::ParseDeep (/home/user/fuzzing_targets/tinyxml2/build/libtinyxml2.so.10)
                       2083: char tinyxml2::XMLElement::ParseDeep(this = (class tinyxml2::XMLElement *)0x55555579e980, p = (char *)0x55555579e83e "<body>\n<!--00\3170000-", '0' <repeats 11 times>, "M", '0' <repeats 17 times>, "U\322>\n<p><mIET:math><m:mstyle sel=\"0\"scmi></m:mst", '\r' <repeats 12 times>, "00000000\377d=\"\"><xht:del t=\"\"><xht:h0 r=000--> <m:mi style", parentEndTag = (class tinyxml2::StrPair *)0x7ffffffe0780, curLineNumPtr = (int *)0x55555579d350) {
                       ||||:
                       ||||: /* Local reference: char * p = 0x55555579e83e "<body>\n<!--00\3170000-", '0' <repeats 11 times>, "M", '0' <repeats 17 times>, "U\322>\n<p><mIET:math><m:mstyle sel=\"0\"scmi></m:mst", '\r' <repeats 12 times>, "00000000\37... */
                       ||||: /* Local reference: class tinyxml2::StrPair * parentEndTag = 0x7ffffffe0780; */
                       ||||: /* Local reference: int * curLineNumPtr = 0x55555579d350; */
                       2104:     }
                       2105: 
                       2106:     p = XMLNode::ParseDeep( p, parentEndTag, curLineNumPtr );
                       ||||:
                       ----: }
                       at ../tinyxml2.cpp:2106

#17 0x00007ffff7f9ebb2 in tinyxml2::XMLNode::ParseDeep (/home/user/fuzzing_targets/tinyxml2/build/libtinyxml2.so.10)
                       1080: char tinyxml2::XMLNode::ParseDeep(this = (class tinyxml2::XMLNode *)0x55555579d2b0, p = (char *)0x55555579e821 "html xmlns", parentEndTag = (class tinyxml2::StrPair *)0x0, curLineNumPtr = (int *)0x55555579d350) {
                       ||||:
                       ||||: /* Local reference: class tinyxml2::StrPair endTag = {_flags = 0, _start = 0x0, _end = 0x0}; */
                       ||||: /* Local reference: class tinyxml2::XMLNode * node = 0x55555579e980; */
                       ||||: /* Local reference: char * p = 0x55555579e821 "html xmlns"; */
                       ||||: /* Local reference: int * curLineNumPtr = 0x55555579d350; */
                       1115: 
                       1116:         StrPair endTag;
                       1117:         p = node->ParseDeep( p, &endTag, curLineNumPtr );
                       ||||:
                       ----: }
                       at ../tinyxml2.cpp:1117

#18 0x00007ffff7fa9725 in tinyxml2::XMLDocument::Parse (/home/user/fuzzing_targets/tinyxml2/build/libtinyxml2.so.10)
                       2558: void tinyxml2::XMLDocument::Parse(this = (class tinyxml2::XMLDocument *)0x55555579d2b0) {
                       ||||:
                       ||||: /* Local reference: char * p = 0x55555579e820 "<html xmlns"; */
                       2569:         return;
                       2570:     }
                       2571:     ParseDeep(p, 0, &_parseCurLineNum );
                       ||||:
                       ----: }
                       at ../tinyxml2.cpp:2571

#19 0x00007ffff7fa950d in tinyxml2::XMLDocument::LoadFile (/home/user/fuzzing_targets/tinyxml2/build/libtinyxml2.so.10)
                       2371: enum tinyxml2::XMLDocument::LoadFile(this = (class tinyxml2::XMLDocument *)0x55555579d2b0, fp = (FILE *)0x55555579d630) {
                       ||||:
                       ||||: /* Local reference: const size_t size = 341; */
                       2418:     _charBuffer[size] = 0;
                       2419: 
                       2420:     Parse();
                       ||||:
                       ----: }
                       at ../tinyxml2.cpp:2420

#20 0x00007ffff7fa8f83 in tinyxml2::XMLDocument::LoadFile (/home/user/fuzzing_targets/tinyxml2/build/libtinyxml2.so.10)
                       2352: enum tinyxml2::XMLDocument::LoadFile(this = (class tinyxml2::XMLDocument *)0x55555579d2b0, filename = (const char *)0x7fffffffe14d "crashes/id:000016,sig:06,src:000252,time:303091,execs:1126236,op:MOpt_havoc,rep:4") {
                       ||||:
                       ||||: /* Local reference: FILE * fp = 0x55555579d630; */
                       2364:         return _errorID;
                       2365:     }
                       2366:     LoadFile( fp );
                       ||||:
                       ----: }
                       at ../tinyxml2.cpp:2366

#21 0x000055555555c01f in main (/home/user/fuzzing_targets/tinyxml2/build/xmltest)
                       300: int main(argc = (int)2, argv = (const char **)0x7fffffffdd98) {
                       |||:
                       |||: /* Local reference: class tinyxml2::XMLDocument * doc = 0x55555579d2b0; */
                       |||: /* Local reference: clock_t startTime = 2753; */
                       |||: /* Local reference: const char ** argv = 0x7fffffffdd98; */
                       317:         XMLDocument* doc = new XMLDocument();
                       318:         clock_t startTime = clock();
                       319:         doc->LoadFile( argv[1] );
                       |||:
                       ---: }
                       at ../xmltest.cpp:319

Crash context:
Execution stopped here ==> 0x00007ffff789eb1c: mov    r14d,eax

Register info:
    rax - 0x0000000000000000 (0)
    rbx - 0x000000000011f2f4 (1176308)
    rcx - 0x00007ffff789eb1c (140737346399004)
    rdx - 0x0000000000000006 (6)
    rsi - 0x000000000011f2f4 (1176308)
    rdi - 0x000000000011f2f4 (1176308)
    rbp - 0x00007ffffffdff70 (0x7ffffffdff70)
    rsp - 0x00007ffffffdff30 (0x7ffffffdff30)
     r8 - 0x000055555578b010 (93824994553872)
     r9 - 0x0000000000000007 (7)
    r10 - 0x0000000000000008 (8)
    r11 - 0x0000000000000246 (582)
    r12 - 0x0000000000000006 (6)
    r13 - 0x00007ffff7fb301b (140737353822235)
    r14 - 0x0000000000000016 (22)
    r15 - 0x00007ffff7fb32f4 (140737353822964)
    rip - 0x00007ffff789eb1c (0x7ffff789eb1c <__GI___pthread_kill+284>)
 eflags - 0x00000246 ([ PF ZF IF ])
     cs - 0x00000033 (51)
     ss - 0x0000002b (43)
     ds - 0x00000000 (0)
     es - 0x00000000 (0)
     fs - 0x00000000 (0)
     gs - 0x00000000 (0)
fs_base - 0x00007ffff7f3f7c0 (140737353349056)
gs_base - 0x0000000000000000 (0)
```

## Proof-of-Concept Files
[poc](https://github.com/4n0nym4u5/CVE/raw/main/tinyxml2_poc/reachable_assertion_digit/poc)

## Reproduction
```bash
git clone https://github.com/leethomason/tinyxml2
cd tinyxml2
CC=clang CXX=clang++ meson setup build
CC=clang CXX=clang++ sudo ninja -C build install
./build/xmltest poc
```

## Results
```bash
➜  tinyxml2 git:(master) ✗ ./build/xmltest tinyxml2_poc/reachable_assertion_digit/poc
xmltest: ../tinyxml2.cpp:545: static const char *tinyxml2::XMLUtil::GetCharacterRef(const char *, char *, int *): Assertion `digit == 0 || mult <= UINT_MAX / digit' failed.
[1]    1177540 IOT instruction  ./build/xmltest tinyxml2_poc/reachable_assertion_digit/poc
```

## Environment
```
Linux Mint 22 Wilma 
Ubuntu clang version 18.1.3 (1ubuntu1)
gcc (Ubuntu 13.2.0-23ubuntu4) 13.2.0
```
