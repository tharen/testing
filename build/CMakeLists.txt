cmake_minimum_required (VERSION 2.8.8 FATAL_ERROR)

project(TESTING C CXX Fortran)
enable_language(Fortran)

if(WIN32)
    set(odbc "odbc32")
else()
    set(odbc "odbc")
endif()

set(source_files "../src/test_prog.f90")

add_executable(test_prog ${source_files})
target_link_libraries(test_prog ${odbc})