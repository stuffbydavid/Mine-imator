#!/usr/bin/env sh
# Usage: ./Setup.sh [Qt|FFmpeg|Libzip|OpenAL|Xcode|Release] [x86_64|arm64]
#   Qt|FFmpeg|Libzip|OpenAL:
#       Unzips or downloads external libraries into DEV_DIR, then builds them
#   Xcode:
#       Generates and opens an Xcode project file
#   Release:
#       Creates a release build and install folder for publishing
#   x86_64|arm64:
#       For Mac OS, sets the target architecture, defaults to system architecture

set -eu

jobs=8  # Parallel threads when building

if [ -z "${DEV_DIR:-}" ]; then
    echo "DEV_DIR is not set. Example: export DEV_DIR=\"$HOME/Dev\"" >&2
    exit 1
fi

if [ "$#" -gt 2 ]; then
    echo "Usage: $0 [Qt|FFmpeg|Libzip|OpenAL|Xcode|Release] [x86_64|arm64]" >&2
    exit 1
fi

action="${1:-Qt}" # Qt is the default action
action_key=$(printf '%s' "$action" | tr '[:upper:]' '[:lower:]')
case "$action_key" in
    qt|ffmpeg|libzip|openal|xcode|release) ;;
    *)
        echo "Unknown action '$action'. Use Qt, FFmpeg, Libzip, OpenAL, Xcode or Release." >&2
        exit 1
        ;;
esac

requested_architecture="${2:-}"

script_root=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd -P)
build_xcode_directory="$script_root/build-xcode"
build_release_directory="$script_root/build-release"
cpp_project_directory="$script_root/CppProject"
external_directory="$cpp_project_directory/External"
source_archive_directory="$external_directory/Sources"

case "$(uname -s)" in
    Darwin)
        platform=macos
        output_directory="$external_directory/Mac"
        macos_arch="${requested_architecture:-$(uname -m)}"
        case "$macos_arch" in
            x86_64) macos_deployment_target=10.15 ;;
            arm64) macos_deployment_target=11.0 ;;
            *)
                echo "Architecture must be x86_64 or arm64 (got: $macos_arch)." >&2
                exit 1
                ;;
        esac
        ;;
    Linux)
        if [ -n "$requested_architecture" ]; then
            echo "The architecture argument is supported only on macOS." >&2
            exit 1
        fi
        platform=linux
        output_directory="$external_directory/Linux"
        ;;
    *)
        echo "Unsupported operating system: $(uname -s)" >&2
        exit 1
        ;;
    esac

qt_version="5.15.19"
qt_ref="${qt_ref:-v${qt_version}-lts-lgpl}"
ffmpeg_version="5.1.10"
x264_revision="0480cb05"
libzip_version="1.11.4"
openal_version="1.24.3"

mkdir -p "$DEV_DIR"
dev_directory=$(cd "$DEV_DIR" && pwd -P)
qt_directory="$dev_directory/Qt/$qt_version"
qt_source_directory="$qt_directory/qt5"
qt_build_directory="$qt_directory/build"
qt_install_directory="$qt_directory/install"
ffmpeg_directory="$dev_directory/FFmpeg/ffmpeg-$ffmpeg_version"
x264_directory="$dev_directory/x264/x264-master"
libzip_directory="$dev_directory/Libzip/libzip-$libzip_version"
openal_directory="$dev_directory/OpenAL/openal-soft-$openal_version"

require_command() {
    if ! command -v "$1" >/dev/null 2>&1; then
        echo "Required command not found: $1" >&2
        exit 1
    fi
}

require_file() {
    if [ ! -f "$1" ]; then
        echo "$2 was not found at $1." >&2
        exit 1
    fi
}

