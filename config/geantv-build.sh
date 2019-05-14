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

### Checkout GeantV

cd ${SOURCE_DIR}
run-verbose git clone https://gitlab.cern.ch/GeantV/geant.git

# dummy to fool it into downloading file
mkdir -p geant/data
cp geant/examples/physics/FullCMS/Geant4/cms.gdml geant/data/cms2018.gdml

### Build GeantV
setup-build
run-verbose cmake -DCMAKE_INSTALL_PREFIX=${INSTALL_DIR} \
    -DVc_DIR=$INSTALL_DIR/lib/cmake/Vc \
    -DVecCore_DIR=$INSTALL_DIR/share/VecCore/cmake \
    -DVecCoreLib_DIR=$INSTALL_DIR/lib/cmake/VecCoreLib \
    -DVecGeom_DIR=$INSTALL_DIR/lib/CMake/VecGeom \
    -DHepMC_DIR=$INSTALL_DIR/cmake/ \
    -DUSE_ROOT=ON -DWITH_GEANT4=ON \
    -DDATA_DOWNLOAD=ON \
    -DVECTORIZED_GEOMETRY=ON \
    -DUSE_VECPHYS=OFF \
    -DBUILD_REAL_PHYSICS_TESTS=OFF \
    ${SOURCE_DIR}/geant -G Ninja

run-verbose cmake --build ${PWD} --target all
run-verbose cmake --build ${PWD} --target install

run-verbose apt-get -y autoclean
run-verbose rm -rf /var/lib/apt/lists/*
