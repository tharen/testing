sources=$(cat pymod_source.txt)

if [ -v MSYSTEM ]
then
  # Assume this is running on Windows under MSYS2/bash
  f2py -h pyfvs$1.pyf -m pyfvs$1 --overwrite-signature $sources > ../f2py_$1.log 2>&1
  f2py -c --compiler=mingw32 --fcompiler=gnu95 -lodbc32 ./pyfvs$1.pyf libFVS$1_static.a >> ../f2py_$1.log 2>&1

else
  
  v=$(python -c "import sys;print(sys.version_info[0])")
  if [ $v = 3 ]
  then
    f2py=f2py3
  else
    f2py=f2py
  fi
  
  i=$(which python)
  echo Python executable: $i > ../f2py_$1.log
  i=$(which $f2py)
  echo F2PY executable: $i >> ../f2py_$1.log
  
  $(f2py) -h pyfvs$1.pyf -m pyfvs$1 --overwrite-signature $sources >> ../f2py_$1.log 2>&1
  $(f2py) -c -lodbc ./pyfvs$1.pyf libFVS$1_static.a >> ../f2py_$1.log 2>&1

fi

