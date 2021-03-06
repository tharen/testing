# This CMakeLists file will generate a hierarchical build for Open-FVS.
#
# Note that every effort has been made to be platform independent, but surely
# some things will be overlooked. Please let us know of any bugs or quirks.
# Some support is included for Visual Studio and Intel compilers, but most
# work supports GCC/GFortran under MinGW and Linux.
#
# Alternate configurations can be generated by calling CMake from configuration
# specific folders.  This may be useful for keeping a test/debug environment
# and release build in the same folder tree. Cmake tracks all dependent source
# files and generated object code within the project subfolder, thus avoiding
# cross-build polution and redundant compilation where possible.
#
# Example: A project folder for a debug build and a seperate folder for release
#   mkdir <FVS bin>/debug
#   cd <FVS bin>/debug
#   cmake .. -G"MinGW Makefiles" ^
#       -DFVS_VARIANTS="pnc;wcc" ^
#       -DCMAKE_BUILD_TYPE=DEBUG ^
#       -DWITH_PYEXT=ON
#   mingw32-make -j4
#
#   mkdir <FVS bin>/release
#   cd <FVS bin>/release
#   cmake .. -G"MinGW Makefiles" ^
#       -DFVS_VARIANTS="pnc;wcc" ^
#       -DCMAKE_BUILD_TYPE=RELEASE ^
#       -DWITH_PYEXT=ON
#   mingw32-make -j4
#
# Example: Linux 64 bit
#   mkdir debug
#   cd debug
#   cmake .. -G"Unix Makefiles" \
#       -DFVS_VARIANTS="pnc;wcc" \
#       -DWITH_PYEXT=Yes -DCMAKE_BUILD_TYPE=Debug \
#       -DNATIVE_ARCH=ON -DSTATIC_LINK=ON
#   make -j8
#
# CMake will create a subfolder for each FVS variant and copy the cmake list
# and source list files.  A sub-project is then specified for each variant. Files
# common to all variants are compiled in the top level folder for use by each
# variant sub-project.
#
# The result is a make target for each executable, library, Python module. These
# targets can then be built individually or as a group with the "all" target.
# For instance "mingw32-make FVSpnc" would generate the PNC shared library and
# the PNC executable.  "mingw32-make pyfvspnc" would result in the common
# libraries, PNC shared library, and the Python module
# module, but not the PNC executable.  "mingw32-make FVS_pnc" would result in
# common libraries and the PNC shared library, but no executable or Python
# module.  Any combination of targets can be specified in one call to
# "mingw32-make".
#
# Generated binaries are placed in the Open-FVS subfolder.
#
# Additional arguments:
#   -DSTATIC_LINK=ON/OFF - Statically link FFE & SQL with the FVS binaries.
#   -DWITH_PYEXT=ON/OFF - Include Python module targets, default is OFF
#   -DFVS_VARIANTS=<variant list> - Explicitly list the variants to include in
#           the build as a semicolon seperated list of variant abbreviations,
#           eg. pnc;wcc;ncc;soc, the default is to include all variants.
#   -DPROFILING=ON/OFF - Include profiling info with compiled binaries.
#   -DENABLE_LTO=ON/OFF - Enable link time optimizations if BUILD_TYPE=Release.
#   -DNATIVE_ARCH=ON/OFF - Target the local machine architecture. Default=ON
#   -D32BIT_TARGET=ON/OFF - Set the target architecture to 32 bit. Default=OFF
#   -DUNIX_TARGET=ON/OFF - Set the target OS to be a UNIX flavor. Default=OFF
#
# CMake Variables:
#   -DCMAKE_BUILD_TYPE=<build type> - Adjust compiler & linker flags. Debug;Release

cmake_minimum_required (VERSION 2.8.8 FATAL_ERROR)

project(OPEN_FVS C CXX Fortran)
enable_language(Fortran)

set(version "Open-FVS")

#Assumes the FVS source is one level up from the parent CmakeLists.txt
#Used to set the prefix of all files in *sourceList.txt
get_filename_component(source_root "${CMAKE_CURRENT_LIST_DIR}/.." ABSOLUTE)
set(source_list_dir ${CMAKE_CURRENT_LIST_DIR})

