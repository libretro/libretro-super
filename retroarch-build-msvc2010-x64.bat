@echo off

echo cd pkg\msvc
cd pkg\msvc

rem echo "C:\Program Files (x86)\Microsoft Visual Studio 10.0\VC\vcvarsall.bat" x86
rem call "C:\Program Files (x86)\Microsoft Visual Studio 10.0\VC\vcvarsall.bat" x86

echo "C:\Program Files\Microsoft SDKs\Windows\v7.1\Bin\SetEnv.cmd" /x64
call "C:\Program Files\Microsoft SDKs\Windows\v7.1\Bin\SetEnv.cmd" /x64

echo msbuild RetroArch-msvc2010.sln /p:configuration=Release;platform=x64
call msbuild RetroArch-msvc2010.sln /p:configuration=Release;platform=x64

echo move x64\Release\RetroArch-msvc2010.exe ..\..\retroarch.exe
move x64\Release\RetroArch-msvc2010.exe ..\..\retroarch.exe

echo move x64\Release\RetroArch-msvc2010.exe.intermediate.manifest ..\..\retroarch.exe.manifest
move x64\Release\RetroArch-msvc2010.exe.intermediate.manifest ..\..\retroarch.exe.manifest

echo Build finished.
