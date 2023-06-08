# We can later generalise this script to work for multiple toolchains (via a
# command line argument). At the moment, we use it to show that things work for
# one toolchain.

# we follow instructions from
# https://computational-science.mpsd.mpg.de/docs/mpsd-hpc.html#loading-a-toolchain-to-compile-octopus

export ARCH=`archspec cpu`
echo "ARCH is $ARCH"
eval `/usr/share/lmod/lmod/libexec/lmod use mpsd-software-environments/dev-23a/$ARCH/lmod/Core`
eval `/usr/share/lmod/lmod/libexec/lmod avail`

echo "It seems the toolchain foss2022a-mpi is compiled (based on checking logfiles)"
echo "but the module file generation has failed. Not enough detail in the logs to see why."
echo "perhaps some dependency is missing?"

eval `/usr/share/lmod/lmod/libexec/lmod load toolchains/foss2022a-mpi`
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




