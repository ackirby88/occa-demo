#!/bin/bash -e

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
INSTALL_DEMO_DIRECTORY=${INSTALL_DIRECTORY}/DEMO
BUILD_DIRECTORY=${PROJECT_ROOT}/builds
BUILD_DEMO_DIRECTORY=${BUILD_DIRECTORY}/DEMO

# ============== #
# DEMO sources/OKL
# ============== #
SOURCES_DIRECTORY=${PROJECT_ROOT}/src
DEMO_DIRECTORY=${SOURCES_DIRECTORY}
DEMO_SOURCES_DIRECTORY=${DEMO_DIRECTORY}

# ========================= #
# third party library paths
# ========================= #
INSTALL_3RD_PARTY_PATH=${INSTALL_DIRECTORY}/3PL

# occa path
OCCA_DIRECTORY=${INSTALL_3RD_PARTY_PATH}/occa

# ================== #
# compiling defaults
# ================== #
BUILD_DEMO=1
BUILD_CLEAN=0
COMPILE_FAIL=0

# ================= #
# compiler defaults
# ================= #
CC=gcc
CXX=g++

C_FLAGS=
CXX_FLAGS=
Fortran_FLAGS=

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
GC="\x1B[1;32m"
rC="\x1B[0;41m"
gC="\x1B[0;42m"
yC="\x1B[0;33m"
oC="\x1B[3;93m"
aC="\x1B[3;92m"
mC="\x1B[0;43m"

