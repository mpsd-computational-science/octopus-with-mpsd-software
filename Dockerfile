FROM debian:bullseye AS base-environment

# # which spack version are we using now? Default is develop
# # but other strings can be given to the docker build command
# # (for example docker build --build-arg SPACK_VERSION=v0.16.2)
ARG TOOLCHAIN=UNDEFINED
ARG MPSD_RELEASE=dev-23a
RUN echo "MPSD_RELEASE=${MPSD_RELEASE}"
RUN echo "TOOLCHAIN=${TOOLCHAIN}"
RUN cat /etc/issue
# Install dependencies
RUN apt-get -y update
# From https://github.com/ax3l/dockerfiles/blob/master/spack/base/Dockerfile:
# install minimal spack dependencies
RUN apt-get install -y --no-install-recommends \
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
    python \
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

# WORKDIR /home/user
# RUN pwd
# # clone installation script
# RUN git clone https://gitlab.gwdg.de/mpsd-cs/mpsd-software-environments.git
# WORKDIR /home/user/mpsd-software-environments
# # RUN git fetch -a
# # RUN git checkout more-robust-micro-architecture-detection
# # RUN git pull -v
# # RUN git branch
# RUN ls -l
# 
# # RUN ./mpsd-software-environment.py --help
# # 
# # RUN ./mpsd-software-environment.py -l debug install dev-23a --toolchain ${TOOLCHAIN}

WORKDIR /home/user

# call toolchain compilation and compilation of octopus demo into separate script
# ADD install-octopus.sh .
# RUN ls -l
# RUN bash -e -x install-octopus.sh ${TOOLCHAIN}

# for debugging, switch to root
USER root
RUN echo "use user 'user' for normal operation ('su - user')"
# Provide bash in case the image is meant to be used interactively
CMD /bin/bash

FROM base-environment AS toolchain-environtment 
# This part of the docker file contains instructions to build the toolchain
USER user
WORKDIR /home/user
ARG TOOLCHAIN=UNDEFINED
ARG MPSD_RELEASE=dev-23a
RUN echo "MPSD_RELEASE=${MPSD_RELEASE}"
RUN echo "TOOLCHAIN=${TOOLCHAIN}"
RUN cat /etc/issue
RUN git clone https://gitlab.gwdg.de/mpsd-cs/mpsd-software-environments.git
WORKDIR /home/user/mpsd-software-environments
RUN ls -l
RUN ./mpsd-software.py --help
RUN ./mpsd-software.py -l debug install dev-23a --toolchain ${TOOLCHAIN}

# for debugging, switch to root
USER root
RUN echo "use user 'user' for normal operation ('su - user')"
# Provide bash in case the image is meant to be used interactively
CMD /bin/bash

FROM toolchain-environtment AS octopus-build
# This part of the docker file contains instructions to build octopus 
# with the toolchain built in the previous step

USER user
WORKDIR /home/user
ARG TOOLCHAIN=UNDEFINED
ARG MPSD_RELEASE=dev-23a
RUN echo "MPSD_RELEASE=${MPSD_RELEASE}"
RUN echo "TOOLCHAIN=${TOOLCHAIN}"
RUN cat /etc/issue


RUN echo "It seems the toolchain foss2022a-mpi is compiled (based on checking logfiles)"
RUN echo "but the module file generation has failed. Not enough detail in the logs to see why."
RUN echo "perhaps some dependency is missing?"


# we follow instructions from
# https://computational-science.mpsd.mpg.de/docs/mpsd-hpc.html#loading-a-toolchain-to-compile-octopus

RUN mkdir -p build-octopus
WORKDIR /home/user/build-octopus
RUN git clone https://gitlab.com/octopus-code/octopus.git
WORKDIR /home/user/build-octopus/octopus
RUN pwd
RUN ls -l
RUN autoreconf -fi
RUN mkdir _build
WORKDIR /home/user/build-octopus/octopus/_build
RUN pwd
RUN cp /home/user/mpsd-software-environments/dev-23a/spack-environments/octopus/$TOOLCHAIN-config.sh .
RUN ls -l
ADD install-octopus.sh .
RUN bash install-octopus.sh ${TOOLCHAIN}


