#!/bin/bash -l

#------------------------------------------------------------------------------#
#   run command
#------------------------------------------------------------------------------#
if [ -z "${1}" ]; then
    exec /bin/bash
fi

eval $@