#TODO: Clean up cache variable to enable cmake-gui usage
# Define default values for build configuration options
set(FVS_VARIANTS "all" CACHE STRING "FVS variants to configure")
set(WITH_PYEXT OFF CACHE BOOL "Build the Python module module.")
set(NATIVE_ARCH ON CACHE BOOL "Target the local machine architecture.")
set(32BIT_TARGET OFF CACHE BOOL "Set the target architecture to 32 bit.")
set(UNIX_TARGET OFF CACHE BOOL "Set the target OS to be a UNIX flavor.")
set(STATIC_LINK ON CACHE BOOL "Statically link FFE & SQL.")
set(ENABLE_LTO OFF CACHE BOOL "Enable link time optimizations.")
set(PROFILING OFF CACHE BOOL "Compile with profiling information.")

message(STATUS "Build Type:" ${CMAKE_BUILD_TYPE})

# If targetting the native architecture adjust the bit and OS flags
if (NATIVE_ARCH)
    message(STATUS "Configure for native architecture target.")

    # Determine native architecture bit depth
    if (CMAKE_SIZEOF_VOID_P EQUAL 8)
        message(STATUS "Native target architecture is 64 bit")
        set(32BIT_TARGET OFF)
    else ()
        message(STATUS "Native target architecture is 32 bit")
        set(32BIT_TARGET ON)
    endif ()

    # Determine the native OS type
    if (CMAKE_HOST_UNIX EQUAL 1)
        message(STATUS "Native target OS is *NIX")
        set(UNIX_TARGET ON)
    else ()
        message(STATUS "Native target OS is NOT *NIX")
        set(UNIX_TARGET OFF)
    endif ()

endif ()

##-----COMPILER FLAGS-----##
if (CMAKE_GENERATOR MATCHES "Visual Studio 10")
    message(STATUS "Configure FVS build for ${CMAKE_GENERATOR}")
    set(flags "/D_WINDOWS /W3 /Zm100")
    set (CMAKE_C_FLAGS "${flags}" CACHE STRING "VS10 mod A" FORCE)
    set (CMAKE_CXX_FLAGS "${flags}" CACHE STRING "VS10 mod B" FORCE)
endif ()

# TODO: Check for target OS and compiler instead of relying on the CMake generator
# TODO: Add Cygwin GNU toolchains

