pushd bin
mkdir build
pushd build
cmake -G "Unix Makefiles" .. \
    -DFVS_VARIANTS=pnc \
    -DMAKE_JOBS=1 \
    -DCMAKE_SYSTEM_NAME=Windows
    -DWITH_PYMOD=Yes
    