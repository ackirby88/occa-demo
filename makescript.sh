#!/bin/bash -e

# ================== #
# compiling defaults
# ================== #
BUILD_3PL=0
BUILD_SOLVER=0
BUILD_TYPE=0
CLEAN_DIST=0

# ============== #
# print strings
# ============== #
opt_str="[OPTION] "

eC="\x1B[0m"
bC="\x1B[0;34m"
GC="\x1B[1;32m"
yC="\x1B[0;33m"
aC="\x1B[0;96m"
rC="\x1B[0;41m"
gC="\x1B[0;32m"
oC="\x1B[3;93m"
mC="\x1B[0;43m"

help() {
    echo -e " ========================================================= "
    echo -e " ${GC} >>>>>>  Easy Build Option:  ./makescript.sh -go  <<<<<<${eC}"
    echo -e " ========================================================= "
    echo " "
    echo -e "${GC} Usage:${eC} $0 [OPTIONS]...[COMPILER OPTIONS]...[3PL OPTIONS]"
    echo " "
    echo -e " ${aC}Recommended Options:${eC}"
    echo -e "    Default: ./makescript.sh -go"
    echo "      ./makescript.sh CC=gcc CXX=g++"
    echo " "
    echo -e " ${aC}Options List:${eC}"
    echo "  [OPTION]:"
    echo "    --3pl       -3pl    build the 3rd party libraries: metis, t8code, occa, googletest"
    echo "    --Demo      -Demo   build t8code amr interface library"
    echo " "
    echo "    --help      -h      displays this help message"
    echo "    --clean     -c      removes local build directories"
    echo "    --distclean -dc     removes builds and install directories"
    echo "    --release   -opt    compile the project in optimized mode"
    echo "    --debug     -deb    compile the project in debug mode"
    echo " "
    echo "  [COMPILER OPTIONS]:"
    echo "     CC=<arg>   cc=<arg>    sets the C compiler"
    echo "    CXX=<arg>  cxx=<arg>    sets the C++ compiler"
    echo " "
    echo "      C_FLAGS=<arg>    c_flags=<arg>    sets the C compiler flags"
    echo "    CXX_FLAGS=<arg>  cxx_flags=<arg>    sets the C++ compiler flags"
    echo " "
    echo "  [3PL OPTIONS]:"
    echo "    --ALL3P   -all3p  compile all 3rd party libraries"
    echo "    --OCCA    -occa  compile OCCA"
    echo " "
}

# ============ #
# parse inputs
# ============ #
for var in "$@"
do
  if [ "$var" == "--help" -o "$var" == "-help" -o "$var" == "-h" ]; then
    help
    exit 0

  elif [ "$var" == "--distclean" -o "$var" == "-distclean" -o "$var" == "-dc" ]; then
    echo -e "Found known argument: ${gC}$var${eC}"
    echo ${opt_str} "Cleaning the distribution..."
    CLEAN_DIST=1

  elif [ "$var" == "--3pl" -o "$var" == "-3pl" -o "$var" == "-3pl" ]; then
    echo -e "Found known argument: ${gC}$var${eC}"
    BUILD_3PL=1

  elif [ "$var" == "--OCCA" -o "$var" == "-occa" ]; then
    echo -e "Found known argument: ${gC}$var${eC}"
    BUILD_3PL=1

  elif [ "$var" == "--Demo" -o "$var" == "-demo" ]; then
    echo -e "Found known argument: ${gC}$var${eC}"
    BUILD_SOLVER=1

  elif [ "$var" == "--release" -o "$var" == "-release" -o "$var" == "-opt" ]; then
    echo -e "Found known argument: ${gC}$var${eC}"
    BUILD_TYPE=0

  elif [ "$var" == "--debug" -o "$var" == "-debug" -o "$var" == "-deb" ]; then
    echo -e "Found known argument: ${gC}$var${eC}"
    BUILD_TYPE=1

  elif [ "$var" == "--clean" -o "$var" == "-clean" -o "$var" == "-c" -o \
         "${var:0:3}" == "CC=" -o "${var:0:3}" == "cc=" -o \
         "${var:0:4}" == "CXX=" -o "${var:0:4}" == "cxx=" -o \
         "${var:0:8}" == "C_FLAGS=" -o "${var:0:8}" == "c_flags=" -o \
         "${var:0:10}" == "CXX_FLAGS=" -o "${var:0:10}" == "cxx_flags=" -o \
         "${var}" == "-go" -o \
         "${var}" == "-intel" ]; then
    echo -e "Found known argument: ${gC}$var${eC}"

  else
    echo -e "${oC}Unknown option:${eC}  ${rC}$var${eC}"
    echo "See available options: ./makescript.sh -help"
    echo "Using Default Options..."

  fi
done

# ========================= #
# display command line args
# ========================= #
echo "$0 $@"
cmd_args="${@:1}"

# =================================================================== #
if [ $CLEAN_DIST == 1 ]; then
  rm -rf install
  rm -rf builds
  unlink bin
  exit 0
fi
# =================================================================== #

# =================================================================== #
if [ $BUILD_SOLVER == 0 -a $BUILD_3PL == 0 ]; then
  echo "=================================================================="
  echo "Building OCCA and Demo..."
  echo "=================================================================="
  echo " "

  cd scripts

  # build 3PL libraries
  ./build_3PL.sh $cmd_args

  # build Demo library
  ./build_Demo.sh $cmd_args

  cd ..

  echo
  echo "================================================"
  echo -e "${gC} Finished Successfully...${eC}"
  echo -e " Executable: ${GC}builds/Demo_release/bin/Demo?d.mpi${eC}"
  echo "================================================"
  exit 0
fi

# ================================ #
# BUILD INDIVIDUAL COMPONENTS ONLY #
# ================================ #
if [ $BUILD_3PL == 1 ]; then
  echo "========================================================"
  echo "Building the 3rd Party Libraries..."
  echo "========================================================"

  cd scripts
  ./build_3PL.sh $cmd_args
  cd ..
fi

if [ $BUILD_SOLVER == 1 ]; then
  echo "================="
  echo "Building Demo..."
  echo "================="

  cd scripts
  ./build_Demo.sh $cmd_args
  cd ..

  echo
  echo "================================================"
  echo -e "${gC} Finished Successfully...${eC}"
  echo -e " Executable: ${GC}builds/Demo_release/bin/Demo?d.mpi${eC}"
  echo "================================================"
fi
# =================================================================== #
