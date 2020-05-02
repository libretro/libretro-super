set(CMAKE_C_COMPILER "qcc")
# -D_SSIZE_T_DEFINED is only for minizip dependency of TIC-80
set(CMAKE_C_FLAGS "-V4.8.3,gcc_ntoarmv7le_gpp -std=gnu99 -D_SSIZE_T_DEFINED")
set(CMAKE_CXX_COMPILER "QCC")
set(CMAKE_CXX_FLAGS "-V4.8.3,gcc_ntoarmv7le_gpp -std=gnu++11")
set(CMAKE_AR "arm-unknown-nto-qnx8.0.0eabi-ar")

set(CMAKE_RANLIB "arm-unknown-nto-qnx8.0.0eabi-ranlib")
set(CMAKE_SYSTEM_PROCESSOR arm)
set(CMAKE_SYSTEM_NAME QNX)
set(CMAKE_CROSSCOMPILING ON)
set(CMAKE_SHARED_LIBRARY_LINK_C_FLAGS "-fPIC")
set(CMAKE_C_LINK_FLAGS "-fPIC")
