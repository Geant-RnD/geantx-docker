#!/bin/bash -le

ROOT_DIR=${PWD}
if [ "${TIMEMORY}" = "ON" ]; then
    export PATH=/opt/conda/bin:${PATH}
    : ${TIMEMORY_BRANCH:="master"}
    git clone -b ${TIMEMORY_BRANCH} https://github.com/jrmadsen/TiMemory.git timemory-source
    cd timemory-source
    SOURCE_DIR=${PWD}
    mkdir timemory-build
    cd timemory-build
    BINARY_DIR=${PWD}
    cmake -DCMAKE_INSTALL_PREFIX=/opt/local -DCMAKE_BUILD_TYPE=${BUILD_TYPE} -DPYTHON_EXECUTABLE=$(which python) ${SOURCE_DIR} -G Ninja
    ninja
    ninja install
    cd ${ROOT_DIR}
    rm -rf ${BINARY_DIR} ${SOURCE_DIR}
fi