if (CMAKE_COMPILER_IS_GNUCC)
    message(STATUS "Add GCC compiler flags.")
    
    # TODO: These may be clobbering CMAKE FLAGS
    
    # CMAKE_BUILD_TYPE = Debug
    set(debug_flags "-g3 -mfpmath=sse -msse")
    set(CMAKE_Fortran_FLAGS_DEBUG "${debug_flags} -ffpe-trap=invalid,zero,overflow,underflow")
    set(CMAKE_CXX_FLAGS_DEBUG "${debug_flags}")
    set(CMAKE_C_FLAGS_DEBUG "${debug_flags}")
    
    # CMAKE_BUILD_TYPE = Release
    set(release_flags "-Ofast -mfpmath=sse -msse")
    if (ENABLE_LTO)
        set(release_flags "${release_flags} -funroll-loops -flto -fwhole-program")
    else ()
        set(CMAKE_Fortran_FLAGS_RELEASE "${release_flags} -funroll-loops")
    endif ()
    set(CMAKE_CXX_FLAGS_RELEASE "${release_flags}")
    set(CMAKE_C_FLAGS_RELEASE "${release_flags}")
    
    if (PROFILING)
        add_definitions(-DPROFILING)
        set(profile_flags "-pg")
        set(CMAKE_CXX_FLAGS "${profile_flags} ${CMAKE_CXX_FLAGS}")
        set(CMAKE_C_FLAGS "${profile_flags} ${CMAKE_C_FLAGS}")
        set(CMAKE_Fortran_FLAGS "${profile_flags} -fprofile-arcs -ftest-coverage ${CMAKE_Fortran_FLAGS}")
        set(CMAKE_EXE_LINKER_FLAGS "${profile_flags} ${CMAKE_EXE_LINKER_FLAGS}")
        set(CMAKE_SHARED_LINKER_FLAGS "${profile_flags} ${CMAKE_SHARED_LINKER_FLAGS}")
    endif ()
    
    # Flags for all build types
    # TODO: Add additional architecture and optimization flags -mtune=, -mfpmath=sse, etc.
    # TODO: Need to specify target architectures.
    if (NATIVE_ARCH)
        set(flags "-march=native")
    endif()
    
    # TODO: Is pthread necessary
    # set(flags "-pipe -pthread")
    if (32BIT_TARGET)
        set(flags "${flags} -m32 -pipe")
    else ()
        if (WIN32)
            add_definitions(-DMS_WIN64)
        endif ()
        set(flags "${flags} -m64 -pipe")
    endif ()

    # Specify the target OS; perhaps useful with MinGW.
    if (UNIX_TARGET)
        message(STATUS "Add -fPIC for UNIX targets.")
        set(flags "${flags} -fPIC")
    endif()

    # Enable link time optimizations
    if (ENABLE_LTO)
        message(STATUS "Enable link time optimizations.")
        set(flags "${flags} -flto")
    endif()

    set(CMAKE_CXX_FLAGS "-cpp ${flags} ${CMAKE_CXX_FLAGS}")
    set(CMAKE_C_FLAGS "-cpp ${flags} ${CMAKE_C_FLAGS}")
    set(CMAKE_Fortran_FLAGS "-cpp ${flags} ${CMAKE_Fortran_FLAGS}")
    
    # Linker Flags
    set(CMAKE_EXE_LINKER_FLAGS "${flags} ${CMAKE_EXE_LINKER_FLAGS}")
    set(CMAKE_SHARED_LINKER_FLAGS "${flags} ${CMAKE_SHARED_LINKER_FLAGS}")
    set(flags "")
    
    if (NOT UNIX_TARGET)
        set(CMAKE_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS} -static")
        set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -static")
        add_definitions(-DANSI -DWINDOWS -DCMPgcc)
    
    elseif (UNIX_TARGET)
        set(CMAKE_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS}")
        set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS}")
        add_definitions(-DANSI -DCMPgcc)
    
    endif ()

endif ()

#Process the variant list command line argument and make a list of source lists
#  eg. cmake <...> -DFVS_VARIANTS=pnc;wcc;iec
string(TOLOWER ${FVS_VARIANTS} FVS_VARIANTS)
if (FVS_VARIANTS STREQUAL "all")
    file(GLOB source_lists "${source_list_dir}/FVS*_sourceList.txt")
    set(FVS_VARIANTS "")
    foreach (fn ${source_lists})
        string(REGEX REPLACE ".*FVS(.+)_sourceList.txt" "\\1" var ${fn})
        string(TOLOWER ${var} var)
        list(APPEND FVS_VARIANTS ${var})
    endforeach(fn)

else()
    set(source_lists "")
    foreach(var ${FVS_VARIANTS})
        set(fn "${source_list_dir}/FVS${var}_sourceList.txt")
        if (NOT EXISTS "${fn}")
            message(FATAL_ERROR "No source list for variant ${var}: ${fn}")
        else()
            message(STATUS "Variant source list: ${var} - ${fn}")
            list(APPEND source_lists ${fn})
        endif()
    endforeach(var)

endif()

list(LENGTH FVS_VARIANTS num_variants)
message(STATUS "FVS Variants = (${num_variants}) ${FVS_VARIANTS}")
message(STATUS "Source Root = ${source_root}")

#---Top Level Objects
list(GET source_lists 0 source_list)

# Read the source file names as a list
file(STRINGS ${source_list} source_file_list)
# Localize the paths
string(REPLACE "../" "${source_root}/" source_file_list "${source_file_list}")

#---Include Dirs
# Loop through the source files to gather the C header and include file paths
set(include_dirs)
foreach (fn ${source_file_list})
    get_filename_component(pathname ${fn} PATH)
    get_filename_component(filename ${fn} NAME)
    if (${fn} MATCHES "(.*\\.h$)|(.*\\.F77$)")
        list(APPEND include_dirs ${pathname})
    endif()
