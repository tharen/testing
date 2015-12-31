@echo off
:: Build envirnonment for PyFVS

set proj_root=%~dp0

set PATH=C:\progs\cmake\bin

::set PATH=C:\progs\msys64\usr\bin;C:\progs\msys64\MINGW64\bin;C:\Windows\System32;C:\Windows
::set PATH=C:\Anaconda3;C:\Anaconda3\DLLs;C:\Anaconda3\Scripts;%PATH%

:: Activate the target Python environment
::call c:\Anaconda3\Scripts\activate.bat pyfvs_python3.5

set MSYSTEM=MINGW64
set CHERE_INVOKING=1

start c:\progs\console2\console.exe ^
		-d %proj_root% ^
		-w "Testing (MSY2+MinGW-w64 %MSYSTEM%)" ^
		-r "cmd /C C:\progs\msys64\usr\bin\bash.exe --login -i"
