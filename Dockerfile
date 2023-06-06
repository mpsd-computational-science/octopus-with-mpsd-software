FROM debian:bullseye

# # which spack version are we using now? Default is develop
# # but other strings can be given to the docker build command
# # (for example docker build --build-arg SPACK_VERSION=v0.16.2)
ARG toolchain=foss-2021a
ARG MPSD_RELEASE=dev-23a
RUN echo "MPSD_RELEASE=${MPSD_RELEASE}"
RUN echo "toolchain=${toolchain}"

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


# Tools needed by mpsd-software-environment.py (and ../spack-setup.sh)
RUN apt-get -y install rsync

# Convenience tools, if desired for debugging etc
RUN apt-get -y install wget time nano vim emacs vim

RUN rm -rf /var/lib/apt/lists/*

# mount point
RUN mkdir -p /io

RUN adduser user
USER user

WORKDIR /home/user
RUN pwd
# clone installation script
RUN git clone https://gitlab.gwdg.de/mpsd-cs/mpsd-software-environments.git
WORKDIR /home/user/mpsd-software-environments
RUN pwd
RUN ls -l

RUN ./mpsd-software-environment.py --help
 
RUN ./mpsd-software-environment.py -l debug install dev-23a --toolchain foss2022a-mpi
 
# Provide bash in case the image is meant to be used interactively
CMD /bin/bash -l

