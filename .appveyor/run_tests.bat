pip install --upgrade nose-parameterized nose2

:: Make sure the named Python environment is active
call %PYTHON%\Scripts\activate %ENV_NAME%
set PYTHONPATH=%APPVEYOR_BUILD_FOLDER%\bin\build\Open-FVS\python;%PYTHONPATH%

:: Report the current numpy version
call %PYTHON_HOME%\python.exe -c "import numpy;print('Numpy version:',numpy.version.version)"

:: Move into the package parent folder
pushd %APPVEYOR_BUILD_FOLDER%\bin\build\Open-FVS\python
:: Execute all test scripts
call nose2
popd
