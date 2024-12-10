#!/bin/bash -e
# Folder structure:
# ================
# project_root
#   install         #install directory
#     3PL           #install to this folder
#   builds          #build directory
#   sources         #source codes
#     3PL           #location of 3rd party library source code
#   scripts         #location of this script


# ======================= #
# project directory paths
# ======================= #
CURRENT_PATH="$(pwd)"
MY_PATH="$( cd "$( dirname "$0" )" && pwd )"
PROJECT_ROOT=${MY_PATH}/..

# ====================== #
# folder directory paths
# ====================== #
INSTALL_DIRECTORY=${PROJECT_ROOT}/install
INSTALL_3PL_DIRECTORY=${INSTALL_DIRECTORY}/3PL
BUILD_DIRECTORY=${PROJECT_ROOT}/builds
BUILD_SOLVER_DIRECTORY=${BUILD_DIRECTORY}/3PL

# ============== #
# 3PL sources
# ============== #
SOURCES_DIRECTORY=${PROJECT_ROOT}/src
SOURCES_3PL_DIRECTORY=${PROJECT_ROOT}/3PL

# ================== #
# compiling defaults
# ================== #
BUILD_OCCA=0
BUILD_CLEAN=0

# ================= #
# compiler defaults
# ================= #
CC=gcc
CXX=g++

# DO NOT USE -O3
CFLAGS="-fPIC -O2 -std=gnu99"

# ======================== #
# compiler option defaults
# ======================== #
BUILD_SUFFIX="_release"
BUILD_TYPE="Release"

# ======================== #
# make and install command
# ======================== #
MAKE_CMD="make -j4 install"

# ============== #
# print strings
# ============== #
opt_str="[OPTION] "

eC="\x1B[0m"
rC="\x1B[0;41m"
gC="\x1B[0;42m"
yC="\x1B[0;33m"
mC="\x1B[0;43m"

help() {
    echo "Usage: $0 [OPTION]...[COMPILER OPTIONS]...[3PL OPTIONS]"
    echo " "
    echo "  This script builds the 3rd party libraries: "
    echo "       p4est, metis, google test (gtest)"
    echo " "
    echo "  [OPTION]:"
    echo "    --help    -h      displays this help message"
    echo "    --clean   -c      removes build directory: dg4est/builds/dg4est_{}"
    echo "    --release -opt    compile the project in optimized mode"
    echo "    --debug   -deb    compile the project in debug mode"
    echo " "
    echo "  [COMPILER OPTIONS]:"
    echo "     CC=<arg>     cc=<arg>    sets the C compiler"
    echo "    CXX=<arg>    cxx=<arg>    sets the C++ compiler"
    echo " "
    echo "      C_FLAGS=<arg>    c_flags=<arg>    sets the C compiler flags"
    echo "    CXX_FLAGS=<arg>  cxx_flags=<arg>    sets the C++ compiler flags"
    echo " "
    echo "  [3PL OPTIONS]:"
    echo "    --ALL3PL  -all3pl comile all 3rd party libraries"
    echo "    --OCCA    -occa   compile libocca"
    echo " "
}

# ----------------------------- #
# Start the compilation process #
# ----------------------------- #
cd $PROJECT_ROOT

# ============ #
# parse inputs
# ============ #
for var in "$@"
do
  if [ "$var" == "--help" -o "$var" == "-help" -o "$var" == "-h" ]; then
    help
    exit 0
  elif [ "$var" == "--clean" -o "$var" == "-clean" -o "$var" == "-c" ]; then
    echo ${opt_str} "Clean and rebuild"
    BUILD_CLEAN=1

  elif [ "$var" == "--release" -o "$var" == "-release" -o "$var" == "-opt" ]; then
    echo ${opt_str} "Compiling in optimized mode"
    BUILD_SUFFIX="_release"
    BUILD_TYPE="Release"

  elif [ "$var" == "--debug" -o "$var" == "-debug" -o "$var" == "-deb" ]; then
    echo ${opt_str} "Compiling in debug mode"
    BUILD_SUFFIX="_debug"
    BUILD_TYPE="Debug"

  elif [ "${var:0:3}" == "CC=" -o "${var:0:3}" == "cc=" ]; then
    CC=${var:3}
    echo -e "[OPTION]       C Compiler: $yC$CC$eC"

  elif [ "${var:0:4}" == "CXX=" -o "${var:0:4}" == "cxx=" ]; then
    CXX=${var:4}
    echo -e "[OPTION]     CXX Compiler: $yC$CXX$eC"

  elif [ "$var" == "--OCCA" -o "$var" == "-occa" ]; then
    BUILD_OCCA=1
  
  elif [ "$var" == "-intel" ]; then
    CC=icc
    CXX=icpc
 
  elif [ "$var" == "--ALL3PL" -o "$var" == "--all3pl" -o "$var" == "-all3pl" ]; then
    BUILD_OCCA=1
  fi
