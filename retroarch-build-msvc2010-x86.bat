@echo off
cd pkg\msvc
echo Setting MSVC Environment...
call "C:\Program Files (x86)\Microsoft Visual Studio 10.0\VC\vcvarsall.bat" x86

rem del Release\RetroArch-msvc2010.exe 2>nul
echo Appending build log...
echo %date% %time% >buildlog.txt
set platform=
set PLATFORM=
set tmp=
set TMP=
echo Building RetroArch...
call msbuild RetroArch-msvc2010.sln /p:configuration=Release;platform=win32 /flp:LogFile=buildlog.txt;verbosity=normal;Append
echo Moving dist files...
move Release\RetroArch-msvc2010.exe ../../retroarch.exe
move Release\RetroArch-msvc2010.exe.intermediate.manifest ../../retroarch.exe.manifest
echo Build finished.