ensure_source_archive() {
    if [ "$#" -eq 0 ]; then
        echo "At least one source library is required." >&2
        exit 1
    fi

    for source_library in "$@"; do
        source_library_key=$(printf '%s' "$source_library" | tr '[:upper:]' '[:lower:]')
        case "$source_library_key" in
            ffmpeg) source_names="ffmpeg x264" ;;
            libzip|openal) source_names=$source_library_key ;;
            *)
                echo "Unknown source library: $source_library" >&2
                exit 1
                ;;
        esac

        for source_name in $source_names; do
            case "$source_name" in
                ffmpeg)
                    archive_name="ffmpeg-$ffmpeg_version.tar.xz"
                    destination_parent="$dev_directory/FFmpeg"
                    target_directory=$ffmpeg_directory
                    source_marker=configure
                    ;;
                x264)
                    archive_name="x264-master-$x264_revision.tar.bz2"
                    destination_parent="$dev_directory/x264"
                    target_directory=$x264_directory
                    source_marker=configure
                    ;;
                libzip)
                    archive_name="libzip-$libzip_version.tar.gz"
                    destination_parent="$dev_directory/Libzip"
                    target_directory=$libzip_directory
                    source_marker=CMakeLists.txt
                    ;;
                openal)
                    archive_name="openal-soft-$openal_version.tar.bz2"
                    destination_parent="$dev_directory/OpenAL"
                    target_directory=$openal_directory
                    source_marker=CMakeLists.txt
                    ;;
            esac

            case "$target_directory" in
                "$ffmpeg_directory"|"$x264_directory"|"$libzip_directory"|"$openal_directory") ;;
                *)
                    echo "Unexpected source directory request: $target_directory" >&2
                    exit 1
                    ;;
            esac

            if [ -d "$target_directory" ]; then
                echo "Source directory already exists: $target_directory"
            else
                if [ -e "$target_directory" ]; then
                    echo "The expected source directory is occupied by a non-directory path: $target_directory" >&2
                    exit 1
                fi

                require_command tar
                archive_path="$source_archive_directory/$archive_name"
                mkdir -p "$destination_parent"
                echo "Extracting $archive_name into $destination_parent"
                tar -xf "$archive_path" -C "$destination_parent"
                if [ ! -d "$target_directory" ]; then
                    echo "$archive_name did not create the expected directory $target_directory." >&2
                    exit 1
                fi
            fi

            require_file "$target_directory/$source_marker" "$archive_name source marker"
        done
    done
}

remove_build_directory() {
    build_directory=$1
    case "$build_directory" in
        "$dev_directory/Qt/"*|\
        "$dev_directory/FFmpeg/"*|\
        "$dev_directory/x264/"*|\
        "$dev_directory/Libzip/"*|\
        "$dev_directory/OpenAL/"*) ;;
        *)
            echo "Refusing to remove unexpected build directory: $build_directory" >&2
            exit 1
            ;;
    esac
    if [ -e "$build_directory" ]; then
        echo "Removing build directory $build_directory"
        rm -rf -- "$build_directory"
    fi
}

remove_cmake_cache() {
    source_directory=$1
    case "$source_directory" in
        "$libzip_directory"|"$openal_directory") ;;
        *)
            echo "Refusing to remove CMake cache files from unexpected source directory: $source_directory" >&2
            exit 1
            ;;
    esac
    for cache_path in "$source_directory/CMakeCache.txt" "$source_directory/CMakeFiles"; do
        if [ -e "$cache_path" ]; then
            echo "Removing generated CMake cache path $cache_path"
            rm -rf -- "$cache_path"
        fi
    done
}

copy_built_file() {
    source_file=$1
    output_directory=$2
    require_file "$source_file" "Built library"
    mkdir -p "$output_directory"
    cp -f "$source_file" "$output_directory/"
    echo "Copied $(basename "$source_file") to $output_directory"
}

