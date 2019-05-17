#!/bin/bash -e

## Common

TOP_DIR=/tmp
INSTALL_DIR=/opt/local
BUILD_DIR=${TOP_DIR}/build
SOURCE_DIR=${TOP_DIR}/sources

# mkdir -p ${SOURCE_DIR}
# mkdir -p ${INSTALL_DIR}

# clean the build directory
setup-build()
{
    mkdir -p ${BUILD_DIR}
    cd ${BUILD_DIR}
    rm -rf ${BUILD_DIR}/*
}

# function for running command verbosely
run-verbose()
{
    echo -e "\nRunning : '$@'...\n"
    eval $@
}

### Checkout GeantExascalePilot

# cd ${SOURCE_DIR}
# run-verbose git clone https://github.com/Geant-RnD/GeantExascalePilot.git

run-verbose apt-get -y autoclean
run-verbose rm -rf /var/lib/apt/lists/*
