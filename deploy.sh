#!/bin/sh

cd ~/Code/bookclub
./build.sh
rsync -avH build/web/ -e ssh 192.168.178.63:/var/www/bookclub.tiedl.rocks/