build_ffmpeg() {
    for required_command in make nasm yasm pkg-config; do
        require_command "$required_command"
    done
    
    ffmpeg_directory="$dev_directory/FFmpeg/ffmpeg-$ffmpeg_version"
    ffmpeg_build_directory="$ffmpeg_directory/build"
    ffmpeg_install_directory="$ffmpeg_directory/install"
    x264_directory="$dev_directory/x264/x264-master"
    x264_build_directory="$x264_directory/build"
    x264_install_directory="$x264_directory/install"

    remove_build_directory "$x264_build_directory"
    remove_build_directory "$x264_install_directory"
    remove_build_directory "$ffmpeg_build_directory"
    remove_build_directory "$ffmpeg_install_directory"

    mkdir -p "$x264_build_directory" "$ffmpeg_build_directory"

    if [ "$platform" = "macos" ]; then
        case "$macos_arch" in
            x86_64)
                x264_host=x86_64-apple-darwin
                ffmpeg_arch=x86_64
                ;;
            arm64)
                x264_host=aarch64-apple-darwin
                ffmpeg_arch=aarch64
                ;;
        esac
        macos_target="$macos_arch-apple-macos$macos_deployment_target"
        (
            cd "$x264_build_directory"
            ../configure \
                --prefix="$x264_install_directory" \
                --enable-static \
                --disable-cli \
                --host="$x264_host" \
                --extra-cflags="-target $macos_target" \
                --extra-ldflags="-target $macos_target"
            make -j"$jobs"
            make -j1 install
        )
    else
        (
            cd "$x264_build_directory"
            ../configure \
                --prefix="$x264_install_directory" \
                --enable-static \
                --disable-cli
            make -j"$jobs"
            make -j1 install
        )
    fi

    set -- \
        --prefix="$ffmpeg_install_directory" \
        --disable-autodetect \
        --disable-debug \
        --disable-everything \
        --disable-programs \
        --disable-avdevice \
        --disable-avfilter \
        --disable-postproc \
        --disable-network \
        --disable-doc \
        --disable-htmlpages \
        --disable-vaapi \
        --disable-vdpau \
        --disable-sndio \
        --disable-gnutls \
        --enable-protocol=file \
        "--enable-parser=vorbis,opus,flac,mpegaudio,aac*,h264" \
        "--enable-decoder=mp3,vorbis,opus,flac,wma*,pcm*,mpeg4,aac*" \
        "--enable-demuxer=mp3,wav,ogg,flac,xwma,asf,aac,m*" \
        "--enable-encoder=libx264,wma*,aac*,msmpeg4v*" \
        "--enable-muxer=mp4,mov,asf,h264" \
        --enable-libx264 \
        --enable-gpl \
        --pkg-config-flags=--static
    if [ "$platform" = "macos" ]; then
        set -- "$@" \
            --arch="$ffmpeg_arch" \
            --extra-cflags="-arch $macos_arch -mmacosx-version-min=$macos_deployment_target" \
            --extra-ldflags="-arch $macos_arch -mmacosx-version-min=$macos_deployment_target"
    fi

    (
        cd "$ffmpeg_build_directory"
        export PKG_CONFIG_PATH="$x264_install_directory/lib/pkgconfig"
        ../configure "$@"
        make -j"$jobs"
        make -j1 install
    )

    copy_built_file "$x264_install_directory/lib/libx264.a" "$output_directory"
    for library in libavcodec.a libavformat.a libavutil.a libswresample.a libswscale.a; do
        copy_built_file "$ffmpeg_install_directory/lib/$library" "$output_directory"
    done
}

build_libzip() {
    require_command cmake
    qt_core_library="$qt_install_directory/lib/libQt5Core.a"
    require_file "$qt_core_library" "Qt Core static library"

    libzip_directory="$dev_directory/Libzip/libzip-$libzip_version"
    build_directory="$libzip_directory/build"

    remove_cmake_cache "$libzip_directory"
    remove_build_directory "$build_directory"

    set -- \
        -S "$libzip_directory" -B "$build_directory" -G "Unix Makefiles" \
        -DCMAKE_BUILD_TYPE=Release \
        "-DZLIB_INCLUDE_DIR=$qt_install_directory/include/QtZlib" \
        "-DCMAKE_C_STANDARD_INCLUDE_DIRECTORIES=$qt_install_directory/include;$qt_install_directory/include/QtCore" \
        "-DZLIB_LIBRARY=$qt_core_library" \
        -DENABLE_BZIP2=OFF -DENABLE_LZMA=OFF -DENABLE_ZSTD=OFF \
        -DBUILD_DOC=OFF -DBUILD_EXAMPLES=OFF -DBUILD_OSSFUZZ=OFF -DBUILD_REGRESS=OFF \
        -DBUILD_SHARED_LIBS=OFF -DBUILD_TOOLS=OFF -DHAVE_ARC4RANDOM=OFF
    if [ "$platform" = "macos" ]; then
        set -- "$@" \
            "-DCMAKE_OSX_DEPLOYMENT_TARGET=$macos_deployment_target" \
            "-DCMAKE_OSX_ARCHITECTURES=$macos_arch"
    fi
    cmake "$@"
    cmake --build "$build_directory" --parallel "$jobs"
    copy_built_file "$build_directory/lib/libzip.a" "$output_directory"
}

build_openal() {
    require_command cmake
    
    openal_directory="$dev_directory/OpenAL/openal-soft-$openal_version"
    build_directory="$openal_directory/build"

    remove_cmake_cache "$openal_directory"
    remove_build_directory "$build_directory"

    set -- \
        -S "$openal_directory" -B "$build_directory" -G "Unix Makefiles" \
        -DCMAKE_BUILD_TYPE=Release -DLIBTYPE=STATIC \
        -DALSOFT_EXAMPLES=OFF -DALSOFT_UTILS=OFF -DALSOFT_EAX=OFF \
        -DALSOFT_EMBED_HRTF_DATA=OFF
    if [ "$platform" = "macos" ]; then
        set -- "$@" \
            "-DCMAKE_OSX_DEPLOYMENT_TARGET=$macos_deployment_target" \
            "-DCMAKE_OSX_ARCHITECTURES=$macos_arch"
    fi
    cmake "$@"
    cmake --build "$build_directory" --parallel "$jobs"
    copy_built_file "$build_directory/libopenal.a" "$output_directory"
}