help() {
    echo "Usage: $0 [OPTION]...[COMPILER OPTIONS]...[DEMO OPTIONS]"
    echo " "
    echo "  [OPTION]:"
    echo "    --help     -h      displays this help message"
    echo "    --clean    -c      removes build directory: DEMO/builds/DEMO_{}"
    echo "    --release  -opt    compile the project in optimized mode"
    echo "    --debug    -deb    compile the project in debug mode"
    echo "    --testsON  -ton    turn on unit tests (google tests)"
    echo " "
    echo "  [COMPILER OPTIONS]:"
    echo "     CC=<arg>     cc=<arg>    sets the C compiler"
    echo "    CXX=<arg>    cxx=<arg>    sets the C++ compiler"
    echo " "
    echo "      C_FLAGS=<arg>    c_flags=<arg>    sets the C compiler flags"
    echo "    CXX_FLAGS=<arg>  cxx_flags=<arg>    sets the C++ compiler flags"
    echo " "
    echo -e "  ${aC}Recommended Options:${eC}"
    echo "    Default (-go):"
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
    BUILD_DEMO=0

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

  elif [ "${var:0:8}" == "C_FLAGS=" -o "${var:0:8}" == "c_flags=" ]; then
    C_FLAGS=${var:8}
    echo -e "[OPTION]       C Compiler Flags: $yC$C_FLAGS$eC"

  elif [ "${var:0:10}" == "CXX_FLAGS=" -o "${var:0:10}" == "cxx_flags=" ]; then
    CXX_FLAGS=${var:10}
    echo -e "[OPTION]     CXX Compiler Flags: $yC$CXX_FLAGS$eC"

  elif [ "$var" == "-go" ]; then
    CC=gcc
    CXX=g++

  elif [ "$var" == "-intel" ]; then
    CC=icc
    CXX=icpc

  fi
done

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
COMPILE_INSTALL_DEMO_DIRECTORY="${INSTALL_DEMO_DIRECTORY}${BUILD_SUFFIX}"
COMPILE_BUILD_DEMO_DIRECTORY="${BUILD_DEMO_DIRECTORY}${BUILD_SUFFIX}"

# ============== #
# compiler paths
# ============== #
CC_PATH="`which $CC`"
CXX_PATH="`which $CXX`"
LD_PATH="`which ld`"

# ====================== #
# check source directory
# ====================== #
if [ ! -d "${DEMO_SOURCES_DIRECTORY}" ]; then
  echo " "
  echo "Error:"
  echo "${DEMO_SOURCES_DIRECTORY} does not exist."
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
if [ $BUILD_CLEAN == 1 ]; then
  echo " "
  echo "Clean: removing ${COMPILE_BUILD_DEMO_DIRECTORY}..."
  echo "Clean: removing ${COMPILE_INSTALL_DEMO_DIRECTORY}..."
  echo " "
  rm -rf $COMPILE_BUILD_DEMO_DIRECTORY
  rm -rf $COMPILE_INSTALL_DEMO_DIRECTORY
fi

if [ $BUILD_DEMO == 1 ]; then
  echo " "
  echo -e "${mC} ===================== Building DEMO ==================== ${eC}"
  echo         "   Compiling Options:"
  echo         "          Build Type: ${BUILD_TYPE}"
  echo         "          Unit Tests: ${UNIT_TEST}"
  echo         " "
  echo         "                  CC: ${CC}"
  echo         "                 CXX: ${CXX}"
  echo         " "
  echo         "            CC Flags: ${C_FLAGS}"
  echo         "           CXX Flags: ${CXX_FLAGS}"
  echo         " "
  echo         "          Build Type: ${BUILD_TYPE}"
  echo         "      Build Location: ${COMPILE_BUILD_DEMO_DIRECTORY}"
  echo         "    Install Location: ${COMPILE_INSTALL_DEMO_DIRECTORY}"
  echo         " Executable Location: ${COMPILE_BUILD_DEMO_DIRECTORY}/bin"
  echo -e "${mC} ========================================================== ${eC}"
  echo " "

  # move to the build directory
  cd $BUILD_DIRECTORY

  if [ ! -d $COMPILE_BUILD_DEMO_DIRECTORY ]; then
    mkdir $COMPILE_BUILD_DEMO_DIRECTORY
  fi
  cd $COMPILE_BUILD_DEMO_DIRECTORY

  cmake -D CMAKE_C_COMPILER=${CC_PATH}                              \
        -D CMAKE_CXX_COMPILER=${CXX_PATH}                           \
        -D CMAKE_C_FLAGS=${C_FLAGS}                                 \
        -D CMAKE_CXX_FLAGS=${CXX_FLAGS}                             \
        -D CMAKE_LINKER=${LD_PATH}                                  \
        -D CMAKE_INSTALL_PREFIX=${COMPILE_INSTALL_DEMO_DIRECTORY}   \
        -D CMAKE_BUILD_TYPE=${BUILD_TYPE}                           \
	-D OKL_DIR=${PROJECT_ROOT}/src              		    \
        -D occa_dir=${OCCA_DIRECTORY}                               \
        -G "Unix Makefiles" ${DEMO_DIRECTORY} | tee cmake_config.out

  ${MAKE_CMD}
  cd ${CURRENT_PATH}

  if [ ! -d "${COMPILE_INSTALL_DEMO_DIRECTORY}" ]; then
    echo "ERROR:"
    echo "${COMPILE_INSTALL_DEMO_DIRECTORY} does not exist."
    COMPILE_FAIL=1
  fi
fi

if [ ${COMPILE_FAIL} == 0 ]; then
  echo " "
  echo -e " ========================================================== "
  echo -e " ${gC}DEMO build successful! ${eC}"
  echo    "   Compiling Options:"
  echo    "          Build Type: ${BUILD_TYPE}"
  echo    "          Unit Tests: ${UNIT_TEST}"
  echo    " "
  echo    "                  CC: ${CC}"
  echo    "                 CXX: ${CXX}"
  echo    " "
  echo    "             C Flags: ${C_FLAGS}"
  echo    "           CXX Flags: ${CXX_FLAGS}"
  echo    " "
  echo    "          Build Type: ${BUILD_TYPE}"
  echo    "      Build Location: ${COMPILE_BUILD_DEMO_DIRECTORY}"
  echo -e "                    : ${GC}make clean; make -j install${eC} in this directory"
  echo    "    Install Location: ${COMPILE_INSTALL_DEMO_DIRECTORY}"
  echo    " Executable Location: ${COMPILE_BUILD_DEMO_DIRECTORY}/bin"
  echo -e " ========================================================== "
  echo    " "
else
  echo " "
  echo         "======================"
  echo -e "${rC} DEMO build FAILED! ${eC}"
  echo         "======================"
  echo " "
  exit 1
fi
# =================================================================== #

# Create hyperlink to bin directory
ln -sf ${COMPILE_BUILD_DEMO_DIRECTORY}/bin ../bin

echo
echo "================================================"
echo -e "${gC} Finished Successfully...${eC}"
echo -e " Executable: ${GC}builds/DEMO_release/bin/demo.exe${eC}"
echo "================================================"

echo -e "${gC}Build Script Completed Successfully!${eC}"
