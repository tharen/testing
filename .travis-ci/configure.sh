mkdir -p ${BUILD_ROOT}
pushd ${BUILD_ROOT}
cmake -G"Unix Makefiles" .. \
    -DFVS_VARIANTS=pnc \
    -DWITH_PYMOD=Yes \
    -DCMAKE_SYSTEM_NAME=Linux \
    -DCMAKE_INSTALL_PREFIX=Open-FVS    
popd
