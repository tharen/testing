
set proj_root=%~dp0

set PATH=C:\progs\msys64\mingw64\bin;C:\Windows\System32;C:\Windows
set PATH=C:\progs\cmake\bin;%PATH%
set PATH=C:\Ruby22-x64\bin;%PATH%

call C:\Anaconda3\Scripts\activate.bat pyfvs_python3.5

start c:\progs\console2\console.exe ^
		-d %proj_root% ^
		-w "PyFVS (CMD+MinGW-w64)" ^
