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

ADDI_CFLAGS="-march=armv8-a"
ADDI_LDFLAGS="-L$TOOLCHAIN/sysroot/usr/lib"
ADDITIONAL_CONFIG_FLAG="--arch=aarch64 --enable-yasm"

function buildFF {
	# 执行.configure 文件
	echo "开始编译ffmpeg"
	./configure --prefix=${PREFIX} \
		--target-os=android \
		--cross-prefix=${CROSS_PREFIX} \
		--arch=$ARCH \
		--cpu=$CPU \
		--sysroot=$SYSROOT \
		--extra-cflags="-Os -fPIC $ADDI_CFLAGS" \
		--enable-shared \
		--enable-runtime-cpudetect \
		--enable-gpl \
		--enable-small \
		--enable-cross-compile \
		--disable-debug \
		--disable-static \
		--disable-doc \
		--disable-ffmpeg \
		--disable-ffplay \
		--disable-ffprobe \
		--disable-ffserver \
		--disable-postproc \
		--disable-avdevice \
		--disable-symver \
		--disable-stripping
		$ADDITIONAL_CONFIG_FLAG

	# 运行 Makefile
	make -j4

	# 安装到指定 prefix 目录下
	make install
	echo "编译结束"
}

##########################################################################
# 执行编译函数
echo "编译支持neon和硬解码"
PREFIX=$(pwd)/android/$ARCH/$CPU-neon-hard
ADDITIONAL_CONFIG_FLAG="--enable-asm \
                --enable-neon \
                --enable-jni \
                --enable-mediacodec \
                --enable-decoder=h264_mediacodec \
                --enable-hwaccel=h264_mediacodec "
buildFF

##########################################################################
PREFIX=$(pwd)/android/$ARCH/$CPU
ADDI_CFLAGS="-DANDROID -mfloat-abi=softfp -mthumb -mfpu=vfp"
ADDITIONAL_CONFIG_FLAG=
echo "编译不支持neon和硬解码"
buildFF
