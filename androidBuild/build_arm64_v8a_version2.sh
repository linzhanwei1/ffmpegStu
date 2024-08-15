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
# ARCH=arm
ARCH=aarch64
CPU=armv8-a
PREFIX=$(pwd)/android/$ARCH/$CPU
NDK_PATH=/home/book/download/android-ndk-r16b

# ANDROID_TOOLCHAINS_PATH=${NDK_PATH}/android-toolchains/android-19/arch-arm
ANDROID_TOOLCHAINS_PATH=${NDK_PATH}/android-toolchains/android-21/$ARCH
# CROSS_PREFIX=${ANDROID_TOOLCHAINS_PATH}/bin/arm-linux-androideabi-
CROSS_PREFIX=${ANDROID_TOOLCHAINS_PATH}/bin/aarch64-linux-android-
SYSROOT=${ANDROID_TOOLCHAINS_PATH}/sysroot

ADDI_CFLAGS=""
ADDI_LDFLAGS="-L$TOOLCHAIN/sysroot/usr/lib"
ADDITIONAL_CONFIG_FLAG="--arch=aarch64 --enable-yasm"

# 执行.configure 文件
./configure --prefix=${PREFIX} \
	--enable-gpl \
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
	--extra-cflags="-Os $ADDI_CFLAGS" \
	--extra-ldflags="$ADDI_LDFLAGS" \
	--enable-yasm \

# 运行 Makefile
make clean
make -j4 V=1

# 安装到指定 prefix 目录下
make install

# 合并多个.a生成1个.so
cd ${PREFIX}/lib
${CROSS_PREFIX}gcc --sysroot=${PLATFORM_SYSROOT} -shared -o libffmpeg_3.4.13.so -Wl,--whole-archive *.a -Wl,--no-whole-archive
