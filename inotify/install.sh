#!/bin/bash
# install inotify-tools
mkdir -p /Data/download
cd /Data/download
[ -f inotify-tools-3.14.tar.gz ] || wget http://nchc.dl.sourceforge.net/project/inotify-tools/inotify-tools/3.13/inotify-tools-3.13.tar.gz
tar -xf inotify-tools-3.14.tar.gz -C /tmp
cd /tmp/inotify-tools-3.14
./configure
make && make install

echo '/usr/local/lib' >> /etc/ld.so.conf
ldconfig
