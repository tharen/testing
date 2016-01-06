pushd bin
mkdir /p build
pushd build
cmake -G "MinGW Makefiles" .. ^
    -DFVS_VARIANTS=pnc ^
    -DMAKE_JOBS=1 ^
    -DCMAKE_SYSTEM_NAME=Windows ^
    -DWITH_PYMOD=Yes
popd
popd
