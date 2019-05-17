#!/bin/bash -e

VC_VERSION=1.3.3

## Common

TOP_DIR=/tmp
INSTALL_DIR=/opt/local
BUILD_DIR=${TOP_DIR}/build
SOURCE_DIR=${TOP_DIR}/sources

mkdir -p ${SOURCE_DIR}
mkdir -p ${INSTALL_DIR}
mkdir -p ${BUILD_DIR}

# clean the build directory
setup-build()
{
    cd ${BUILD_DIR}
    rm -rf ${BUILD_DIR}/*
}

# function for running command verbosely
run-verbose()
{
    echo -e "\nRunning : '$@'...\n"
    eval $@
}

# clone the repos
cd ${SOURCE_DIR}
run-verbose git clone https://github.com/root-project/VecCore.git
run-verbose git clone https://github.com/root-project/VecMath.git
run-verbose git clone https://gitlab.cern.ch/VecGeom/VecGeom.git

### Environment settings

: ${VECGEOM_VECTOR:=avx}
: ${VECGEOM_BACKEND:=scalar}

### Build VecCore

setup-build
run-verbose cmake ${SOURCE_DIR}/VecCore -DCMAKE_INSTALL_PREFIX=${INSTALL_DIR} -DVC=OFF -G Ninja
run-verbose cmake --build ${PWD} --target all
run-verbose cmake --build ${PWD} --target install

### Build VecMath

setup-build
run-verbose cmake ${SOURCE_DIR}/VecMath -DCMAKE_INSTALL_PREFIX=${INSTALL_DIR} -DBACKEND=scalar
run-verbose cmake --build ${PWD} --target all
run-verbose cmake --build ${PWD} --target install

### Build VecGeom

setup-build
run-verbose cmake -DCMAKE_INSTALL_PREFIX=${INSTALL_DIR} \
    -DBUILTIN_VECCORE=OFF \
    -DBACKEND=${VECGEOM_BACKEND} \
    -DCUDA=ON -DCUDA_VOLUME_SPECIALIZATION=OFF \
    -DNO_SPECIALIZATION=ON -DROOT=OFF \
    -DVECGEOM_VECTOR=${VECGEOM_VECTOR} \
    ${SOURCE_DIR}/VecGeom -G Ninja
run-verbose cmake --build ${PWD} --target all
run-verbose cmake --build ${PWD} --target install
