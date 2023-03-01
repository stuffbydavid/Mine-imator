**Links:**
* CMake GUI: https://cmake.org/download/
* Python: https://www.python.org/downloads/
* Strawberry Perl: https://strawberryperl.com/
* OpenSSL Windows installer: https://slproweb.com/download/Win64OpenSSL-3_0_5.msi (64 bit), https://slproweb.com/download/Win32OpenSSL-3_0_5.msi (32 bit)
* FFmpeg 5.0 sources: http://www.ffmpeg.org/releases/ffmpeg-5.0.tar.xz
* x264 sources: https://code.videolan.org/videolan/x264/-/archive/master/x264-master.tar.bz2
* Zlib 1.2.11 sources: https://zlib.net/zlib-1.2.12.tar.gz
* Libzip 1.9.2 sources: https://libzip.org/download/libzip-1.9.2.tar.gz
* FreeType 2.9.1 sources: https://download.savannah.gnu.org/releases/freetype/freetype-2.9.1.tar.gz (only header is used, library comes with Qt)
* OpenAL Soft 1.22.0 sources: https://openal-soft.org/openal-releases/openal-soft-1.22.0.tar.bz2
* Jom: https://download.qt.io/official_releases/jom/jom_1_1_3.zip
* NASM: https://www.nasm.us/pub/nasm/releasebuilds/2.15.05/win64/

This setup stores libraries in C:\Dev for Windows and ~\Dev for Mac/Linux.
For new developers Qt must be built, the other libraries are pre-built for each platform in /External.

**Build setup (Windows 64-bit):**
1. Set the environment variable DEV_DIR to C:\Dev
2. Get Visual Studio 2022
    1. Install Desktop development with C++
    2. Install MFC for latest v143 build tools (x86 & x64)
3. Get Python and install (When asked, add to PATH)
4. Get Strawberry Perl
5. Get CMake GUI
6. Get OpenSSL for 64-bit
    * Install into C:\Dev\OpenSSL
    * When asked, select to copy DLLs to "bin"
2. Get Jom, extract into C:\Dev\Jom and add folder to PATH
7. Get Qt, create folder C:/Dev/Qt/5.15.9
    1. Open x64 Native Tools Command Prompt for VS 2022 as Administrator
    2. `cd %DEV_DIR%/Qt/5.15.9`
    3. `git clone git://code.qt.io/qt/qt5.git`
    4. `cd qt5`
    5. `git checkout 5.15`
    6. `perl init-repository`
    7. `configure.bat -platform win32-msvc -prefix "%DEV_DIR%/Qt/5.15.9/build" -opensource -confirm-license -release -static -static-runtime -qt-libjpeg -opengl desktop -openssl-linked -I"%DEV_DIR%/OpenSSL/include" -L"%DEV_DIR%/OpenSSL/lib/VC/static" OPENSSL_LIBS="-lWs2_32 -lGdi32 -lAdvapi32 -lCrypt32 -lUser32" OPENSSL_LIBS_DEBUG="-llibssl64MDd -llibcrypto64MDd" OPENSSL_LIBS_RELEASE="-llibssl64MT -llibcrypto64MT" -no-icu -nomake tests -nomake examples -nomake tools -skip qt3d -skip qtmultimedia -skip activeqt -skip qtandroidextras -skip qtconnectivity -skip datavis3d -skip qtdoc -skip gamepad -skip qtgraphicaleffects -skip qtcharts -skip qtlocation -skip qtlottie -skip qtnetworkauth -skip qtpurchasing -skip qtquick3d -skip qtquickcontrols -skip qtquickcontrols2 -skip qtquicktimeline -skip qtremoteobjects -skip qtscxml -skip qtsensors -skip qtserialbus -skip qtserialport -skip qtspeech -skip qtvirtualkeyboard -skip qtwayland -skip qtwebengine -skip qtwebglplugin -skip qtwebchannel -skip qtwebsockets -skip qtwebview -skip qtxmlpatterns`
    8. `jom` then `jom install`
7. Get Libzip sources, extract into C:\Dev\Libzip\libzip-1.9.2
8. Get FreeType sources, put in C:\Dev\FreeType\freetype-2.9.1
9. Get FFmpeg sources, put in C:\Dev\FFmpeg\ffmpeg-5.0
10. Get OpenAL sources, put in C:\Dev\OpenAL\openal-soft-1.22.0
11. Generate VS project
    1. Open CMake GUI, select "Where is the source code" to the CppProject folder
    2. Select "Where to build the binaries" to a chosen output folder
    3. Configure for Visual Studio 17 2022
    4. Generate and Open Project
    5. Copy datafiles contents into the build folder
