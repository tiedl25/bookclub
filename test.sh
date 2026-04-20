#!/bin/sh

cd ~/Code/bookclub
./build.sh
cd build/web
python3 -m http.server 8888
cd ../..