endforeach(fn)

# Include the root folder to catch the DBSTYPEDEFS.F77 location
list(APPEND include_dirs ${CMAKE_CURRENT_BINARY_DIR})
list(REMOVE_DUPLICATES include_dirs)
include_directories(BEFORE ${include_dirs})

#---SQL
# Setup targets for the mkdbsTypeDefs generator, and SQL library
# Get the SQL source code file
file(STRINGS ${source_list} sql_source REGEX "fvsSQL.c")
string(REPLACE "../" "${source_root}/" sql_source "${sql_source}")

# Add the command to generate the SQL type defs
file(STRINGS ${source_list} typedefs_src REGEX "mkdbsTypeDefs.c")
string(REPLACE "../" "${source_root}/" typedefs_src "${typedefs_src}")
add_executable(mkdbsTypeDefs ${typedefs_src})

set(dbstypedefs_f77 "${CMAKE_CURRENT_BINARY_DIR}/DBSTYPEDEFS.F77")

# Execute the DBSTYPEDEFS.F77 generator.
add_custom_command(
        OUTPUT ${dbstypedefs_f77}
        COMMAND $<TARGET_FILE:mkdbsTypeDefs>
        DEPENDS mkdbsTypeDefs)

# Create a dummy target so the DBSTYPEDEFS.F77 generator will be called.
add_custom_target(gen_dbstypedefs ALL DEPENDS ${dbstypedefs_f77})

# TODO: use find_library to locate the correct odbc library

# Compile the SQL object library
if (NOT STATIC_LINK)
    message(STATUS "Build shared SQL library.")
    add_library(sql_lib SHARED ${sql_source})

    if (WIN32)
        target_link_libraries(sql_lib odbc32)
    else ()
        target_link_libraries(sql_lib odbc)
    endif ()

    set_target_properties(sql_lib PROPERTIES
            LINKER_LANGUAGE CXX
            OUTPUT_NAME FVSsql
            )

else ()
    message(STATUS "Build static SQL objects.")
    add_library(sql_lib OBJECT ${sql_source})

endif ()

# Ensure that DBSTYPEDEFS.F77 is generated
add_dependencies(sql_lib gen_dbstypedefs)

#---FFE
# Get the list of FFE C/C++ source files
set(ffe_source)
foreach (fn ${source_file_list})
    # FFE Source files are C/C++, excluding the SQL code
    if((${fn} MATCHES "(.*\\.c$)|(.*\\.cpp$)")
            AND (NOT ${fn} MATCHES "(.*mkdbsTypeDefs.c$)|(.*fvsSQL.c$)"))
        list (APPEND ffe_source ${fn})
    endif()
endforeach(fn)
list(REMOVE_DUPLICATES ffe_source)

# Compile the FFE object library
if (NOT STATIC_LINK)
    message(STATUS "Build shared FFE library.")
    add_library(ffe_lib SHARED ${ffe_source})
    set_target_properties(ffe_lib PROPERTIES
            LINKER_LANGUAGE CXX
            OUTPUT_NAME FVSffe
            #TODO: is stdcall alias necessary
            #LINK_FLAGS -Wl,--add-stdcall-alias
            )
else ()
    message(STATUS "Build static FFE objects.")
    add_library(ffe_lib OBJECT ${ffe_source})
endif ()

#---Common Objects
# Generate a list of fortran source code files common to all variants
set(common_source)
#list(GET source_lists 0 sl)
#file(STRINGS ${sl} common_source REGEX "(.*f$)|(.*f90$)")
#string(REPLACE "../" "${source_root}/" common_source "${common_source}")

#set(temp_src)
#foreach(fn ${common_source})
#    file(READ ${fn} foo)
#    if ((NOT ${fn} MATCHES ".*main\\.(f|f90)$")
#        # Variant specific code includes the prgprm and esparm files
#        AND (NOT "${foo}" MATCHES ".*PRGPRM.F77.*")
#        AND (NOT "${foo}" MATCHES ".*ESPARM.F77.*")
#        AND (NOT "${foo}" MATCHES ".*prgprm_mod.*")
#        AND (NOT "${foo}" MATCHES ".*siteht_mod.*")
#        AND (NOT "${foo}" MATCHES ".*snag_data.*"))
#        list(APPEND temp_src ${fn})
#    endif()
#endforeach()
#set(common_source ${temp_src})

