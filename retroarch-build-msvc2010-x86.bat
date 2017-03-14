@echo off
cd pkg\msvc
call "C:\Program Files (x86)\Microsoft Visual Studio 10.0\VC\vcvarsall.bat" x86
rem del Release\RetroArch-msvc2010.exe 2>nul
echo %date% %time% >buildlog.txt
tskill vcexpress 2>nul
set platform=
set PLATFORM=
set tmp=
set TMP=
echo Building RetroArch...
vcexpress RetroArch-msvc2010.sln /Out buildlog.txt /Rebuild Release
move Release\RetroArch-msvc2010.exe ../../retroarch.exe
cat buildlog.txt
echo Build finished.
