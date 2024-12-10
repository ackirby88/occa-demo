CMAKE_MINIMUM_REQUIRED(VERSION 3.1)
PROJECT(DEMO)

# --------------------------------------------------------------------------- #
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)
# --------------------------------------------------------------------------- #
set(CMAKE_INSTALL_RPATH_USE_LINK_PATH TRUE)
# --------------------------------------------------------------------------- #
# set C++17 standard for OCCA compatibility
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++17")
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_EXTENSIONS OFF)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
# --------------------------------------------------------------------------- #
# force GNU linker to include all shared libraries
if (NOT APPLE)
  set(CMAKE_SHARED_LINKER_FLAGS "-Wl,--no-as-needed")
else ()
  set(CMAKE_MACOSX_RPATH ON)
endif ()

# --------------------------------------------------------------------------- #
# set OCCA directory
set(occa_dir  "" CACHE PATH "occa  install directory location")
set(ENV{OCCA_DIR} "${occa_dir}")
message("OCCA_DIR: " $ENV{OCCA_DIR})
# --------------------------------------------------------------------------- #
# Library header files to be included
include_directories($ENV{OCCA_DIR}/include)

# Libraries to be linked
find_library(occa_lb   NAMES occa   PATHS $ENV{OCCA_DIR}/lib)
# --------------------------------------------------------------------------- #
add_definitions("-DOKL_DIR=\"${OKL_DIR}\"")
message("OKL Directory: ${OKL_DIR}")
# --------------------------------------------------------------------------- #
add_executable(demo.exe main.cxx)
target_link_libraries(demo.exe ${occa_lb} m)

install(TARGETS demo.exe
        RUNTIME DESTINATION bin/
        LIBRARY DESTINATION lib/
        ARCHIVE DESTINATION lib/
)
# ======================================= #
