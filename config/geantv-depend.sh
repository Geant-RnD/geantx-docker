#!/bin/bash -e

VC_VERSION=1.3.3

## Common

TOP_DIR=/tmp
INSTALL_DIR=/usr/local
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

cd ${SOURCE_DIR}

# install ROOT
cd ${SOURCE_DIR}
run-verbose wget https://root.cern/download/root_v6.16.00.source.tar.gz \
 && tar xvzf root_v6.16.00.source.tar.gz \
 && rm root_v6.16.00.source.tar.gz

setup-build

run-verbose cmake ${SOURCE_DIR}/root-6.16.00 -DCMAKE_INSTALL_PREFIX=${INSTALL_DIR} -G Ninja
run-verbose cmake --build ${PWD} --target all
run-verbose cmake --build ${PWD} --target install
run-verbose source ${INSTALL_DIR}/bin/thisroot.sh

cd ${SOURCE_DIR}
run-verbose git clone https://github.com/VcDevel/Vc.git
cd Vc
run-verbose git checkout ${VC_VERSION}

cd ${SOURCE_DIR}
run-verbose git clone https://gitlab.cern.ch/hepmc/HepMC3.git
cd HepMC3
run-verbose git checkout 3.0.0

cd ${SOURCE_DIR}
run-verbose git clone https://github.com/root-project/VecCore.git
cd VecCore
run-verbose git checkout v0.5.2

cd ${SOURCE_DIR}
run-verbose git clone https://github.com/root-project/VecMath.git
cd VecMath
run-verbose git checkout master

cd ${SOURCE_DIR}
run-verbose git clone https://gitlab.cern.ch/VecGeom/VecGeom.git
cd VecGeom
run-verbose git checkout v00.05.01

### Environment settings
: ${VECGEOM_VECTOR:=avx}
: ${VECGEOM_BACKEND:=vc}

### Build Vc

setup-build
run-verbose cmake ${SOURCE_DIR}/Vc -DCMAKE_INSTALL_PREFIX=${INSTALL_DIR} -G Ninja
run-verbose cmake --build ${PWD} --target all
run-verbose cmake --build ${PWD} --target install

### Build HepMC [requires ROOT]

setup-build
run-verbose cmake ${SOURCE_DIR}/HepMC3 -DCMAKE_INSTALL_PREFIX=${INSTALL_DIR} \
    -DROOT_DIR=${ROOTSYS}/cmake
run-verbose cmake --build ${PWD} --target all
run-verbose cmake --build ${PWD} --target install

### Build VecCore

setup-build
run-verbose cmake -DCMAKE_INSTALL_PREFIX=${INSTALL_DIR} \
    -DROOT=ON \
    -DBACKEND=Vc \
    -DVc_DIR=${INSTALL_DIR}/lib/cmake/Vc/ \
    ${SOURCE_DIR}/VecCore -G Ninja
run-verbose cmake --build ${PWD} --target all
run-verbose cmake --build ${PWD} --target install

### Build VecMath

setup-build
run-verbose cmake ${SOURCE_DIR}/VecMath -DCMAKE_INSTALL_PREFIX=${INSTALL_DIR} -DBACKEND=Vc
run-verbose cmake --build ${PWD} --target all
run-verbose cmake --build ${PWD} --target install

### Build VecGeom

setup-build
run-verbose cmake -DCMAKE_INSTALL_PREFIX=${INSTALL_DIR} \
    -DROOT=ON \
    -DBACKEND=Vc \
    -DVc_DIR=${INSTALL_DIR}/lib/cmake/Vc/ \
    ${SOURCE_DIR}/VecGeom -G Ninja
run-verbose cmake --build ${PWD} --target all
run-verbose cmake --build ${PWD} --target install
