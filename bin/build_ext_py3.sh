sources=$(cat pymod_source.txt)

if [ -v MSYSTEM ]
then
  # Assume this is running on Windows under MSYS2/bash
  f2py -h pyfvs$1.pyf -m pyfvs$1 --overwrite-signature $sources
  f2py -c --compiler=mingw32 --fcompiler=gnu95 -lodbc32 ./pyfvs$1.pyf libFVS$1_static.a

else
  f2py -h pyfvs$1.pyf -m pyfvs$1 --overwrite-signature $sources
  f2py -c -lodbc ./pyfvs$1.pyf libFVS$1_static.a

fi

