#!/bin/bash
# start base taken from https://github.com/kivy/kivy-ios/blob/master/tools/reduce-python.sh

#
# remove source and useless files from 'lib' folder
#
# preserve files that are needed by 'sysconfig.py' in 'get_config_vars()' and used to validate the python installation:
#   include/python2.7/pyconfig.h
#   lib/python2.7/config/Makefile
#
# create a lib/python27.zip file containing modules
#

pushd ./lib

find . -iname '*.pyc' | xargs rm
find . -iname '*.py' | xargs rm
find . -iname 'test*' | xargs rm -rf
rm -rf *test* lib* wsgiref bsddb curses idlelib hotshot || true
rm -rf pkgconfig || true

pushd ./python2.7

mv config/Makefile ../config_Makefile
rm -rf config

zip -r ../python27.zip *
rm -rf *

mkdir config
mv ../config_Makefile config

popd

popd
