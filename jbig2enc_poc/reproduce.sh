#!/bin/bash

sudo apt install libleptonica-dev
cd jbig2enc
./autogen.sh
CFLAGS="-fsanitize=address -fno-omit-frame-pointer -g" CXXFLAGS=" -fsanitize=address -fno-omit-frame-pointer -g" ./configure --disable-shared
make -j 12
./src/jbig2 -s -S -p -v -d -2 -O ../poc/out.png ../poc/poc.jpg