build_qt() {
    for required_command in git perl make clang clang++; do
        require_command "$required_command"
    done

    case "$platform" in
        macos) qt_platform=macx-clang ;;
        linux) qt_platform=linux-clang ;;
    esac

    mkdir -p "$qt_directory"
    if [ ! -d "$qt_source_directory" ]; then
        echo "Cloning Qt $qt_ref for $platform into $qt_source_directory"
        git clone --branch "$qt_ref" --depth 1 https://code.qt.io/qt/qt5.git "$qt_source_directory"
    else
        require_file "$qt_source_directory/.git/HEAD" "Existing Qt Git checkout"
        current_qt_commit=$(git -C "$qt_source_directory" rev-parse HEAD)
        requested_qt_commit=$(git -C "$qt_source_directory" rev-parse "${qt_ref}^{commit}") || {
            echo "The existing Qt checkout does not contain $qt_ref." >&2
            exit 1
        }
        if [ "$current_qt_commit" != "$requested_qt_commit" ]; then
            echo "Existing Qt source is at $current_qt_commit, not $qt_ref " \
                "($requested_qt_commit). Move it aside or select the matching " \
                "qt_ref; it will not be deleted automatically." >&2
            exit 1
        fi
        echo "Reusing existing Qt source directory $qt_source_directory"
    fi

    if [ ! -f "$qt_source_directory/qtbase/configure" ]; then
        (cd "$qt_source_directory" && perl init-repository --module-subset=qtbase)
    fi
    
    remove_build_directory "$qt_build_directory"
    remove_build_directory "$qt_install_directory"
    mkdir -p "$qt_build_directory"

    set -- \
        -platform "$qt_platform" \
        -prefix "$qt_install_directory" \
        -opensource -confirm-license \
        -release -static \
        -opengl desktop \
        -qt-libpng -qt-libjpeg -qt-zlib -qt-harfbuzz -qt-pcre -qt-doubleconversion \
        -no-feature-textmarkdownreader -no-feature-textmarkdownwriter -no-feature-bearermanagement \
        -no-libinput -no-libmd4c -no-icu -no-dbus -no-glib -no-cups \
        -nomake tests -nomake examples -nomake tools

    if [ "$platform" = "macos" ]; then
        set -- "$@" \
            "QMAKE_APPLE_DEVICE_ARCHS=$macos_arch" \
            "QMAKE_MACOSX_DEPLOYMENT_TARGET=$macos_deployment_target"
    else
        set -- "$@" \
            -openssl-linked -xcb -xcb-xlib -bundled-xcb-xinput
    fi

    (
        cd "$qt_build_directory"
        "$qt_source_directory/configure" "$@"
        make -j"$jobs"
        make install
    )
    echo "Qt $qt_ref for $platform was installed to $qt_install_directory"
}

case "$action_key" in
    qt)
        ensure_source_archive FFmpeg OpenAL Libzip
        build_qt
        ;;
    ffmpeg)
        ensure_source_archive FFmpeg
        build_ffmpeg
        ;;
    libzip)
        ensure_source_archive Libzip
        build_libzip
        ;;
    openal)
        ensure_source_archive OpenAL
        build_openal
        ;;
    xcode)
        cmake \
            -S "$cpp_project_directory" -B "$build_xcode_directory" -G "Xcode" \
            -DCMAKE_OSX_ARCHITECTURES=$macos_arch
        open "$build_xcode_directory/Mine-imator.xcodeproj"
        ;;
    release)
        if [ "$platform" = "macos" ]; then
            cmake \
                -S "$cpp_project_directory" -B "$build_release_directory" \
                -G "Unix Makefiles" -DCMAKE_BUILD_TYPE=Release \
                -DCMAKE_OSX_ARCHITECTURES=$macos_arch
        else
            cmake \
                -S "$cpp_project_directory" -B "$build_release_directory" \
                -G "Unix Makefiles" -DCMAKE_BUILD_TYPE=Release
        fi
        cmake \
            --build "$build_release_directory" \
            --parallel "$jobs"
        cmake \
            --install "$build_release_directory"
        ;;
esac