12. Build in Debug or Release mode

**Build setup (Windows 32-bit):**

Follow 64-bit instructions with additional steps:
1. Get OpenSSL for 32-bit
    * Install into C:/Dev/OpenSSL-Win32
    * When asked, select to copy DLLs to "bin"
2. Get Qt, create folder C:/Dev/Qt/5.15.9-Win32
    1. Open x86 Native Tools Command Prompt for VS 2022 as Administrator
    2. `cd %DEV_DIR%/Qt/5.15.9-Win32`
    3. Same as step 8.3-8.6 for 64-bit
    4. `configure.bat -platform win32-msvc -prefix "%DEV_DIR%/Qt/5.15.9-Win32/build" -opensource -confirm-license -release -static -static-runtime -qt-libjpeg -opengl desktop -openssl-linked -I"%DEV_DIR%/OpenSSL-Win32/include" -L"%DEV_DIR%/OpenSSL-Win32/lib/VC/static" OPENSSL_LIBS="-lWs2_32 -lGdi32 -lAdvapi32 -lCrypt32 -lUser32" OPENSSL_LIBS_DEBUG="-llibssl32MDd -llibcrypto32MDd" OPENSSL_LIBS_RELEASE="-llibssl32MT -llibcrypto32MT" -no-icu -nomake tests -nomake examples -nomake tools -skip qt3d -skip qtmultimedia -skip activeqt -skip qtandroidextras -skip qtconnectivity -skip datavis3d -skip qtdoc -skip gamepad -skip qtgraphicaleffects -skip qtcharts -skip qtlocation -skip qtlottie -skip qtnetworkauth -skip qtpurchasing -skip qtquick3d -skip qtquickcontrols -skip qtquickcontrols2 -skip qtquicktimeline -skip qtremoteobjects -skip qtscxml -skip qtsensors -skip qtserialbus -skip qtserialport -skip qtspeech -skip qtvirtualkeyboard -skip qtwayland -skip qtwebengine -skip qtwebglplugin -skip qtwebchannel -skip qtwebsockets -skip qtwebview -skip qtxmlpatterns`
3. Generate VS project
    * Same as 64-bit, except set WINDOWS_32BIT to 1 in CMakeLists.txt and delete cache before configuring, then restart VS 2022

**Build setup (Mac):**
1. Get CMake GUI
2. Install Xcode, open and agree to license
3. Get HomeBrew `/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"`
4. Get Qt, create folder ~/Dev/Qt/5.15.9
    1. `cd ~/Dev/Qt/5.15.9`
    2. `git clone git://code.qt.io/qt/qt5.git`
    3. `cd qt5`
    4. `git checkout 5.15`
    5. `./init-repository`
    6. Apply patch https://codereview.qt-project.org/c/qt/qtbase/+/378706/2/src/plugins/platforms/cocoa/qiosurfacegraphicsbuffer.h
    7. `sudo ./configure -platform macx-clang -prefix "../build" -opensource -confirm-license -release -static -static-runtime -qt-libjpeg -opengl desktop -no-openssl -securetransport -no-icu -nomake tests -nomake examples -nomake tools -skip qt3d -skip qtmultimedia -skip activeqt -skip qtandroidextras -skip qtconnectivity -skip datavis3d -skip qtdoc -skip gamepad -skip qtgraphicaleffects -skip qtcharts -skip qtlocation -skip qtlottie -skip qtnetworkauth -skip qtpurchasing -skip qtquick3d -skip qtquickcontrols -skip qtquickcontrols2 -skip qtquicktimeline -skip qtremoteobjects -skip qtscxml -skip qtsensors -skip qtserialbus -skip qtserialport -skip qtspeech -skip qtvirtualkeyboard -skip qtwayland -skip qtwebengine -skip qtwebglplugin -skip qtwebchannel -skip qtwebsockets -skip qtwebview -skip qtxmlpatterns`
    8. `sudo make -j8`
    9. `sudo make -j1 install`
