@echo off

echo cd pkg\msvc
cd pkg\msvc

rem I moved SetEnv BEFORE vcvarsall because I was getting the dreaded "\Microsoft was unexpected at this time" error and this somehow prevents it.
rem Even after reading several hard-to-find "none of the other solutions online worked for me, but this one does" posts, still nothing worked for me.
rem Then I got this:
rem error MSB6001: Invalid command line switch for "VCBuild.exe". Item has already been added. Key in dictionary: 'tmp'  Key being added: 'tmp'
rem The fix was to unset TMP and TEMP.

set TMP=
set TEMP=

rem MSVC uses the platform variable which conflicts with our build system, so unset it temporarily
set platform=

call "C:\Program Files\Microsoft Platform SDK\SetEnv.cmd" /2000 /RETAIL

echo "%ProgramFiles(x86)%\Microsoft Visual Studio 8\VC\vcvarsall.bat" x86
call "%ProgramFiles(x86)%\Microsoft Visual Studio 8\VC\vcvarsall.bat" x86

echo msbuild RetroArch-msvc2005.sln /p:configuration=Release;platform=win32 /v:diag
call msbuild RetroArch-msvc2005.sln /p:configuration=Release;platform=win32 /v:diag

echo move msvc-2005\Release\RetroArch-msvc2005.exe ..\..\retroarch.exe
move msvc-2005\Release\RetroArch-msvc2005.exe ..\..\retroarch.exe

echo move msvc-2005\Release\RetroArch-msvc2005.exe.intermediate.manifest ..\..\retroarch.exe.manifest
move msvc-2005\Release\RetroArch-msvc2005.exe.intermediate.manifest ..\..\retroarch.exe.manifest

echo Build finished.
