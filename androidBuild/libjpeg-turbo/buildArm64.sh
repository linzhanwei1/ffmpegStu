#!/bin/bash
NDK_PATH=/home/book/download/android-ndk-r16b
TOOLCHAIN="clang"  # 对于NDK r17c及以上版本使用clang
ANDROID_VERSION=21 # 最低支持版本，64位需21+
BUILD_DIR=build_android
SRC_DIR=$(pwd)
INSTALL_DIR=${SRC_DIR}/install_android_arm64

# 清理旧构建产物（可选，确保编译纯净）
# rm -rf ${BUILD_DIR} ${INSTALL_DIR}
# mkdir -p ${BUILD_DIR}
# cd ${BUILD_DIR}


cmake -G"Unix Makefiles" \
  -DANDROID_ABI=arm64-v8a \
  -DANDROID_ARM_MODE=arm \
  -DANDROID_PLATFORM=android-${ANDROID_VERSION} \
  -DANDROID_TOOLCHAIN=${TOOLCHAIN} \
  -DCMAKE_ASM_FLAGS="--target=aarch64-linux-android${ANDROID_VERSION}" \
  -DCMAKE_TOOLCHAIN_FILE=${NDK_PATH}/build/cmake/android.toolchain.cmake \
  -DCMAKE_INSTALL_PREFIX=${INSTALL_DIR} \
  -DWITH_SIMD=ON \
  -DANDROID_ARM_NEON=ON \
  #-DCMAKE_C_FLAGS="-O3 -mfpu=neon" \
  # C 编译参数：低 CPU 占比 + 高性能平衡
  -DCMAKE_C_FLAGS="-O3 -ffast-math -fstrict-aliasing" \
  # ASM  flags：适配 arm64-v8a 汇编指令集 \
  -DCMAKE_ASM_FLAGS="--target=aarch64-linux-android${ANDROID_VERSION} -march=armv8-a+neon" \
  -DENABLE_SHARED=ON \  # 生成动态库（车机工程通常用动态库，内存占用更低）
  -DENABLE_STATIC=ON \ # 禁用静态库（按需开启，动态库更适合车机多模块共享）
  -DWITH_JPEG7=ON \     # 启用 jpeg7 兼容，支持更多车机摄像头 MJPEG 格式
  -DWITH_JPEG8=ON \     # 支持 progressive JPEG（部分车机摄像头输出此格式）
  -DENABLE_JAVA=OFF \    # 禁用 Java 绑定（纯 C/C++ 工程，降低库体积）
  ${SRC_DIR}

  # 并行编译（加速构建，线程数 = CPU 核心数，避免编译阻塞）
  make -j$(nproc)
  # 安装到指定目录（生成 libturbojpeg.so + 头文件）
  make install

  echo "编译完成！产物路径："
  echo "库文件：${INSTALL_DIR}/lib/libturbojpeg.so"
  echo "头文件：${INSTALL_DIR}/include/turbojpeg.h"
