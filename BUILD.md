# Mine-imator build guide
This guide uses the following folders on Windows:
* Mine-imator repo: `C:\Dev\Mine-imator`
* Third-party libraries: `C:\Dev\...`

For Mac OS/Linux:
* Mine-imator repo: `~/Dev/Mine-imator`
* Third-party libraries: `~/Dev/...`

To change the third-party source code location, set the `DEV_DIR` environment variable. To avoid command-length issues with Qt, it's recommended to be a short path.

## Building Mine-imator (Windows 64-bit)
1. Set up environment and `DEV_DIR` variable
    1. Open command prompt (via Start menu, right click and run as Administrator)
    2. Run `powershell -Command "Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force"` to enable PowerShell scripts.
    3. Run `setx DEV_DIR "C:\Dev" /M`
    4. Run `mkdir C:\Dev`
2. Get Visual Studio from https://visualstudio.microsoft.com/ (2022 or 2026)
    1. Under "Workloads", select "Desktop development with C++"
    2. Under "Individual Components", search for "Git for Windows" and select it
    3. Click "Install"
3. Get Strawberry Perl from https://strawberryperl.com/
4. Open Windows PowerShell (via Start menu)
5. Get Mine-imator sources
    1. Run `cd $env:DEV_DIR`
    2. Run `git clone https://github.com/stuffbydavid/Mine-imator.git`
    3. Run `cd Mine-imator`
6. Set up external libraries and build Qt
    * Run `.\Setup.ps1`
7. Generate Visual Studio project for debugging **(recommended)**
    1. Run `.\Setup.ps1 VisualStudio`
    2. The generated Mine-imator solution will open in Visual Studio
    3. To debug Qt types, install Qt Visual Studio Tools from Extensions > Manage Extensions **(recommended)**
        * Add `C:\Dev\Qt\5.15.19\install\bin\qmake.exe` to Tools > Options > Qt > Versions
    4. Run in Debug or RelWithDebInfo mode
