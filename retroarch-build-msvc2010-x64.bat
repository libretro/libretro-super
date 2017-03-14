@echo off
cd pkg\msvc
rem call "C:\Program Files (x86)\Microsoft Visual Studio 10.0\VC\vcvarsall.bat" x86
call "C:\Program Files\Microsoft SDKs\Windows\v7.1\Bin\SetEnv.cmd" /x64
rem del x64\Release\RetroArch-msvc2010.exe 2>nul
echo %date% %time% >buildlog.txt
tskill vcexpress 2>nul
set platform=
set PLATFORM=
set tmp=
set TMP=
echo Building RetroArch...
vcexpress RetroArch-msvc2010.sln /Out buildlog.txt /Rebuild "Release|x64" /Project RetroArch-msvc2010 /ProjectConfig "Release|x64"
move x64\Release\RetroArch-msvc2010.exe ../../retroarch.exe
cat buildlog.txt
echo Build finished.
