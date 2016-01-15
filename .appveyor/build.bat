%APPVEYOR_BUILD_FOLDER%\\.appveyor\\setpath.bat

pushd bin\build
mingw32-make install 2> build_err.log
popd
