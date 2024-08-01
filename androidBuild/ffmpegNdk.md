# 编译android平台库文件
## 概述
- 使用NDK环境交叉编译ffmpeg源代码，供android音视频开发使用.本文档会指导完成编译任务，从0编写构建脚本。\
- 由于android(NDK)和ffmpeg都是更新比较频繁，版本众多，不同版本有历史差异，本文分别使用gcc和clang编译两版源代码。
- 本文档主要描述构建的流程和注意事项，假设你具备基本的Linux操作的能力、sh脚本的基本知识等，如不具备请自行学习。
- 请仔细阅读文档，深刻理解其中的含义和思想
## 基础知识
### 本地编译
- 当前操作系统的HOST环境:`Linux 746f41b4e03c 5.4.0-181-generic #201-Ubuntu SMP Thu Mar 28 15:39:01 UTC 2024 x86_64 x86_64 x86_64 GNU/Linux`
- 如下源码进行本地编译
```C
int main(int argc, char **argv) { return 0; }
```
- 编译可重定位目标文件，输出：helloNdk.o
```sh
gcc -c helloNdk.c
```
- 查看输出文件的相关信息
```
file helloNdk.o
```
> 反馈
```sh
helloNdk.o: ELF 64-bit LSB relocatable, x86-64, version 1 (SYSV), not stripped
```
- 结论：**编译源码的HOST平台(x86_64) == 目标文件运行的target平台(x86_64)**
### 交叉编译
- 当前操作系统的HOST环境:`Linux 746f41b4e03c 5.4.0-181-generic #201-Ubuntu SMP Thu Mar 28 15:39:01 UTC 2024 x86_64 x86_64 x86_64 GNU/Linux`
- 如下源码进行本地编译
```C
int main(int argc, char **argv) { return 0; }
```
- 编译执行程序,输出a.out
```sh
/home/book/download/android-ndk-r16b/toolchains/aarch64-linux-android-4.9/prebuilt/linux-x86_64/bin//aarch64-linux-android-gcc -c helloNdk.c
```
- 查看输出文件的相关信息
```
file helloNdk.o
```
> 反馈
```sh
helloNdk.o: ELF 64-bit LSB relocatable, ARM aarch64, version 1 (SYSV), not stripped
```
- 结论：**编译源码的HOST平台(x86_64) != 目标文件运行的target平台(ARM aarch64)**
## 环境搭建
- HOST平台：`Linux 62881e6bba6c 5.4.0-181-generic #201-Ubuntu SMP Thu Mar 28 15:39:01 UTC 2024 x86_64 x86_64 x86_64 GNU/Linux`
- 
### 准备原材料
- [下载android-ndk-r16b]()
- [下载当前时间段(2024)最新android-ndk-r27-linux.zip](https://googledownloads.cn/android/repository/android-ndk-r27-linux.zip)
- [下载ffmpeg-3.4.13.tar.bz2](https://ffmpeg.org/releases/ffmpeg-3.4.13.tar.bz2)
- [下载ffmpeg-6.1.1.tar.bz2](https://ffmpeg.org/releases/ffmpeg-6.1.1.tar.bz2)
- 说明：
    - 使用android-ndk-r16b环境编译较老版本的ffmpeg
    - 使用(紧跟实时)android-ndk-r27-linux编译较新的ffmpeg
## 编写编译脚本
### 构建ffmpeg-3.4.13.tar.bz2源码
- NDK目录：`/home/book/download/android-ndk-r16b`
- 生成目标交叉编译工具链工具链
```sh
cd $HOME/download/android-ndk-r16b/build/tools && ./make_standalone_toolchain.py --arch arm64 --api 21 --install-dir /home/book/download/android-ndk-r16b/android-toolchains/android-21/aarch64 --force
```
- 查看生成的工具链(保持最大兼容性最低支持android-21)
```sh
tree $HOME/download/android-ndk-r16b/android-toolchains/android-21/ -L 3
```
> 反馈
``` sh
//home/book/download/android-ndk-r16b/android-toolchains/android-21/
`-- aarch64
    ...
    |-- bin
    |   |-- 2to3
    |   |-- FileCheck
    |   |-- aarch64-linux-android-addr2line
    |   |-- aarch64-linux-android-ar
    |   |-- aarch64-linux-android-as
    |   |-- aarch64-linux-android-c++
    |   |-- aarch64-linux-android-c++filt
    |   |-- aarch64-linux-android-clang
    |   |-- aarch64-linux-android-clang++
    |   |-- aarch64-linux-android-cpp
    |   |-- aarch64-linux-android-dwp
    |   |-- aarch64-linux-android-elfedit
    |   |-- aarch64-linux-android-g++
    |   |-- aarch64-linux-android-gcc
    |   |-- aarch64-linux-android-gcc-4.9
    |   |-- aarch64-linux-android-gcc-4.9.x
    |   |-- aarch64-linux-android-gcc-ar
    |   |-- aarch64-linux-android-gcc-nm
    |   |-- aarch64-linux-android-gcc-ranlib
    |   |-- aarch64-linux-android-gcov
    |   |-- aarch64-linux-android-gcov-tool
    |   |-- aarch64-linux-android-gprof
    |   |-- aarch64-linux-android-ld
    |   |-- aarch64-linux-android-ld.bfd
    |   |-- aarch64-linux-android-ld.gold
    |   |-- aarch64-linux-android-nm
    |   |-- aarch64-linux-android-objcopy
    |   |-- aarch64-linux-android-objdump
    |   |-- aarch64-linux-android-ranlib
    |   |-- aarch64-linux-android-readelf
    |   |-- aarch64-linux-android-size
    |   |-- aarch64-linux-android-strings
    |   |-- aarch64-linux-android-strip
    |   |-- arm64-v8a
    |   |-- armeabi
    |   |-- armeabi-v7a
    |   |-- armeabi-v7a-hard
    |   |-- asan_device_setup
    |   |-- bisect_driver.py
    |   |-- clang
    |   |-- clang++
    |   |-- clang-format
    |   |-- clang-tidy
    |   |-- clang50
    |   |-- clang50++
    |   |-- gcore
    |   |-- gdb
    |   |-- gdb-orig
    |   |-- git-clang-format
    |   |-- idle
    |   |-- llvm-ar
    |   |-- llvm-as
    |   |-- llvm-dis
    |   |-- llvm-link
    |   |-- llvm-profdata
    |   |-- llvm-symbolizer
    |   |-- make
    |   |-- mips
    |   |-- mips64
    |   |-- ndk-depends
    |   |-- ndk-gdb
    |   |-- ndk-gdb.py
    |   |-- ndk-stack
    |   |-- ndk-which
    |   |-- pydoc
    |   |-- python
    |   |-- python-config
    |   |-- python-config.sh
    |   |-- python2
    |   |-- python2-config
    |   |-- python2.7
    |   |-- python2.7-config
    |   |-- sancov
    |   |-- sanstats
    |   |-- smtpd.py
    |   |-- x86
    |   |-- x86_64
    |   `-- yasm
    ...

46 directories, 88 files
```
- 编写构建脚本:`vim build_arm64-v8a.sh`
```sh
#/bin/bash
# 生成32位工具链:./make_standalone_toolchain.py --arch arm --api 19 --install-dir /home/book/download/android-ndk-r16-beta1/android-toolchains/android-19/arch-arm
# 生成64位工具链:./make_standalone_toolchain.py --arch arm64 --api 21 --install-dir /home/book/download/android-ndk-r16b/android-toolchains/android-21/aarch64
# 调整configure文件内容
# SLIBNAME_WITH_MAJOR='$(SLIBPREF)$(FULLNAME)-$(LIBMAJOR)$(SLIBSUF)'
# LIB_INSTALL_EXTRA_CMD='$$(RANLIB) "$(LIBDIR)/$(LIBNAME)"'
# SLIB_INSTALL_NAME='$(SLIBNAME_WITH_MAJOR)'
# SLIB_INSTALL_LINKS='$(SLIBNAME)'

# 用于编译android armv8a 平台脚本

# 定义几个变量
ARCH=aarch64
CPU=armv8-a
PREFIX=$(pwd)/android/$ARCH/$CPU
NDK_PATH=/home/book/download/android-ndk-r16b

# ANDROID_TOOLCHAINS_PATH=${NDK_PATH}/android-toolchains/android-19/arch-arm
ANDROID_TOOLCHAINS_PATH=${NDK_PATH}/android-toolchains/android-21/$ARCH
# CROSS_PREFIX=${ANDROID_TOOLCHAINS_PATH}/bin/arm-linux-androideabi-
CROSS_PREFIX=${ANDROID_TOOLCHAINS_PATH}/bin/aarch64-linux-android-
SYSROOT=${ANDROID_TOOLCHAINS_PATH}/sysroot

ADDI_CFLAGS="-march=armv8-a"
ADDI_LDFLAGS="-L$TOOLCHAIN/sysroot/usr/lib"
ADDITIONAL_CONFIG_FLAG="--arch=aarch64 --enable-yasm"

# 执行.configure 文件
./configure --prefix=${PREFIX} \
        --enable-gpl \
        --enable-static \
        --disable-shared \
        --enable-small \
        --disable-programs \
        --disable-ffmpeg \
        --disable-ffplay \
        --disable-ffprobe \
        --disable-ffserver \
        --disable-doc \
        --arch=$ARCH \
        --cpu=$CPU \
        --cross-prefix=${CROSS_PREFIX} \
        --enable-cross-compile \
        --sysroot=$SYSROOT \
        --target-os=android \
        --enable-pic \
        --extra-cflags="-Os -fpic $ADDI_CFLAGS" \
        --extra-ldflags="$ADDI_LDFLAGS" \
        --enable-yasm \

# 运行 Makefile
make -j4

# 安装到指定 prefix 目录下
make install
```
- 更改脚本运行权限并放置到ffmpeg-3.4.13源码目录
```
chmod u+x build_arm64-v8a.sh
mv build_arm64-v8a.sh ffmpeg-3.4.13/
```
- 进入ffmpeg-3.4.13源码目录开始编译
```sh
./build_arm64-v8a.sh
```
- 编译完成后查看输出文件
```
tree -L 4 $HOME/download/ffmpeg-3.4.13/android/
```
> 反馈
```sh
/home/book/download/ffmpeg-3.4.13/android/
`-- aarch64
    `-- armv8-a
        |-- include
        |   |-- libavcodec
        |   |-- libavdevice
        |   |-- libavfilter
        |   |-- libavformat
        |   |-- libavutil
        |   |-- libpostproc
        |   |-- libswresample
        |   `-- libswscale
        |-- lib
        |   |-- libavcodec.a
        |   |-- libavdevice.a
        |   |-- libavfilter.a
        |   |-- libavformat.a
        |   |-- libavutil.a
        |   |-- libpostproc.a
        |   |-- libswresample.a
        |   |-- libswscale.a
        |   `-- pkgconfig
        `-- share
            `-- ffmpeg

15 directories, 8 files
```
### 构建ffmpeg-3.4.13.tar.bz2源码(armv7-a)==>具体流程参考rmv8-a 如上
- 具体编译脚本如下`build_arm32_v7a.sh`：
```sh
#/bin/bash
# 生成32位工具链:./make_standalone_toolchain.py --arch arm --api 19 --install-dir /home/book/download/android-ndk-r16b/android-toolchains/android-19/arch-arm
# 生成64位工具链:./make_standalone_toolchain.py --arch arm64 --api 21 --install-dir /home/book/download/android-ndk-r16b/android-toolchains/android-21/aarch64
# 调整configure文件内容
# SLIBNAME_WITH_MAJOR='$(SLIBPREF)$(FULLNAME)-$(LIBMAJOR)$(SLIBSUF)'
# LIB_INSTALL_EXTRA_CMD='$$(RANLIB) "$(LIBDIR)/$(LIBNAME)"'
# SLIB_INSTALL_NAME='$(SLIBNAME_WITH_MAJOR)'
# SLIB_INSTALL_LINKS='$(SLIBNAME)'

# 用于编译android armv8a 平台脚本

# 定义几个变量
ARCH=arm
CPU=armv7-a
PREFIX=$(pwd)/android/$ARCH/$CPU
NDK_PATH=/home/book/download/android-ndk-r16b

ANDROID_TOOLCHAINS_PATH=${NDK_PATH}/android-toolchains/android-19/arch-arm
CROSS_PREFIX=${ANDROID_TOOLCHAINS_PATH}/bin/arm-linux-androideabi-
SYSROOT=${ANDROID_TOOLCHAINS_PATH}/sysroot

ADDI_CFLAGS="-marm -march=armv7-a -mfloat-abi=softfp -mthumb -mfpu=vfpv3-d16 -mtune=cortex-a8"
ADDI_LDFLAGS="-marm -march=armv7-a -Wl,--fix-cortex-a8"
ADDITIONAL_CONFIG_FLAG="--arch=arm --disable-asm"

# 执行.configure 文件
./configure --prefix=${PREFIX} \
        --enable-gpl \
        --enable-static \
        --disable-shared \
        --enable-small \
        --disable-programs \
        --disable-ffmpeg \
        --disable-ffplay \
        --disable-ffprobe \
        --disable-ffserver \
        --disable-doc \
        --arch=$ARCH \
        --cpu=$CPU \
        --cross-prefix=${CROSS_PREFIX} \
        --enable-cross-compile \
        --sysroot=$SYSROOT \
        --target-os=android \
        --enable-pic \
        --extra-cflags="-Os -fpic $ADDI_CFLAGS" \
        --extra-ldflags="$ADDI_LDFLAGS" \
        --enable-yasm \
        $ADDITIONAL_CONFIG_FLAG

# 运行 Makefile
make -j4

# 安装到指定 prefix 目录下
make install
```

### 构建ffmpeg-6.1.1.tar.bz2源码
- 编写构建脚本:`build_clangV8a_ndk27.sh`
```sh
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
```
- 更改脚本运行权限并放置到ffmpeg-6.1.1源码目录
```
chmod u+x build_clangV8a_ndk27.sh
mv build_clangV8a_ndk27.sh ffmpeg-6.1.1/
```
- 进入ffmpeg-6.1.1源码目录开始编译
```sh
./build_clangV8a_ndk27.sh
```
- 编译完成后查看输出文件
```
tree -L 4 $HOME/download/ffmpeg-6.1.1/build
```
> 反馈
```sh
/home/book/download/ffmpeg-6.1.1/build
`-- ffmpeg-android
    `-- armv8-a
        |-- include
        |   |-- libavcodec
        |   |-- libavdevice
        |   |-- libavfilter
        |   |-- libavformat
        |   |-- libavutil
        |   |-- libswresample
        |   `-- libswscale
        |-- lib
        |   |-- libavcodec.a
        |   |-- libavdevice.a
        |   |-- libavfilter.a
        |   |-- libavformat.a
        |   |-- libavutil.a
        |   |-- libswresample.a
        |   |-- libswscale.a
        |   `-- pkgconfig
        `-- share
            `-- ffmpeg

14 directories, 7 files
```