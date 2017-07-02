@echo off

echo cd pkg\msvc
cd pkg\msvc

echo "C:\Program Files (x86)\Microsoft Visual Studio 10.0\VC\vcvarsall.bat" x86
call "C:\Program Files (x86)\Microsoft Visual Studio 10.0\VC\vcvarsall.bat" x86

echo msbuild RetroArch-msvc2010.sln /p:configuration=Debug;platform=win32
call msbuild RetroArch-msvc2010.sln /p:configuration=Debug;platform=win32

echo move Debug\RetroArch-msvc2010.exe ..\..\retroarch.exe
move Debug\RetroArch-msvc2010.exe ..\..\retroarch.exe

echo move Debug\RetroArch-msvc2010.exe.intermediate.manifest ..\..\retroarch.exe.manifest
move Debug\RetroArch-msvc2010.exe.intermediate.manifest ..\..\retroarch.exe.manifest

echo Build finished.
