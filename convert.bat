@echo off
set "ROOT=%CD%"
set "GM_DIR=%ROOT%\GmProject"
set "GEN_DIR=%ROOT%\CppProject\Generated"
set "SPR_DIR=%ROOT%\CppProject\Asset\Sprites"
set "SHD_DIR=%ROOT%\CppProject\Asset\Shaders"
set "JSON_FILE=%ROOT%\CppGen\gml.json"

echo Building CppGen...
dotnet build CppGen/CppGen.sln -c Release
if %errorlevel% neq 0 (
    echo Error building CppGen
    pause
    exit /b %errorlevel%
)

rem Detect output framework folder
set "CPPGEN_EXE="
if exist "CppGen\CppGen\bin\Release\net8.0\CppGen.exe" set "CPPGEN_EXE=CppGen\CppGen\bin\Release\net8.0\CppGen.exe"
if "%CPPGEN_EXE%"=="" if exist "CppGen\CppGen\bin\Release\net7.0\CppGen.exe" set "CPPGEN_EXE=CppGen\CppGen\bin\Release\net7.0\CppGen.exe"
if "%CPPGEN_EXE%"=="" if exist "CppGen\CppGen\bin\Release\net6.0\CppGen.exe" set "CPPGEN_EXE=CppGen\CppGen\bin\Release\net6.0\CppGen.exe"
if "%CPPGEN_EXE%"=="" (
    echo No se encontró CppGen.exe en bin\Release\netX.Y\
    pause
    exit /b 1
)

echo Running CppGen...
echo Command: "%CPPGEN_EXE%" "%GM_DIR%" "%GEN_DIR%" "%SPR_DIR%" "%SHD_DIR%" "%JSON_FILE%"
"%CPPGEN_EXE%" "%GM_DIR%" "%GEN_DIR%" "%SPR_DIR%" "%SHD_DIR%" "%JSON_FILE%"
if %errorlevel% neq 0 (
    echo Error running CppGen
    pause
    exit /b %errorlevel%
)

echo Conversion complete.
pause
