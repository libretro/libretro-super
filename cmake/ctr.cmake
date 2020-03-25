set(CMAKE_C_COMPILER "$ENV{DEVKITARM}/bin/arm-none-eabi-gcc")
set(CMAKE_CXX_COMPILER "$ENV{DEVKITARM}/bin/arm-none-eabi-g++")
set(CMAKE_AR "$ENV{DEVKITARM}/bin/arm-none-eabi-gcc-ar")

# Workaround for old cmake. Remove when we update cmake
set(CMAKE_C_ARCHIVE_CREATE "${CMAKE_AR} qc <TARGET> <LINK_FLAGS> <OBJECTS>")
set(CMAKE_CXX_ARCHIVE_CREATE "${CMAKE_AR} qc <TARGET> <LINK_FLAGS> <OBJECTS>")
set(CMAKE_C_CREATE_STATIC_LIBRARY "${CMAKE_AR} qc <TARGET> <LINK_FLAGS> <OBJECTS>")
set(CMAKE_CXX_CREATE_STATIC_LIBRARY "${CMAKE_AR} qc <TARGET> <LINK_FLAGS> <OBJECTS>")

set(CMAKE_RANLIB "$ENV{DEVKITARM}/bin/arm-none-eabi-gcc-ranlib")
set(CMAKE_SYSTEM_PROCESSOR armv6k)
set(CMAKE_SYSTEM_NAME Generic)
set(CMAKE_CROSSCOMPILING ON)
set(CMAKE_SHARED_LIBRARY_LINK_C_FLAGS "-fPIC")
set(CMAKE_C_LINK_FLAGS "-fPIC")
set(CMAKE_TRY_COMPILE_TARGET_TYPE STATIC_LIBRARY)
set(CMAKE_CXX_FLAGS " -march=armv6k -mtune=mpcore -mfloat-abi=hard -I$ENV{DEVKITPRO}/libctru/include")
set(CMAKE_C_FLAGS " -march=armv6k -mtune=mpcore -mfloat-abi=hard -I$ENV{DEVKITPRO}/libctru/include")

add_definitions(-DARM11 -D_3DS)

# Workaround for old cmake. Remove when we update cmake
add_definitions(-march=armv6k -mtune=mpcore -mfloat-abi=hard -I$ENV{DEVKITPRO}/libctru/include)

set(BUILD_SHARED_LIBS OFF CACHE INTERNAL "Shared libs not available" )