8. After GML changes
    1. Right-click and build the `CppGen` target in Visual Studio
    2. Alternatively, run `.\Setup.ps1 CppGen` or `CppGen.exe` in the `CppGen\Win64\` folder
    3. The `.gml` files in `GmProject` are converted to C++ in `CppProject\Generated\`
    4. **Note**: These resulting `.cpp` files should not be manually edited!
9. Generate Release build in `install\`
    * Run `.\Setup.ps1 Release`

## Building Mine-imator (Mac OS Intel)
1. Open terminal (⌘+Space and type terminal)
2. Set up environment and `DEV_DIR` variable
    1. Run `xcode-select --install`
    2. Run `/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"`
    3. Run `brew install cmake libomp`
    4. Run `export DEV_DIR=$HOME/Dev`, optionally add as a permanent environment variable: [See guide](https://phoenixnap.com/kb/set-environment-variable-mac) **(recommended)**
    5. Run `mkdir -p $DEV_DIR`
3. Get Mine-imator sources
    1. Run `cd $DEV_DIR`
    2. Run `git clone https://github.com/stuffbydavid/Mine-imator.git`
    3. Run `cd Mine-imator`
4. Set up external libraries and build Qt
    * Run `./Setup.sh`
5. Generate Xcode project for debugging **(recommended)**
    1. Install Xcode from the App Store into `/Applications`
    2. Run `sudo xcode-select -s /Applications/Xcode.app/Contents/Developer`
    3. Run `sudo xcodebuild -license accept`
    4. Run `sudo xcodebuild -runFirstLaunch`
    5. Run `./Setup.sh Xcode`
    6. The generated Mine-imator project file will open in Xcode
    7. Build project (⌘+B) or run (⌘+R)
6. After GML changes
    1. In Xcode, select the `CppGen` Scheme next to "My Mac"
    2. Run (⌘+R)
    3. Alternatively, run `./Setup.sh CppGen` or `./CppGen` in the `CppGen/Mac/` folder
    4. The `.gml` files in `GmProject` are converted to C++ in `CppProject/Generated/`
    5. **Note**: These resulting `.cpp` files should not be manually edited!
7. Generate release build in `install/`
    * Run `./Setup.sh Release`

## Building Mine-imator (Mac OS ARM)
**Note**: Mine-imator has not been officially built or tested on the ARM architecture.
1. Follow steps 1-4 for Mac OS Intel setup
2. Run `brew install nasm yasm pkg-config`
3. Build libraries for Mac OS ARM
    1. Run `./Setup.sh FFmpeg`
    2. Run `./Setup.sh Libzip`
    3. Run `./Setup.sh OpenAL`
4. Follow steps 5-7 for Mac OS Intel setup

## Building Mine-imator (Linux)
1. Open terminal
2. Install build dependencies
    * **Ubuntu**: Run `sudo apt update && sudo apt-get install -y software-properties-common && sudo add-apt-repository -y --enable-source --enable-source && sudo apt build-dep -y qtbase5-dev && sudo apt install -y git cmake perl clang libomp-dev`
    * **Debian/Linux Mint**: [Enable Source Code Repositories](https://wiki.debian.org/SourcesList), then run `sudo apt build-dep -y qtbase5-dev && sudo apt install -y git cmake perl clang libomp-dev`
    * **Fedora**: Run `sudo dnf install -y dnf-plugins-core && sudo dnf builddep -y qt5-qtbase && sudo dnf install -y git cmake perl clang libomp-devel`
    * **Arch Linux/CachyOS**: Run `sudo pacman -Syu --needed --noconfirm base-devel git cmake perl clang openmp`
3. Set up `DEV_DIR` variable
    1. Run `export DEV_DIR=$HOME/Dev`, optionally add as a permanent environment variable: [See guide](https://contabo.com/blog/how-to-set-and-list-linux-environment-variables/) **(recommended)**
    2. Run `mkdir -p $DEV_DIR`
4. Get Mine-imator sources
    1. Run `cd $DEV_DIR`
    2. Run `git clone https://github.com/stuffbydavid/Mine-imator.git`
    3. Run `cd Mine-imator`
5. Set up external libraries and build Qt
    * Run `./Setup.sh`
6. Use Visual Studio Code project for debugging **(recommended)**
    1. Get Visual Studio Code from https://code.visualstudio.com/
    2. Run `code CppProject` to open the Mine-imator C++ project
    3. Turn off Restricted Mode if needed (Click "Manage" at the top, then "Trust")
    4. Install the **C/C++** and **CMake Tools** extensions from Microsoft (Ctrl+Shift+X)
    5. Run command `CMake: Select a Kit` (Ctrl+Shift+P) and choose `Clang <version>`
    6. Run command `CMake: Set Launch/Debug Target` and choose `Mine-imator`
    7. Debug with Shift+F5 or command `CMake: Debug`
7. After GML changes
    1. Run command `CMake: Run Task` and choose `Run CppGen`.
    2. Alternatively, run `./Setup.sh CppGen` or `./CppGen` in the `CppGen/Linux/` folder
    3. The `.gml` files in `GmProject` are converted to C++ in `CppProject/Generated/`
    4. **Note**: These resulting `.cpp` files should not be manually edited!
8. Generate Release build in `install/`
    * Run `./Setup.sh Release`

## Building libraries (Windows 64-bit) (optional)
1. Get MSYS2 from https://www.msys2.org/
    1. Install into `C:\Dev\msys64`
    2. Open MSYS2 MSYS prompt (via Start menu)
    3. Run `pacman -S --noconfirm make nasm pkgconf`
2. Open Windows PowerShell
3. Run `cd $env:DEV_DIR\Mine-imator`
4. Build libraries for Windows 64-bit
    1. Run `.\Setup.ps1 OpenSSL`
    2. Run `.\Setup.ps1 FFmpeg`
    3. Run `.\Setup.ps1 Libzip` (requires Qt)
    4. Run `.\Setup.ps1 OpenAL`
5. Build libraries for Windows 32-bit
    1. Run `.\Setup.ps1 Qt x86`
    2. Run `.\Setup.ps1 OpenSSL x86`
    3. Run `.\Setup.ps1 FFmpeg x86`
    4. Run `.\Setup.ps1 Libzip x86`
    5. Run `.\Setup.ps1 OpenAL x86`
6. Libraries are copied into `CppProject\External\Win32` and `CppProject\External\Win64`

## Building libraries (Mac OS Intel/ARM) (optional)
1. Open terminal
2. Run `brew install nasm yasm pkg-config`
3. Run `cd $DEV_DIR/Mine-imator`
4. Run `./Setup.sh FFmpeg`
5. Run `./Setup.sh Libzip` (requires Qt)
6. Run `./Setup.sh OpenAL`
7. Libraries are copied into `CppProject/External/Mac`

## Building libraries (Linux) (optional)
1. Open terminal
2. Install build dependencies
    * **Ubuntu/Debian/Linux Mint**: Run `sudo apt install -y nasm yasm pkg-config`
    * **Fedora**: Run `sudo dnf install -y nasm yasm pkgconf-pkg-config`
    * **Arch Linux/CachyOS**: Run `sudo pacman -S --needed --noconfirm nasm yasm pkgconf`
3. Run `cd $DEV_DIR/Mine-imator`
4. Run `./Setup.sh FFmpeg`
5. Run `./Setup.sh Libzip` (requires Qt)
6. Run `./Setup.sh OpenAL`
7. Libraries are copied into `CppProject/External/Linux`

## Building Mine-imator (on Windows 64-bit for 32-bit)
1. Follow steps 1-5 for Windows 64-bit setup
2. Set up external libraries and build Qt for Windows 32-bit
    * Run `.\Setup.ps1 Qt x86`
3. Generate Release build in `install-Win32\`
    * Run `.\Setup.ps1 Release x86`

## Building Mine-imator (on Mac OS ARM for Intel)
**Note**: Mine-imator has not been officially built or tested on the ARM architecture.
1. Follow steps 1-3 for Mac OS Intel setup
2. Run `sudo softwareupdate --install-rosetta --agree-to-license`
3. Run `brew install nasm yasm pkg-config`
4. Build libraries for Mac OS Intel
    1. Run `./Setup.sh Qt x86_64`
    2. Run `./Setup.sh FFmpeg x86_64`
    3. Run `./Setup.sh Libzip x86_64`
    4. Run `./Setup.sh OpenAL x86_64`
5. Generate Release build in `install/`
    * Run `./Setup.sh Release x86_64`

## Guide coverage
This guide has been tested on the following systems. If you run into troubles or errors, please [open a Github issue](https://github.com/stuffbydavid/Mine-imator/issues) with details.
* Windows 11 25H2 64-bit
* Mac OS Sonoma 14
* Ubuntu 20.04.6
* Ubuntu 26.04
* Fedora Workstation 44
* Linux Mint LMDE 7
* CachyOS