# Parse each configured variant source file list keeping files common to all
#foreach (sl ${source_lists})
#    set(temp_src)
#    # Read the list of source files for this variant
#    file(STRINGS ${sl} fl)
#    string(REPLACE "../" "${source_root}/" fl "${fl}")
#
#    # Compare each file currently in the common list with the variant file list
#    foreach(fn ${common_source})
#        list(FIND fl ${fn} m)
#        # FIND returns -1 for files not in the variant file list
#        if (NOT m EQUAL -1)
#            list(APPEND temp_src ${fn})
#        endif()
#    endforeach()
#    set(common_source ${temp_src})
#endforeach()
#list(REMOVE_DUPLICATES common_source)

# Compile the  object libraries
add_library(common_objs OBJECT ${common_source})

# Ensure the SQL and common objects are built in sequence
add_dependencies(common_objs sql_lib)

#---Configure each requested variant.
message(STATUS "Configure variants: ${FVS_VARIANTS}")
math(EXPR num_variants "${num_variants}-1")
foreach(v RANGE ${num_variants})
    list(GET FVS_VARIANTS ${v} variant)
    get_filename_component(variant_dir ${CMAKE_BINARY_DIR}/${variant} ABSOLUTE)
    message(STATUS "Variant Dir = ${variant_dir}")

    file(MAKE_DIRECTORY ${variant_dir})

    # Write out the modified source list file to the variant sub directory
    list(GET source_lists ${v} srclst_fn)
    message(STATUS "Source List File: ${srclst_fn}")
    file(STRINGS ${srclst_fn} source_list NEWLINE_CONSUME)
    string(REPLACE "../" "${source_root}/" source_list "${source_list}")
    file(WRITE ${variant_dir}/sourcelist.txt ${source_list})

    # Write out the new variant CMakeLists file
    # TODO: Move the variant template to a seperate file.
    file(STRINGS CMakeLists.txt cmakelist NEWLINE_CONSUME)
    string(REGEX REPLACE ".*##-----DO NOT REMOVE THIS TAG-----##" ""
           cmakelist ${cmakelist})

    # Replace template strings
    # TODO: use string(configure ...) instead of this mess
    string(REGEX REPLACE "<<variant>>" "${variant}" cmakelist ${cmakelist})
    string(REGEX REPLACE "<<source_list>>" "${variant_dir}/sourcelist.txt" cmakelist ${cmakelist})
    string(REGEX REPLACE "<<source_root>>" "${source_root}" cmakelist ${cmakelist})
    string(REGEX REPLACE "<<with_pyext>>" ${WITH_PYEXT} cmakelist ${cmakelist})
    file(WRITE ${variant_dir}/CMakeLists.txt ${cmakelist})

    # Add the the FVS variant CMakeLists.txt as a sub-project
    add_subdirectory(${variant_dir} ${variant_dir})
endforeach()

return()

##The text below this tag becomes the CMakeLists.txt file in the variant subdirectory
##-----DO NOT REMOVE THIS TAG-----##
cmake_minimum_required(VERSION 2.8.8 FATAL_ERROR)

project(FVS<<variant>> C CXX Fortran)
#include(GenerateExportHeader)

enable_language(Fortran)

set(fvsexe "FVS${variant}")
set(fvslib_shared "libFVS${variant}")
set(fvslib_static "FVS${variant}_static")

#Replaced by regex during configuration
set(variant <<variant>>)
set(source_list <<source_list>>)
set(source_root <<source_root>>)

message(STATUS "Configure variant: ${variant}")
message(STATUS "CMake Build Type: ${CMAKE_BUILD_TYPE}")
message(STATUS "Profiling: ${PROFILING}")
message(STATUS "source_list: ${source_list}")
message(STATUS "fvsexe: ${fvsexe}")
message(STATUS "fvslib_shared: ${fvslib_shared}")
#message(STATUS "Shared Link Flags: ${CMAKE_SHARED_LINKER_FLAGS}")
#message(STATUS "Exe Link Flags: ${CMAKE_EXE_LINKER_FLAGS}")

