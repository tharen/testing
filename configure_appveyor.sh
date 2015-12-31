cd bin
cmake -G "Unix Makefiles" . \
    -DFVS_VARIANTS=pnc,wcc \
    -DMAKE_JOBS=1 \
    -DCMAKE_SYSTEM_NAME=Windows