
set proj_root=%~dp0

set PATH=C:\progs\mingw-w64\bin;C:\Windows\System32;C:\Windows
set PATH=C:\progs\cmake\bin;%PATH%

start c:\progs\console2\console.exe ^
		-d %proj_root% ^
		-w "Testing (CMD+MinGW-w64)" ^
