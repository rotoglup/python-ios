#!/bin/bash
# TODO uncomment host python build
# TODO uncomment ios device build
# TODO simplify/factorize build for device/simulator
# TODO assemble a fat libpython for armv7 + i686
# TODO ios specific python patch for module import (dolmen)
# TODO ios specific ctypes (arm + dolmen)

set -x

try () {
	"$@" || exit -1
}

# iOS SDK Environmnent
export SDKVER=4.2

# some tools
export CCACHE=$(which ccache)

# one method to deduplicate some symbol in libraries
function deduplicate() {
	fn=$(basename $1)
	echo "== Trying to remove duplicate symbol in $1"
	try mkdir ddp
	try cd ddp
	try ar x $1
	try ar rc $fn *.o
	try ranlib $fn
	try mv -f $fn $1
	try cd ..
	try rm -rf ddp
}


## Patch Python for temporary reduce PY_SSIZE_T_MAX otherzise, splitting string doesnet work
#try patch -p1 < $KIVYIOSROOT/src/python_files/Python-$PYTHON_VERSION-ssize-t-max.patch
#try patch -p1 < $KIVYIOSROOT/src/python_files/Python-$PYTHON_VERSION-dynload.patch

## Copy our setup for modules
#try cp $KIVYIOSROOT/src/python_files/ModulesSetup Modules/Setup.local


echo "Building host for native machine ============================================"

# make sure that we make a clean start
# Copy our setup for host python static modules, to enable working without being properly installed
try rm -f ./Modules/Setup.local
try cp -f ./Modules/Setup.host ./Modules/Setup.local

#try ./configure CC="$CCACHE clang -Qunused-arguments -fcolor-diagnostics"

#try make -j2 python.exe Parser/pgen

#try mv python.exe hostpython

# preserve host 'pgen' which is the whole point of building the native version of python, this files not provided in binary distributions of python
#try mv Parser/pgen Parser/hostpgen

#try make distclean

echo "Building for iOS device ======================================================="

# flags for arm compilation
export DEVROOT=/Developer/Platforms/iPhoneOS.platform/Developer
export SDKROOT=$DEVROOT/SDKs/iPhoneOS$SDKVER.sdk

export ARM_CC="$CCACHE $DEVROOT/usr/bin/arm-apple-darwin10-llvm-gcc-4.2"
export ARM_CXX="$CCACHE $DEVROOT/usr/bin/arm-apple-darwin10-llvm-g++-4.2"
export ARM_AR="$DEVROOT/usr/bin/ar"
export ARM_LD="$DEVROOT/usr/bin/ld"
export ARM_CFLAGS="-march=armv7 -mcpu=arm176jzf -mcpu=cortex-a8"
export ARM_CFLAGS="$ARM_CFLAGS -pipe -no-cpp-precomp"
export ARM_CFLAGS="$ARM_CFLAGS -isysroot $SDKROOT"
export ARM_CFLAGS="$ARM_CFLAGS -miphoneos-version-min=$SDKVER"
export ARM_LDFLAGS="-isysroot $SDKROOT"
export ARM_LDFLAGS="$ARM_LDFLAGS -miphoneos-version-min=$SDKVER"

# uncomment this line if you want debugging stuff
export ARM_CFLAGS="$ARM_CFLAGS -O3"
#export ARM_CFLAGS="$ARM_CFLAGS -O0 -g"

# set up environment variables for cross compilation
#export CPPFLAGS="-I$SDKROOT/usr/lib/gcc/arm-apple-darwin11/4.2.1/include/ -I$SDKROOT/usr/include/"
#export CPP="$CCACHE /usr/bin/cpp $CPPFLAGS"
export MACOSX_DEPLOYMENT_TARGET=

## make a link to a differently named library for who knows what reason
#mkdir extralibs||echo "foo"
#ln -s "$SDKROOT/usr/lib/libgcc_s.1.dylib" extralibs/libgcc_s.10.4.dylib || #echo "sdf"

# Copy our setup for ios static modules
try rm -f ./Modules/Setup.local
try cp -f ./Modules/Setup.ios ./Modules/Setup.local