5. Get Libzip sources into ~/Dev/Libzip/libzip-1.9.2
6. Get FreeType sources into ~/Dev/FreeType/freetype-2.9.1
7. Get FFmpeg sources, put in ~/Dev/FFmpeg/ffmpeg-5.0
	* Remove VERSION file
8. Get OpenAL sources, put in ~/Dev/OpenAL/openal-soft-1.22.0
9. Get OpenMP `brew install libomp`
10. Generate Xcode project
    * "XCode 1.5 not supported" -> `sudo xcode-select --switch ~/Downloads/Xcode.app`
    * "CXX compiler not found" -> `sudo xcode-select --reset`

**Build setup (Ubuntu)**
1. `sudo apt update`
2. `sudo apt install build-essential git gcc-multilib g++-multilib mesa-utils mesa-common-dev libbz2-dev libomp-12-dev clang-12 lldb -y`
3. Get CMake GUI, extract into ~/Dev/Cmake
4. Get Code::Blocks `sudo apt install codeblocks`
5. Get Qt, create folder ~/Dev/Qt/5.15.9
    1. `software-properties-gtk` -> Enable "Source Code"
    2. `sudo apt-get build-dep qt5-default`
    3. `cd ~/Dev/Qt/5.15.9`
    4. `git clone git://code.qt.io/qt/qt5.git`
    5. `cd qt5`
    6. `git checkout 5.15`
    7. `./init-repository`
    8. Apply patch https://bugreports.qt.io/browse/QTBUG-85922 in qtbase/mkspecs/linux-g++-64/qmake.conf
    9. `sudo ./configure -platform linux-g++-64 -prefix "../Build" -opensource -confirm-license -release -static -static-runtime -xcb -xcb-xlib -bundled-xcb-xinput -qt-libjpeg -opengl desktop -openssl-linked -no-icu -nomake tests -nomake examples -nomake tools -skip qt3d -skip qtmultimedia -skip activeqt -skip qtandroidextras -skip qtconnectivity -skip datavis3d -skip qtdoc -skip gamepad -skip qtgraphicaleffects -skip qtcharts -skip qtlocation -skip qtlottie -skip qtnetworkauth -skip qtpurchasing -skip qtquick3d -skip qtquickcontrols -skip qtquickcontrols2 -skip qtquicktimeline -skip qtremoteobjects -skip qtscxml -skip qtsensors -skip qtserialbus -skip qtserialport -skip qtspeech -skip qtvirtualkeyboard -skip qtwayland -skip qtwebengine -skip qtwebglplugin -skip qtwebchannel -skip qtwebsockets -skip qtwebview -skip qtxmlpatterns`
    10. `sudo make -j8`
    11. `sudo make -j1 install`
6. Get Libzip sources into ~/Dev/Libzip/libzip-1.9.2
7. Get FreeType sources into ~/Dev/FreeType/freetype-2.9.1
8. Get FFmpeg sources, put in ~/Dev/FFmpeg/ffmpeg-5.0
9. Get OpenAL sources, put in ~/Dev/OpenAL/openal-soft-1.22.0
10. Generate Code::Blocks project
    1. Settings > Compiler... > LLVM Clang Compiler > Toolchain executables tab 
        1. Compiler's installation directory `/usr/bin`
        2. C Compiler `clang-12`
        3. C++ Compiler `clang++-12`
    2. Build > Select target > Mine-imator
    3. Right click Workspace > "Disable Categorize by file types"

**Building FFmpeg + x264 (Windows 64-bit)**
1. Get FFmpeg sources, extract into C:\Dev\FFmpeg\ffmpeg-5.0
    * Apply patch: https://stackoverflow.com/a/62093711/2229164
