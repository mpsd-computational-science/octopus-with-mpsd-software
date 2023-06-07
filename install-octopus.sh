# We can later generalise this script to work for multiple toolchains (via a
# command line argument). At the moment, we use it to show that things work for
# one toolchain.

# we follow instructions from
# https://computational-science.mpsd.mpg.de/docs/mpsd-hpc.html#loading-a-toolchain-to-compile-octopus

mkdir -p build-octopus
cd build-octopus
git clone https://gitlab.com/octopus-code/octopus.git
cd octopus
pwd
ls -l
autoreconf -fi
mkdir _build
cd _build
cp ../../../mpsd-software-environments/dev-23a/spack-environments/octopus/foss2022a-mpi-config.sh .
source foss2022a-mpi-config.sh --prefix=`pwd`
make
make check