function(join VALUES GLUE OUTPUT)
  string(REPLACE ";" "${GLUE}" _TMP_STR "${VALUES}")
  set(${OUTPUT} "${_TMP_STR}" PARENT_SCOPE)
endfunction()

# Parse the source file list and populate Cmake lists
set(include_dirs)
set(fvs_source)
set(main_source)
set(pyext_source)

# Process the source list for the variant
file(STRINGS ${source_list} source_files)
# Localize the paths
string(REPLACE "../" "${source_root}/" source_files "${source_files}")

foreach (fn ${source_files})
    if (NOT ${fn} MATCHES "^#.*")
        get_filename_component(filename ${fn} NAME)
        get_filename_component(pathname ${fn} PATH)
        get_filename_component(extname ${fn} EXT)

        # Need the location of C headers and include files
        if (${fn} MATCHES "(.*\\.h$)|(.*\\.F77$)")
            list(APPEND include_dirs ${pathname})
        endif()

        # Separate the core FVS code from executable main routine
        if ((${extname} STREQUAL ".f") OR (${extname} STREQUAL ".f90"))
            if ((${filename} STREQUAL "main.f")
                OR (${filename} STREQUAL "main.f90"))
                list(APPEND main_source ${fn})
            else()
                list (APPEND fvs_source ${fn})
            endif()
        endif()

        unset(filename CACHE)
        unset(pathname CACHE)
        unset(extname CACHE)
    endif()
endforeach(fn)

list(REMOVE_DUPLICATES include_dirs)
list(REMOVE_DUPLICATES fvs_source)
list(REMOVE_DUPLICATES main_source)

# Include the variant build folder to catch .mod files
list(APPEND include_dirs ${CMAKE_CURRENT_BINARY_DIR})

# Add the newly found include dirs
include_directories(BEFORE ${include_dirs})

# Remove source files already in common, FFE, SQL
set(sl ${common_source} ${ffe_source} ${sql_source})
foreach(fn ${sl})
    list(FIND fvs_source ${fn} i)
    if (NOT ${i} EQUAL -1)
        list(REMOVE_ITEM fvs_source ${fn})
    endif()
endforeach()

#---CMake Variables
file(WRITE "cmakevars-${variant}.txt" "CMake Variables - ${variant}")
get_cmake_property(_variableNames VARIABLES)
foreach (_variableName ${_variableNames})
    file(APPEND
            "cmakevars-${variant}.txt"
            "${_variableName}=${${_variableName}}\n"
            )
endforeach()

#---Compile the variant FVS code to an object library
set(fvs_objs "fvs${variant}_objs")
add_library(${fvs_objs} OBJECT ${fvs_source} ${common_source})

# Ensure common source files are built before the variant sources
add_dependencies(${fvs_objs} common_objs)

##TODO: Need a fixup for VBA 
#if (WIN32)
#    set_target_properties(${fvs_lib} PROPERTIES
#            LINK_FLAGS "${CMAKE_SHARED_LINKER_FLAGS} -Wl,--output-def,${fvs_lib}.def"
#            )
#endif ()

#---Link the shared library and executables
if (NOT STATIC_LINK)
    add_library(${fvslib_shared} SHARED
        $<TARGET_OBJECTS:common_objs>
        $<TARGET_OBJECTS:${fvs_objs}>)
    target_link_libraries(${fvslib_shared} ffe_lib sql_lib)

    add_library(${fvslib_static}
        $<TARGET_OBJECTS:common_objs>
        $<TARGET_OBJECTS:${fvs_objs}>)
    target_link_libraries(${fvslib_static} ffe_lib sql_lib)

    add_executable (${fvsexe} ${main_source}
        $<TARGET_OBJECTS:common_objs>
        $<TARGET_OBJECTS:${fvs_objs}>)
    target_link_libraries(${fvsexe} ffe_lib sql_lib)

