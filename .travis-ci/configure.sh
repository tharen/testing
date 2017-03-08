mkdir -p ${BUILD_ROOT}
pushd ${BUILD_ROOT}
cmake -G"Unix Makefiles" .. \
    -DFVS_VARIANTS="pnc;wcc;soc;cac" \
    -DWITH_PYEXT=Yes \
    -DCMAKE_SYSTEM_NAME=Linux \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX=Open-FVS    
popd
