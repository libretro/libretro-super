# Copied from https://github.com/vbe0201/switch-cmake/blob/master/devkita64-libnx.cmake
# Copyright (c) 2019 SwitchPy Team
# Licensed under MIT license, full text is available in COPYING
if (NOT DEFINED ENV{DEVKITPRO})
    cmake_panic("Please set DEVKITPRO in your environment. export DEVKITPRO=<path to>/devkitpro")
endif ()

set(CMAKE_SYSTEM_NAME Generic)
set(CMAKE_SYSTEM_PROCESSOR aarch64)
set(SWITCH TRUE) # To be used for multiplatform projects

# devkitPro paths are broken on Windows. We need to use this macro to fix those.
macro(msys_to_cmake_path msys_path resulting_path)
    if (WIN32)
        string(REGEX REPLACE "^/([a-zA-Z])/" "\\1:/" ${resulting_path} ${msys_path})
    else ()
        set(${resulting_path} ${msys_path})
    endif ()
endmacro()

msys_to_cmake_path($ENV{DEVKITPRO} DEVKITPRO)
set(DEVKITA64 ${DEVKITPRO}/devkitA64)
set(LIBNX ${DEVKITPRO}/libnx)
set(PORTLIBS_PATH ${DEVKITPRO}/portlibs)
set(PORTLIBS ${PORTLIBS_PATH}/switch)

set(TOOLCHAIN_PREFIX ${DEVKITA64}/bin/aarch64-none-elf-)
if (WIN32)
    set(TOOLCHAIN_SUFFIX ".exe")
else ()
    set(TOOLCHAIN_SUFFIX "")
endif ()

set(CMAKE_C_COMPILER ${TOOLCHAIN_PREFIX}gcc${TOOLCHAIN_SUFFIX})
set(CMAKE_CXX_COMPILER ${TOOLCHAIN_PREFIX}g++${TOOLCHAIN_SUFFIX})
set(CMAKE_ASM_COMPILER ${TOOLCHAIN_PREFIX}as${TOOLCHAIN_SUFFIX})

set(PKG_CONFIG_EXECUTABLE ${TOOLCHAIN_PREFIX}pkg-config${TOOLCHAIN_SUFFIX})
set(CMAKE_AR ${TOOLCHAIN_PREFIX}gcc-ar${TOOLCHAIN_SUFFIX} CACHE STRING "")
set(CMAKE_RANLIB ${TOOLCHAIN_PREFIX}gcc-ranlib${TOOLCHAIN_SUFFIX} CACHE STRING "")
set(CMAKE_LD "/${TOOLCHAIN_PREFIX}ld${TOOLCHAIN_SUFFIX}" CACHE INTERNAL "")
set(CMAKE_OBJCOPY "${TOOLCHAIN_PREFIX}objcopy${TOOLCHAIN_SUFFIX}" CACHE INTERNAL "")
set(CMAKE_SIZE_UTIL "${TOOLCHAIN_PREFIX}size${TOOLCHAIN_SUFFIX}" CACHE INTERNAL "")

set(WITH_PORTLIBS ON CACHE BOOL "use portlibs ?")
if (WITH_PORTLIBS)
    set(CMAKE_FIND_ROOT_PATH ${DEVKITA64} ${DEVKITPRO} ${LIBNX} ${PORTLIBS})
else ()
    set(CMAKE_FIND_ROOT_PATH ${DEVKITA64} ${DEVKITPRO} ${LIBNX})
endif ()

set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)

add_definitions(-D__SWITCH__)
set(ARCH "-march=armv8-a -mtune=cortex-a57 -mtp=soft -fPIE")
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -MMD -MP -g -Wall -O2 -ffunction-sections ${ARCH}")
set(CMAKE_CXX_FLAGS "${CMAKE_C_FLAGS} ${CMAKE_CXX_FLAGS} -fno-rtti -fno-exceptions")
set(CMAKE_EXE_LINKER_FLAGS_INIT "${ARCH} -ftls-model=local-exec -L${LIBNX}/lib -L${PORTLIBS}/lib")
set(CMAKE_MODULE_LINKER_FLAGS_INIT ${CMAKE_EXE_LINKER_FLAGS_INIT})

set(BUILD_SHARED_LIBS OFF CACHE INTERNAL "Shared libs not available")
set(CMAKE_INSTALL_PREFIX ${PORTLIBS})
set(CMAKE_PREFIX_PATH ${PORTLIBS})
