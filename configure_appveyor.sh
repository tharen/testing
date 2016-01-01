cd bin
cmake -G "Unix Makefiles" . \
    -DFVS_VARIANTS=pnc \
    -DMAKE_JOBS=2 \
    -DCMAKE_SYSTEM_NAME=Windows