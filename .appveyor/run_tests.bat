%PYTHON%\Scripts\pip install --upgrade nose-parameterized
%PYTHON%\Scripts\conda update -y

set PYTHONPATH=%APPVEYOR_BUILD_FOLDER%\bin\build\Open-FVS\python;%PYTHONPATH%

pushd %APPVEYOR_BUILD_FOLDER%\bin\build\Open-FVS\python\test
call %PYTHON%\python.exe -m unittest test_variants

popd
