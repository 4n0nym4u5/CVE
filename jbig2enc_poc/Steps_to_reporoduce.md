# Follow these steps to reporoduce the crash


sudo apt install libleptonica-dev
./autogen.sh
CFLAGS="-fsanitize=address -fno-omit-frame-pointer -g" CXXFLAGS=" -fsanitize=address -fno-omit-frame-pointer -g" ./configure --disable-shared
make -j 12
./src/jbig2 -s -S -p -v -d -2 -O poc/out.png poc/poc.jpg