2. Get x264 sources, extract into C:\Dev\x264\x264-master
3. Get msys 1.0 + msys-libintl + msys-libiconv with MinGW-Get
4. Put pr.exe from http://gnuwin32.sourceforge.net/downlinks/coreutils-bin-zip.php into C:\Dev\MinGW\msys\1.0\bin
5. Get NASM, extract to C:\Dev\NASM and add to PATH
6. Open x64 VS Developer console and run `%DEV_DIR%\MinGW\msys\1.0\msys.bat`
7. `cd $DEV_DIR/x264/x264-master`
8. `CC=cl ./configure --prefix=build/ --enable-static`
9. `make && make install`
10. `cd $DEV_DIR/FFmpeg/ffmpeg-5.0`
11. `./configure --toolchain=msvc --arch=x86_64 --prefix=build/ --disable-debug --disable-everything --disable-programs --disable-avdevice --disable-avfilter --disable-vaapi --disable-postproc --disable-network --disable-doc --disable-htmlpages --enable-protocol=file --enable-parser=vorbis,opus,flac,mpegaudio,aac*,h264 --enable-decoder=mp3,vorbis,opus,flac,wma*,pcm*,mpeg4,aac* --enable-demuxer=mp3,wav,ogg,flac,xwma,asf,aac,m* --enable-encoder=libx264,wma*,aac*,msmpeg4v* --enable-muxer=mp4,mov,asf,h264 --enable-libx264 --enable-gpl --extra-ldflags=-LIBPATH:$DEV_DIR/x264/x264-master/build/lib --extra-cflags=-I$DEV_DIR/x264/x264-master/build/include`
12. `make -j8 && make -j1 install`

**Building FFmpeg + x264 (Windows 32-bit)**
1. Open x86 VS Developer console
2. Same as 64-bit, change `build` to `build-Win32` and `x86_64` to `x86_32` in commands

**Building FFmpeg (Mac)**
https://trac.ffmpeg.org/wiki/CompilationGuide/macOS#CompilingFFmpegyourself
1. Get FFmpeg sources, extract into ~/FFmpeg/ffmpeg-5.0
2. `xcode-select --install`
3. `brew install automake fdk-aac git lame libass libtool libvorbis libvpx opus sdl shtool texi2html theora wget x264 x265 xvid nasm`
4. `cd ~/Dev/FFmpeg/ffmpeg-5.0`
5. `./configure --arch=x86_64 --prefix=build/ --disable-debug --disable-everything --disable-programs --disable-avdevice --disable-avfilter --disable-vaapi --disable-postproc --disable-network --disable-doc --disable-htmlpages --enable-protocol=file --enable-parser='vorbis,opus,flac,mpegaudio,aac*,h264' --enable-decoder='mp3,vorbis,opus,flac,wma*,pcm*,mpeg4,aac*' --enable-demuxer='mp3,wav,ogg,flac,xwma,asf,aac,m*' --enable-encoder='libx264,wma*,aac*,msmpeg4v*' --enable-muxer='mp4,mov,asf,h264' --enable-libx264 --enable-gpl`
6. `sudo make -j8 && sudo make -j1 install`

Use libx264.a found in /usr/local/Cellar/x264/r3095

**Building FFmpeg (Ubuntu)**
https://trac.ffmpeg.org/wiki/CompilationGuide/Ubuntu
1. Get FFmpeg sources, extract into ~/FFmpeg/ffmpeg-5.0
2. `sudo apt install autoconf automake build-essential libass-dev libfreetype6-dev libgnutls28-dev libmp3lame-dev libsdl2-dev libtool libva-dev libvdpau-dev libvorbis-dev libxcb1-dev libxcb-shm0-dev libxcb-xfixes0-dev meson ninja-build pkg-config texinfo wget yasm zlib1g-dev libunistring-dev libaom-dev -y`
3. Same as Mac 4-6

**Building ZLib/Libzip/OpenAL Soft (Windows 64-bit)**
1. Configure VS 17 2022 project into /build or /build-Win32
    * Libzip:
        * Disable all BUILD_ parameters
        * Add `SET(ZLIB_LIBRARY "C:/Dev/zlib/zlib-1.2.11")` to CMakeLists.txt
    * OpenAL:
        * Disable ALSOFT_UTILS, ALSOFT_EXAMPLES
        * Set CMAKE_BUILD_TYPE to Release
        * Add LIBTYPE string entry as STATIC
2. Generate and open VS Studio solution and build for Release
    * Set Runtime Library to /MT for libzip (zip) and zlibstatic (zlibstatic) projects
    
**Building ZLib/Libzip/OpenAL Soft (Windows 32-bit)**
1. Add `set(CMAKE_GENERATOR_PLATFORM Win32)` to the top of CMakeLists.txt
2. Same as 64-bit

**Building ZLib/Libzip/OpenAL Soft (Mac/Linux)**
1. Configure and Generate Unix Makefiles with Cmake into /build, same CMake settings as Windows
2. `cd` into /build
3. `sudo make && make install`