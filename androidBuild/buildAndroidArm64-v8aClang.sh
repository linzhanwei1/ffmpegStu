#!/bin/bash
# use ndk version:android-ndk-r20b

export NDK=/home/book/download/android-ndk-r20b
TOOLCHAIN=$NDK/toolchains/llvm/prebuilt/linux-x86_64

function build_android
{
./configure \
	--prefix=$PREFIX \
	--enable-neon \
	--enable-hwaccels \
	--enable-gpl \
	--enable-small \
	--enable-jni \
	--enable-mediacodec \
	--enable-decoder=h264_mediacodec \
	--enable-static \
	--enable-shared \
	--disable-postproc \
	--disable-debug \
	--disable-doc \
	--disable-ffmpeg \
	--disable-ffplay \
	--disable-ffprobe \
	--disable-avdevice \
	--disable-symver \
	--cross-prefix=$CROSS_PREFIX \
	--target-os=android \
	--arch=$ARCH \
	--cpu=$CPU \
	--cc=$CC \
	--cxx=$CXX \
	--enable-cross-compile \
	--sysroot=$SYSROOT \
	--extra-cflags="-Os -fPIC $OPTIMIZE_CFLAGS" \
	--extra-ldflags="$ADDI_LDFLAGS"

make clean
make -j4
make install

echo "================================== build android arm64-v8a success =================================="
}

# arm64-v8a
ARCH=arm64
CPU=armv8-a
API=21
CC=$TOOLCHAIN/bin/aarch64-linux-android$API-clang
CXX=$TOOLCHAIN/bin/aarch64-linux-android$API-clang++
SYSROOT=$NDK/toolchains/llvm/prebuilt/linux-x86_64/sysroot
CROSS_PREFIX=$TOOLCHAIN/bin/aarch64-linux-android-
PREFIX=$(pwd)/android/$CPU
OPTIMIZE_CFLAGS="-march=$CPU"

build_android
