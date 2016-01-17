set OLDPATH=%PATH%
set PATH=%PYTHON%;C:\msys64\mingw64\bin;C:\Program Files (x86)\cmake\bin
set PATH=%PATH%;C:\Windows\System32;C:\Windows
echo %PATH%
echo %PYTHONPATH%

:: Activate the target Python environment
call %PYTHON%\Scripts\activate %ENV_NAME%
::set PATH=%PYTHON_HOME%;%PYTHON_HOME%\Scripts;%PATH%

:: Configure CMake
mkdir bin\build
pushd bin\build
cmake -G "MinGW Makefiles" .. ^
    -DFVS_VARIANTS="pnc;wcc" ^
    -DCMAKE_SYSTEM_NAME=Windows ^
    -DWITH_PYEXT=Yes ^
    -DCMAKE_INSTALL_PREFIX=Open-FVS

:: Compile and install locally
mingw32-make install 2> build_err.log

popd

set PATH=%OLDPATH%