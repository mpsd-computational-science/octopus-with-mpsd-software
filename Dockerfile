FROM debian:bullseye

# # which spack version are we using now? Default is develop
# # but other strings can be given to the docker build command
# # (for example docker build --build-arg SPACK_VERSION=v0.16.2)
ARG toolchain=foss-2021a
ARG MPSD_RELEASE=dev-23a
RUN echo "MPSD_RELEASE=${MPSD_RELEASE}"
RUN echo "toolchain=${toolchain}"
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
RUN apt-get -y install rsync

RUN echo "deb http://deb.debian.org/debian bullseye-backports main" >> /etc/apt/sources.list
RUN apt-get -y update
CMD bash -l
RUN apt-get -y install pipx
# use funny locations so user 'user' can execute the program
RUN PIPX_HOME=/opt/pipx PIPX_BIN_DIR=/usr/local/bin pipx install archspec

RUN rm -rf /var/lib/apt/lists/*

RUN adduser user

# prepare mount point
RUN mkdir /io
RUN chown -R user /io

USER user

WORKDIR /home/user
RUN pwd
# clone installation script
RUN git clone https://gitlab.gwdg.de/mpsd-cs/mpsd-software-environments.git
WORKDIR /home/user/mpsd-software-environments
# RUN git fetch -a
# RUN git checkout more-robust-micro-architecture-detection
# RUN git pull -v
# RUN git branch
RUN ls -l

RUN ./mpsd-software-environment.py --help

RUN ./mpsd-software-environment.py -l debug install dev-23a --toolchain foss2022a-mpi

# RUN 

USER root
RUN echo "use user 'user' for normal operation ('su - user')"
# Provide bash in case the image is meant to be used interactively
CMD /bin/bash -l
# 
# 