done

# if no 3PL are selected, compile all of them
if [ $BUILD_OCCA == 0 ]; then
  BUILD_OCCA=1
fi

# ========================= #
# display command line args
# ========================= #
echo " "
echo "$0 $@"

# ----------------------------------------------------- #
# After reading in cmd arg options, set remaining paths #
# ----------------------------------------------------- #

# ====================================== #
# install/build location compiled source
# ====================================== #
COMPILE_INSTALL_3PL_DIRECTORY="${INSTALL_3PL_DIRECTORY}${BUILD_SUFFIX}"
COMPILE_BUILD_3PL_DIRECTORY="${BUILD_3PL_DIRECTORY}${BUILD_SUFFIX}"

# ============== #
# compiler paths
# ============== #
CC_PATH="`which $CC`"
CXX_PATH="`which $CXX`"
LD_PATH="`which ld`"

# ====================== #
# check source directory
# ====================== #
if [ ! -d "${SOURCES_3PL_DIRECTORY}" ]; then
  echo "${rC}ERROR: {SOURCES_3PL_DIRECTORY} does not exist.${eC}"
  exit 1
fi

# ======================= #
# check install directory
# ======================= #
if [ ! -d "${INSTALL_DIRECTORY}" ]; then
  echo  "${INSTALL_DIRECTORY} does not exist. Making it..."
  mkdir "${INSTALL_DIRECTORY}"
fi

# ====================== #
# check builds directory
# ====================== #
if [ ! -d "${BUILD_DIRECTORY}" ]; then
  echo  "${BUILD_DIRECTORY} does not exist. Making it..."
  mkdir "${BUILD_DIRECTORY}"
fi
# =================================================================== #

# =================================================================== #
COMPILE_FAIL=0
INSTALL_OCCA_DIRECTORY=${INSTALL_3PL_DIRECTORY}/occa
if [ $BUILD_OCCA == 1 ]; then
  echo " "
  echo -e "${mC} ==== Building OCCA ==== ${eC}"
  echo " Compiling Options:"
  echo "        Build Type: ${BUILD_TYPE}"
  echo "  Install Location: ${INSTALL_OCCA_DIRECTORY}"
  echo " "
  echo "                CC: ${CC}"
  echo "               CXX: ${CXX}"
  echo -e "${mC} ========================= ${eC}"
  echo " "

  git submodule init
  git submodule update
  cd ${SOURCES_3PL_DIRECTORY}/occa

  HIP="ON"
  CUDA="ON"
  OPENCL="ON"
  OPENMP="ON"
  DPCPP="OFF"
  METAL="OFF"

  INSTALL_DIR=${INSTALL_OCCA_DIRECTORY}   \
  HIP_ROOT="/opt/rocm-6.1.2" 	\
  CUDAToolkit_ROOT="/opt/cuda" 	\
  OCCA_ENABLE_HIP=${HIP}       	\
  OCCA_ENABLE_CUDA=${CUDA}     	\
  OCCA_ENABLE_OPENCL=${OPENCL} 	\
  OCCA_ENABLE_OPENMP=${OPENMP} 	\
  OCCA_ENABLE_DPCPP=${DPCPP}   	\
  OCCA_ENABLE_METAL=${METAL}   	\
  ./configure-cmake.sh

  cd build
  ${MAKE_CMD}
  cd ..
  cd ${CURRENT_PATH}
fi
# =================================================================== #
echo -e "${gC}Build Script Completed Successfully!${eC}"
