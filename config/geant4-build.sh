#!/bin/bash -e

# function for running command verbosely
run-verbose()
{
    echo -e "\nRunning : '$@'...\n"
    eval $@
}

# work in this directory
cd /tmp

# default settings, can be overridden by environment settings in Dockerfile
: ${BUILD_TYPE:=Release}
: ${SHARED:=ON}
: ${STATIC:=OFF}
: ${CXXSTD:=11}
: ${MT:=ON}
: ${TLS:=initial-exec}
: ${USE_TIMEMORY:=OFF}
: ${USE_HDF5:=OFF}
: ${USE_X11:=ON}
: ${USE_QT:=ON}
: ${VERBOSE:=OFF}
: ${USE_USOLIDS:=OFF}
: ${TYPE:=minimal}
: ${TAG:="master"}
: ${PARALLEL_JOBS:=4}

if [ -n "$(which nproc)" ]; then
    PARALLEL_JOBS=$(nproc)
fi

#-----------------------------------------------------------------------------#
#
#   Geant4
#
#-----------------------------------------------------------------------------#

# clone the Geant4 repository
run-verbose git clone https://gitlab.cern.ch/geant4/geant4.git /tmp/geant4-source

# checkout the tag
if [ -n "${TAG}" ]; then
    cd /tmp/geant4-source
    git checkout ${TAG}
    cd /tmp
fi

# make a build directory
mkdir /tmp/geant4-build

# generate the CMake configuration
run-verbose \
    cmake \
        -DBUILD_TYPE=${BUILD_TYPE} \
        -DSHARED=${SHARED} \
        -DSTATIC=${STATIC} \
        -DCXXSTD=${CXXSTD} \
        -DMT=${MT} \
        -DTLS=${TLS} \
        -DTESTS=${TESTS} \
        -DVERBOSE=${VERBOSE} \
        -DUSE_TIMEMORY=${USE_TIMEMORY} \
        -DUSE_HDF5=${USE_HDF5} \
        -DUSE_X11=${USE_X11} \
        -DUSE_QT=${USE_QT} \
        -DUSE_USOLIDS=${USE_USOLIDS} \
        -DGEANT4_INSTALL_DATA=ON \
        -DGEANT4_USE_GDML=ON \
        -DGEANT4_INSTALL_EXAMPLES=OFF \
    -P /tmp/configure-file.cmake

#-----------------------------------------------------------------------------#

# enter build directory
cd /tmp/geant4-build

# echo for debugging
echo -e "\n\n####################################################################################\n"
cat geant4-config.cmake
echo -e "\n\n####################################################################################\n"

# run CMake
run-verbose cmake -C geant4-config.cmake /tmp/geant4-source

# copy cmake configuration to place it can be referred to later
cp geant4-config.cmake /usr/local/share/

#-----------------------------------------------------------------------------#

# build and install Geant4
run-verbose make -j${PARALLEL_JOBS} install

#-----------------------------------------------------------------------------#
