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
: ${BUILD_TYPE:=RelWithDebInfo}
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
