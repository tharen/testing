::%PYTHON%\Scripts\pip install --upgrade nose-parameterized
::%PYTHON%\Scripts\conda update -y --all

set PYTHONPATH=%APPVEYOR_BUILD_FOLDER%\bin\build\Open-FVS\python;%PYTHONPATH%

call %PYTHON%\python.exe -c "import numpy;print('Numpy version:',numpy.version.version)"

pushd %APPVEYOR_BUILD_FOLDER%\bin\build\Open-FVS\python\test
call %PYTHON%\python.exe -m unittest test_variants

popd
