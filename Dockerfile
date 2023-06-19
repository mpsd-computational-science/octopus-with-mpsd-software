# Dockerfile for building the toolchains and octopus
# the build is split into 2 stages:
# 1. base-environment: contains the base environment for building the toolchain
# 2. build-environment: contains the build of toolchains and octopus
FROM debian:bullseye AS base-environment

RUN cat /etc/issue
# Install dependencies
RUN apt-get -y update
# From https://github.com/ax3l/dockerfiles/blob/master/spack/base/Dockerfile:
# install minimal spack dependencies
RUN apt-get install -y \
            autoconf \
            build-essential \
            ca-certificates \
            coreutils \
            curl \
            environment-modules \
            file \
            gfortran \
            git \
            openssh-server \
            python-is-python3 \
            python3-pip \
            unzip

# Convenience tools, if desired for debugging etc
RUN apt-get -y install wget time nano vim emacs vim

# Tools needed by mpsd-software-environment.py (and ../spack-setup.sh)
RUN apt-get -y install rsync automake libtool linux-headers-amd64


# prepare for pipx installation (to enable archspec installation)
RUN echo "deb http://deb.debian.org/debian bullseye-backports main" >> /etc/apt/sources.list
RUN apt-get -y update
CMD bash -l
RUN apt-get -y install pipx
# use funny locations so user 'user' can execute the program
RUN PIPX_HOME=/opt/pipx PIPX_BIN_DIR=/usr/local/bin pipx install archspec

# Tools needed by install-octopus.sh
# install lmod from debian testing as we need lmod 8.6.5 or newer
RUN echo "deb http://deb.debian.org/debian testing main" >> /etc/apt/sources.list
RUN apt-get -y update && apt-get -y install lmod

# tidy up
# RUN rm -rf /var/lib/apt/lists/*

RUN adduser user

# prepare mount point
RUN mkdir /io
RUN chown -R user /io

USER user

WORKDIR /home/user
# for debugging, switch to root
USER root
RUN echo "use user 'user' for normal operation ('su - user')"
# Provide bash in case the image is meant to be used interactively
CMD /bin/bash


FROM base-environment AS build-environment 
# This part of the docker file contains instructions to build the toolchain
# needs the following arguments:
# TOOLCHAIN: the name of the toolchain to build (e.g. foss2022a-mpi)
# MPSD_RELEASE: the name of the mpsd release to build (e.g. dev-23a)
USER user
WORKDIR /home/user
ARG TOOLCHAIN=UNDEFINED
ARG MPSD_RELEASE=dev-23a
RUN echo "MPSD_RELEASE=${MPSD_RELEASE}"
RUN echo "TOOLCHAIN=${TOOLCHAIN}"
RUN cat /etc/issue
RUN git clone https://gitlab.gwdg.de/mpsd-cs/mpsd-software.git
WORKDIR /home/user/mpsd-software
RUN python3 -m pip install  /home/user/mpsd-software
RUN ls -l
ENV PATH /home/user/.local/bin:$PATH
RUN mpsd-software --help
RUN mpsd-software --version
# build requested toolchain
# RUN ./mpsd-software.py -l debug install ${MPSD_RELEASE} ${TOOLCHAIN}

ADD install-octopus.sh .
# we follow instructions from
# https://computational-science.mpsd.mpg.de/docs/mpsd-hpc.html#loading-a-toolchain-to-compile-octopus

RUN bash install-octopus.sh ${TOOLCHAIN} ${MPSD_RELEASE} /home/user/octopus_build


