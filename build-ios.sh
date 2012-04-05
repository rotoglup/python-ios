#!/bin/bash
# TODO simplify/factorize build for device/simulator
# TODO assemble a fat libpython for armv7 + i686
# TODO ios specific python patch for module import (dolmen)
# TODO ios specific ctypes (arm + dolmen)

set -x

try () {
	"$@" || exit -1
}

# iOS SDK Environmnent, either from environment or default values
[ -z $IOS_SDK_VER ] && export IOS_SDK_VER="5.1"
[ -z $IOS_DEPLOYMENT_TARGET ] && export IOS_DEPLOYMENT_TARGET="5.0"
[ -z $IOS_PLATFORMS_ROOT ] && export IOS_PLATFORMS_ROOT="/Applications/Xcode.app/Contents/Developer/Platforms"
[ -z $IOS_DEVICE_HOSTARCH ] && export IOS_DEVICE_HOSTARCH="arm-apple-darwin10"
[ -z $IOS_SIMULATOR_HOSTARCH ] && export IOS_SIMULATOR_HOSTARCH="i686-apple-darwin11"

#IOS_PYTHON_OPTIMIZATION_CFLAGS="-O3"
IOS_PYTHON_OPTIMIZATION_CFLAGS="-O0 -g"
# TODO libffi host arch

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


echo "Building host for native machine ============================================"

# make sure that we make a clean start
# Copy our setup for host python static modules, to enable working without being properly installed
try rm -f ./Modules/Setup.local
try cp -f ./Modules/Setup.host ./Modules/Setup.local

try ./configure CC="$CCACHE clang -Qunused-arguments -fcolor-diagnostics"

try make -j2 python.exe Parser/pgen

try mv python.exe hostpython

# preserve host 'pgen' which is the whole point of building the native version of python, this files not provided in binary distributions of python
try mv Parser/pgen Parser/hostpgen

echo "Building for iOS device ======================================================="

try make distclean

# flags for arm compilation
export DEVROOT=$IOS_PLATFORMS_ROOT/iPhoneOS.platform/Developer
export SDKROOT=$DEVROOT/SDKs/iPhoneOS$IOS_SDK_VER.sdk

export ARM_CC="$CCACHE $DEVROOT/usr/bin/$IOS_DEVICE_HOSTARCH-llvm-gcc-4.2"
export ARM_CXX="$CCACHE $DEVROOT/usr/bin/$IOS_DEVICE_HOSTARCH-llvm-g++-4.2"
export ARM_AR="$DEVROOT/usr/bin/ar"
export ARM_LD="$DEVROOT/usr/bin/ld"
export ARM_CFLAGS="-march=armv7 -mcpu=arm176jzf -mcpu=cortex-a8"
export ARM_CFLAGS="$ARM_CFLAGS -pipe -no-cpp-precomp"
export ARM_CFLAGS="$ARM_CFLAGS -isysroot $SDKROOT"
export ARM_CFLAGS="$ARM_CFLAGS -miphoneos-version-min=$IOS_DEPLOYMENT_TARGET"
export ARM_CFLAGS="$ARM_CFLAGS $IOS_PYTHON_OPTIMIZATION_CFLAGS"
export ARM_LDFLAGS="-isysroot $SDKROOT"
export ARM_LDFLAGS="$ARM_LDFLAGS -miphoneos-version-min=$IOS_DEPLOYMENT_TARGET"

# set up environment variables for cross compilation
export MACOSX_DEPLOYMENT_TARGET=

# Copy our setup for ios static modules
try rm -f ./Modules/Setup.local
try cp -f ./Modules/Setup.ios ./Modules/Setup.local

# '--disable-toolbox-glue' disable the glue code for the Carbon interface modules
try ./configure CC="$ARM_CC" LD="$ARM_LD" \
	CFLAGS="$ARM_CFLAGS" LDFLAGS="$ARM_LDFLAGS" \
	CXX="$ARM_CXX" CXXFLAGS="$ARM_CFLAGS" \
	--disable-toolbox-glue \
	--host=armv7-apple-darwin \
	--prefix=`pwd`/_python-ios-arm \
	--without-doc-strings

try make -j2 HOSTPYTHON="`pwd`/hostpython" HOSTPGEN="`pwd`/Parser/hostpgen" \
     CROSS_COMPILE=$IOS_DEVICE_HOSTARCH- CROSS_COMPILE_TARGET=yes \
     HOSTARCH=$IOS_DEVICE_HOSTARCH BUILDARCH=darwin-x86

try make -j2 install HOSTPYTHON="`pwd`/hostpython" CROSS_COMPILE_TARGET=yes prefix=`pwd`/_python-ios-arm

#try mv -f $BUILDROOT/python/lib/libpython2.7.a $BUILDROOT/lib/

#deduplicate $BUILDROOT/lib/libpython2.7.a


echo "Building for iOS simulator ======================================================="

try make distclean

# flags for simulator compilation
export DEVROOT=$IOS_PLATFORMS_ROOT/iPhoneSimulator.platform/Developer
export SDKROOT=$DEVROOT/SDKs/iPhoneSimulator$IOS_SDK_VER.sdk

export ARM_CC="$CCACHE $DEVROOT/usr/bin/$IOS_SIMULATOR_HOSTARCH-llvm-gcc-4.2"
export ARM_CXX="$CCACHE $DEVROOT/usr/bin/$IOS_SIMULATOR_HOSTARCH-llvm-g++-4.2"
export ARM_AR="$DEVROOT/usr/bin/ar"
export ARM_LD="$DEVROOT/usr/bin/ld"
export ARM_CFLAGS=""
export ARM_CFLAGS="$ARM_CFLAGS -pipe -no-cpp-precomp"
export ARM_CFLAGS="$ARM_CFLAGS -isysroot $SDKROOT"
export ARM_CFLAGS="$ARM_CFLAGS -miphoneos-version-min=$IOS_DEPLOYMENT_TARGET"
export ARM_CFLAGS="$ARM_CFLAGS $IOS_PYTHON_OPTIMIZATION_CFLAGS"
export ARM_LDFLAGS="-isysroot $SDKROOT"
export ARM_LDFLAGS="$ARM_LDFLAGS -miphoneos-version-min=$IOS_DEPLOYMENT_TARGET"

# set up environment variables for cross compilation
export MACOSX_DEPLOYMENT_TARGET=

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
     CROSS_COMPILE=$IOS_SIMULATOR_HOSTARCH- CROSS_COMPILE_TARGET=yes \
     HOSTARCH=$IOS_SIMULATOR_HOSTARCH BUILDARCH=darwin-x86

try make -j2 install HOSTPYTHON="`pwd`/hostpython" CROSS_COMPILE_TARGET=yes prefix=`pwd`/_python-ios-simulator

#try mv -f $BUILDROOT/python/lib/libpython2.7.a $BUILDROOT/lib/

#deduplicate $BUILDROOT/lib/libpython2.7.a