else ()
    add_library(${fvslib_shared} SHARED
        $<TARGET_OBJECTS:common_objs>
        $<TARGET_OBJECTS:${fvs_objs}>
        $<TARGET_OBJECTS:ffe_lib>
        $<TARGET_OBJECTS:sql_lib>
        )

    add_library(${fvslib_static}
        $<TARGET_OBJECTS:common_objs>
        $<TARGET_OBJECTS:${fvs_objs}>
        $<TARGET_OBJECTS:ffe_lib>
        $<TARGET_OBJECTS:sql_lib>
        )

    add_executable (${fvsexe} ${main_source}
        $<TARGET_OBJECTS:common_objs>
        $<TARGET_OBJECTS:${fvs_objs}>
        $<TARGET_OBJECTS:ffe_lib>
        $<TARGET_OBJECTS:sql_lib>
        )

endif ()

if (WIN32)
    target_link_libraries(${fvslib_shared} odbc32)
    target_link_libraries(${fvsexe} odbc32)
else ()
    target_link_libraries(${fvslib_shared} ltdl odbc)
    target_link_libraries(${fvsexe} ltdl odbc)
endif ()

set_target_properties(${fvsexe} PROPERTIES LINKER_LANGUAGE Fortran)
set_target_properties(${fvslib_shared} PROPERTIES
    LINKER_LANGUAGE Fortran
    PREFIX ""
    IMPORT_PREFIX ""
    )

# ##TODO: Need a fixup for VBA
# if (NOT UNIX_TARGET)
   # set_target_properties(${fvslib_shared} PROPERTIES
           # LINK_FLAGS "${CMAKE_SHARED_LINKER_FLAGS} -Wl,--output-def,${fvslib_shared}.def,--out-implib,${fvslib_shared}.a"
           # )
# endif ()

install(TARGETS ${fvsexe} DESTINATION bin)
install(TARGETS ${fvslib_shared} DESTINATION lib)
install(TARGETS ${fvslib_static} DESTINATION lib/static)

# Create a header file for the variant library
#generate_export_header(${fvslib_shared})
#generate_export_header(${fvslib_shared}
#    BASE_NAME ${fvslib_shared}
#    EXPORT_MACRO_NAME ${fvslib_shared}_EXPORT
#    EXPORT_FILE_NAME ${fvslib_shared}_Export.h
#    STATIC_DEFINE ${fvslib_shared}_BUILT_AS_STATIC
#    )

# FIXME: Installation of header files is not working
#install(FILES ${CMAKE_CURRENT_BINARY_DIR}/${fvslib_shared}_Export.h DESTINATION "./")

