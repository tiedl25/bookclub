#!/bin/sh

cd ~/Code/bookclub
./build.sh
rsync -avH build/web/ -e ssh tiedlserver.tiedl.rocks:/var/www/bookclub.tiedl.rocks/