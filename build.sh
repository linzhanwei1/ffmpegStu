basepath=$(cd `dirname $0`; pwd)

echo ${basepath}

# 编译SDL库
cd ${basepath}/SDL-release-2.0.18
#./configure --prefix=${basepath}/sdl_install_x86
#make -j4 && make install
export PKG_CONFIG_PATH=${basepath}/sdl_install_x86/lib/pkgconfig:$PKG_CONFIG_PATH
echo ${PKG_CONFIG_PATH}

# 编译x264
cd ${basepath}/x264-master
pwd

# 32位需要关闭线程不然编译过不了
#./configure --prefix=${basepath}/x264_install_x86 --enable-static --disable-thread

# 64位
#./configure --prefix=${basepath}/x264_install_x86 --enable-static
#make -j4 && make install

cd ${basepath}

export PKG_CONFIG_PATH=${basepath}/x264_install_x86/lib/pkgconfig:$PKG_CONFIG_PATH
echo ${PKG_CONFIG_PATH}

# 编译ffmpeg-4.4.1
./configure --prefix=${basepath}/ffmpeg-4.4.1_install_x86 --enable-gpl --enable-shared --enable-sdl2 --enable-libx264 \


#./configure --prefix=${basepath}/ffmpeg-4.4.1_install_x86 --enable-gpl --enable-shared --enable-sdl2 --enable-libx264 \
#--extra-cflags="-l${basepath}/sdl_install_x86/include -l${basepath}/x264_install_x86/include" \
#--extra-ldflags="-L${basepath}/sdl_install_x86/lib -L${basepath}/x264_install_x86/lib"

#make -j4 && make install