# '--disable-toolbox-glue' disable the glue code for the Carbon interface modules
#try ./configure CC="$ARM_CC" LD="$ARM_LD" \
#	CFLAGS="$ARM_CFLAGS" LDFLAGS="$ARM_LDFLAGS" \
#	CXX="$ARM_CXX" CXXFLAGS="$ARM_CFLAGS" \
#	--disable-toolbox-glue \
#	--host=armv7-apple-darwin \
#	--prefix=`pwd`/_python-ios-arm \
#	--without-doc-strings

#try make -j2 HOSTPYTHON="`pwd`/hostpython" HOSTPGEN="`pwd`/Parser/hostpgen" \
#     CROSS_COMPILE=arm-apple-darwin10- CROSS_COMPILE_TARGET=yes \
#     HOSTARCH=arm-apple-darwin10 BUILDARCH=darwin-x86

#try make -j2 install HOSTPYTHON="`pwd`/hostpython" CROSS_COMPILE_TARGET=yes prefix=`pwd`/_python-ios-arm

#try mv -f $BUILDROOT/python/lib/libpython2.7.a $BUILDROOT/lib/

#deduplicate $BUILDROOT/lib/libpython2.7.a


echo "Building for iOS simulator ======================================================="

#try make distclean

# flags for simulator compilation
export DEVROOT=/Developer/Platforms/iPhoneSimulator.platform/Developer
export SDKROOT=$DEVROOT/SDKs/iPhoneSimulator$SDKVER.sdk

export ARM_CC="$CCACHE $DEVROOT/usr/bin/i686-apple-darwin10-llvm-gcc-4.2"
export ARM_CXX="$CCACHE $DEVROOT/usr/bin/i686-apple-darwin10-llvm-g++-4.2"
export ARM_AR="$DEVROOT/usr/bin/ar"
export ARM_LD="$DEVROOT/usr/bin/ld"
export ARM_CFLAGS=""
export ARM_CFLAGS="$ARM_CFLAGS -pipe -no-cpp-precomp"
export ARM_CFLAGS="$ARM_CFLAGS -isysroot $SDKROOT"
export ARM_CFLAGS="$ARM_CFLAGS -miphoneos-version-min=$SDKVER"
export ARM_LDFLAGS="-isysroot $SDKROOT"
export ARM_LDFLAGS="$ARM_LDFLAGS -miphoneos-version-min=$SDKVER"

# uncomment this line if you want debugging stuff
export ARM_CFLAGS="$ARM_CFLAGS -O3"
#export ARM_CFLAGS="$ARM_CFLAGS -O0 -g"

# set up environment variables for cross compilation
#export CPPFLAGS="-I$SDKROOT/usr/lib/gcc/arm-apple-darwin11/4.2.1/include/ -I$SDKROOT/usr/include/"
#export CPP="$CCACHE /usr/bin/cpp $CPPFLAGS"
export MACOSX_DEPLOYMENT_TARGET=

## make a link to a differently named library for who knows what reason
#mkdir extralibs||echo "foo"
#ln -s "$SDKROOT/usr/lib/libgcc_s.1.dylib" extralibs/libgcc_s.10.4.dylib || #echo "sdf"

# Copy our setup for ios static modules
try rm -f ./Modules/Setup.local
try cp -f ./Modules/Setup.ios ./Modules/Setup.local

# '--disable-toolbox-glue' disable the glue code for the Carbon interface modules
try ./configure CC="$ARM_CC" LD="$ARM_LD" \
	CFLAGS="$ARM_CFLAGS" LDFLAGS="$ARM_LDFLAGS" \
	CXX="$ARM_CXX" CXXFLAGS="$ARM_CFLAGS" \
	--disable-toolbox-glue \
	--host=armv7-apple-darwin \
	--prefix=`pwd`/_python-ios-simulator \
	--without-doc-strings

try make -j2 HOSTPYTHON="`pwd`/hostpython" HOSTPGEN="`pwd`/Parser/hostpgen" \
     CROSS_COMPILE=arm-apple-darwin10- CROSS_COMPILE_TARGET=yes \
     HOSTARCH=arm-apple-darwin10 BUILDARCH=darwin-x86

try make -j2 install HOSTPYTHON="`pwd`/hostpython" CROSS_COMPILE_TARGET=yes prefix=`pwd`/_python-ios-simulator

#try mv -f $BUILDROOT/python/lib/libpython2.7.a $BUILDROOT/lib/

#deduplicate $BUILDROOT/lib/libpython2.7.a