# Build the Python module if requested
if (WITH_PYEXT)
    message(STATUS "Configure and build the Python extension.")

    set(pyext_name "pyfvs${variant}")
    
    # TODO: Add a pyfvs_sources.txt file to avoid stuffing them here
    # Process the source list for files to include in the Python module
    file(STRINGS ${source_list} source_files)
    string(REPLACE "../" "${source_root}/" source_files "${source_files}")

    # Source files to be wrapped with F2PY
    set(_pyext_src 
                "apisubs.f" "cmdline.f" "fvs.f"
                "filopn.f" "htcalc.f" "rann.f"
                "htdbh.f"
                
                "prgprm_mod.f90" "esparm_mod.f90" "arrays_mod.f90" 
                "contrl_mod.f90"

                "coeffs_mod.f90" "econ_mod.f90" "escomn_mod.f90" "eshap_mod.f90"
                "estree_mod.f90" "htcal_mod.f90" "multcm_mod.f90" "pden_mod.f90"
                "workcm_mod.f90" "plot_mod.f90" "rancom_mod.f90" 
                "screen_mod.f90"

                "fvsstdcm_mod.f90" "varcom_mod.f90" "outcom_mod.f90" 
                "volstd_mod.f90"

                "fmparm_mod.f90" "fmcom_mod.f90" "fmfcom_mod.f90" 
                "fmprop_mod.f90"

#                "fmsvcm_mod.f90" "svdata_mod.f90"
                "metric_mod.f90"
                
                "carbon_data.f90" "downwood_data.f90" "tree_data.f90"
                "fvs_step.f90"
                "snag_data.f90" "siteht_mod.f90"
                "findage_mod.f90"
                
#                "step_grincr.f90" "dbs_commons.f" "fire_commons.f"
#                "fvs_commons.f"
                
                "esblkd_mod.f90" "esrncm_mod.f90" "escprs.f90"
                )
    # Routines to be skipped by F2PY
    set(pyext_skip "") #required by f2py_gen

    foreach (fn ${source_files})
        if (NOT ${fn} MATCHES "^#.*")
            get_filename_component(filename ${fn} NAME)

            list(FIND _pyext_src ${filename} x)
            if (x GREATER -1)
                list(APPEND pyext_source ${fn})
            endif()
            unset(filename)
        endif()
    endforeach(fn)
    list(REMOVE_DUPLICATES pyext_source)

    # Write the Python extension source files to a text file
    file(WRITE ./pyext_source.txt "${pyext_source}")

    # FIXME: The wrong python is being called on appveyor, 
    set(PYTHON_EXE python)
    
    # Determine the file name of the Python library
    execute_process(
            COMMAND ${PYTHON_EXE} ../platform_ext.py ${pyext_name}
            OUTPUT_VARIABLE pyext_fn
            OUTPUT_STRIP_TRAILING_WHITESPACE
            )
    
    set(cmd_args "")
    # F2PY/Distutils needs to know what compilers are being used
    if (CMAKE_COMPILER_IS_MINGW EQUAL 1)
        list(APPEND cmd_args "--compiler=mingw32")
    endif ()
    
    if (CMAKE_Fortran_COMPILER_ID STREQUAL GNU)   
        list(APPEND cmd_args "--fcompiler=gnu95")
    endif ()
    
#    if (CMAKE_BUILD_TYPE STREQUAL Debug)
#        list(APPEND cmd_args "--debug")
#    endif ()
  
    # Configure the setup.py script for the current variant.
    configure_file(../../setup.py.in setup.py @ONLY)
    configure_file(${source_root}/python/pyfvs_wrap.pyf.in ${pyext_name}.pyf @ONLY)
    
    # Compile the Python extension library
    add_custom_command(
            OUTPUT ${pyext_fn}
            COMMAND python ARGS setup.py build_ext --inplace ${cmd_args} > ../f2py_${variant}.log 2>&1
            DEPENDS ${fvslib_static} ./pyext_source.txt
            COMMENT "Compile python extension."
            )
    add_custom_target(${pyext_name}_ext ALL DEPENDS ${pyext_fn})

    install(
        FILES ${pyext_fn}
        DESTINATION python)
    
    # Add intermediate files to the clean list
    # NOTE: pyext_source.txt should not be cleaned
    set(cf ${pyext_name}.pyf)
    set_directory_properties(
            PROPERTIES
            ADDITIONAL_MAKE_CLEAN_FILES "${cf}"
            )

    # Generate a PyDoc HTML file for the module
    # TODO: Incorporate pydoc generation into setup.py
    set(PYDOC_EXE pydoc)
    add_custom_command(
            TARGET ${pyext_name}_ext
            #TARGET ${pyext_fn}
            POST_BUILD
            COMMAND ${PYDOC_EXE} -w ${pyext_name} > ../pydoc_${pyext_name}.log
            )

    install(FILES ${pyext_name}.html
            DESTINATION python/docs
            )
    set_directory_properties(
            PROPERTIES ADDITIONAL_MAKE_CLEAN_FILES
            ${pyext_name}.html
            )

    # Copy the Python source package
    install(
            DIRECTORY ${source_root}/python/
            DESTINATION python
            FILES_MATCHING REGEX ".*\\.(py|cfg)$"
            PATTERN "__pycache__" EXCLUDE
            )
    
    message(STATUS "*** End PyMod Configuration ***")

endif()

# Add a make target for the variant to build everything seperate from 'all'
if (WITH_PYEXT)
    add_custom_target(${variant} DEPENDS ${pyext_name} ${fvsexe} ${fvslib_shared} ${fvslib_static})
else ()
    add_custom_target(${variant} DEPENDS ${fvsexe} ${fvslib_shared} ${fvslib_static})
endif ()
