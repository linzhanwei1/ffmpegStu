#!/bin/bash
make clean
set -e
archbit=64

if [ $archbit -eq 64 ];then
echo "build for 64bit"
ARCH=aarch64
CPU=armv8-a
API=21
PLATFORM=aarch64
ANDROID=android
# CFLAGS="-I$SYSROOT/usr/include -I$SYSROOT/usr/include/$ARCH-linux-$ANDROID"
# LDFLAGS="-L$SYSROOT/usr/lib/$ARCH-linux-$ANDROID -L$SYSROOT/usr/lib/$ARCH-linux-$ANDROID/$API"
CFLAGS="-fPIC"
LDFLAGS=""

else
echo "build for 32bit"
ARCH=arm
CPU=armv7-a
API=21
PLATFORM=armv7a
ANDROID=androideabi
CFLAGS="-mfloat-abi=softfp -march=$CPU"
LDFLAGS="-Wl,--fix-cortex-a8"
fi

export NDK=/home/book/download/android-ndk-r27
export TOOLCHAIN=$NDK/toolchains/llvm/prebuilt/linux-x86_64/bin
export SYSROOT=$NDK/toolchains/llvm/prebuilt/linux-x86_64/sysroot
export CROSS_PREFIX=$TOOLCHAIN/$ARCH-linux-$ANDROID-
export CC=$TOOLCHAIN/$PLATFORM-linux-$ANDROID$API-clang
export CXX=$TOOLCHAIN/$PLATFORM-linux-$ANDROID$API-clang++
export PREFIX=build/ffmpeg-android/$CPU

function build_android {
    ./configure \
    --prefix=$PREFIX \
    --cross-prefix=$CROSS_PREFIX \
    --target-os=android \
    --arch=$ARCH \
    --cpu=$CPU \
    --cc=$CC \
    --cxx=$CXX \
	--ar=$TOOLCHAIN/llvm-ar \
    --nm=$TOOLCHAIN/llvm-nm \
    --strip=$TOOLCHAIN/llvm-strip \
	--ranlib=$TOOLCHAIN/llvm-ranlib \
	--pkg-config=$TOOLCHAIN/bin/llvm-config \
    --enable-cross-compile \
    --sysroot=$SYSROOT \
    --extra-cflags="$CFLAGS" \
    --extra-ldflags="$LDFLAGS" \
    --extra-ldexeflags=-pie \
    --enable-runtime-cpudetect \
    --enable-static \
	--enable-small \
    --disable-shared \
    --disable-ffprobe \
    --disable-ffplay \
    --disable-ffmpeg \
    --disable-debug \
    --disable-doc \
    --enable-avfilter \
    --enable-decoders \
	--enable-pic \

    make -j4
    make install
}
build_android
