mkdir bin\build
pushd bin\build
cmake -G "MinGW Makefiles" .. ^
    -DFVS_VARIANTS=pnc ^
    -DMAKE_JOBS=1 ^
    -DCMAKE_SYSTEM_NAME=Windows ^
    -DWITH_PYMOD=Yes ^
    -DCMAKE_INSTALL_PREFIX=Open-FVS
popd