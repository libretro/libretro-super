@echo off
echo tskill vcexpress
tskill vcexpress >nul 2>nul
rem this is a hack for sleep()
ping 192.0.2.1 -n 1 -w 2000 >nul
echo taskkill /t /f /im vcexpress.exe
taskkill /t /f /im vcexpress.exe >nul 2>nul
ping 192.0.2.1 -n 1 -w 2000 >nul
cd pkg\msvc
echo Setting MSVC Environment...
rem call "C:\Program Files (x86)\Microsoft Visual Studio 10.0\VC\vcvarsall.bat" x86
call "C:\Program Files\Microsoft SDKs\Windows\v7.1\Bin\SetEnv.cmd" /x64
rem del x64\Release\RetroArch-msvc2010.exe 2>nul
echo Appending build log...
echo %date% %time% >buildlog.txt
set platform=
set PLATFORM=
set tmp=
set TMP=
echo Building RetroArch...
echo Calling vcexpress to build project...
vcexpress RetroArch-msvc2010.sln /Out buildlog.txt /Rebuild "Release|x64" /Project RetroArch-msvc2010 /ProjectConfig "Release|x64"
echo Moving dist files...
move x64\Release\RetroArch-msvc2010.exe ../../retroarch.exe
move x64\Release\RetroArch-msvc2010.exe.intermediate.manifest ../../retroarch.exe.manifest
echo Contents of build log:
cat buildlog.txt
echo Build finished.
