set PATH=%PYTHON%;C:\\msys64\\mingw64\\bin

pushd bin\build
mingw32-make install 2> build_err.log
popd
