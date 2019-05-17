################################################################################
#   Build stage 1
################################################################################
ARG BASE_IMG=ubuntu
ARG BASE_TAG=latest
FROM ${BASE_IMG}:${BASE_TAG} as builder

USER root
ENV HOME /root
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US
ENV LC_ALL C
ENV SHELL /bin/bash
ENV BASH_ENV /etc/bash.bashrc
ENV DEBIAN_FRONTEND noninteractive

WORKDIR /tmp

# build and env args used by package-manager
ARG COMPILER_TYPE
ARG COMPILER_VERSION
ENV COMPILER_TYPE ${COMPILER_TYPE}
ENV COMPILER_VERSION ${COMPILER_VERSION}

# package-manager configuration
COPY ./config/apt.sh /tmp/apt.sh
RUN ./apt.sh

# build arguments
ARG SHARED=ON
ARG STATIC=OFF
ARG CXXSTD=11
ARG TIMEMORY=OFF
ARG BUILD_TYPE=RelWithDebInfo
ARG SOFTWARE=geant4

# environment settings
ENV BUILD_TYPE      ${BUILD_TYPE}
ENV SHARED          ${SHARED}
ENV STATIC          ${STATIC}
ENV CXXSTD          ${CXXSTD}
ENV TIMEMORY        ${TIMEMORY}
ENV SOFTWARE        ${SOFTWARE}

# cmake script for generating templates
COPY ./config/configure-file.cmake /tmp/configure-file.cmake

# copy over all the "-config", "-depend", and "-build" scripts
COPY ./config/*-depend.sh /tmp/
COPY ./config/*-build.sh /tmp/
COPY ./config/*-config.cmake.in /tmp/

# build the common dependencies
RUN ./common-depend.sh
# build the software specific dependencies
RUN ./${SOFTWARE}-depend.sh
# build the software
RUN ./${SOFTWARE}-build.sh
# clean up
RUN rm -rf /tmp/*

################################################################################
#   Build stage 2 - compress to 1 layer
################################################################################
FROM scratch

COPY --from=builder / /

ENV HOME /root
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US
ENV LC_ALL C
ENV SHELL /bin/bash
ENV BASH_ENV /etc/bash.bashrc
ENV DEBIAN_FRONTEND noninteractive

ARG REQUIRE_CUDA_VERSION=10.0
ENV CUDA_HOME "/opt/local/cuda"
ENV NVIDIA_REQUIRE_CUDA "cuda>=${REQUIRE_CUDA_VERSION}"
ENV NVIDIA_VISIBLE_DEVICES "all"
ENV NVIDIA_DRIVER_CAPABILITIES "compute,utility"

ENV CC /usr/bin/cc
ENV CXX /usr/bin/c++
ENV CUDACC /opt/local/cuda/bin/nvcc
ENV CUDACXX /opt/local/cuda/bin/nvcc

#------------------------------------------------------------------------------#
#   interactive settings and startup
#------------------------------------------------------------------------------#
COPY ./config/etc/profile.d/*.sh /etc/profile.d/
COPY ./config/etc/bash.bashrc /etc/
COPY ./config/etc/compute-dir-size.py /etc/
COPY ./config/root/* /root/
COPY ./config/runtime-entrypoint.sh /runtime-entrypoint.sh

USER root
WORKDIR /home
SHELL [ "/bin/bash", "--login", "-c" ]
ENTRYPOINT [ "/runtime-entrypoint.sh" ]
