export TOOLCHAIN=$1
echo "Will install Octopus using toolchain $TOOLCHAIN"
export ARCH=`archspec cpu`
echo "ARCH is $ARCH"

git clone https://gitlab.gwdg.de/mpsd-cs/mpsd-software-environments.git
cd mpsd-software-environments
ls -l
./mpsd-software.py --help
./mpsd-software.py -l debug install dev-23a --toolchain ${TOOLCHAIN}

cd ..
pwd

eval `/usr/share/lmod/lmod/libexec/lmod use mpsd-software-environments/dev-23a/$ARCH/lmod/Core`
eval `/usr/share/lmod/lmod/libexec/lmod avail`

echo "It seems the toolchain foss2022a-mpi is compiled (based on checking logfiles)"
echo "but the module file generation has failed. Not enough detail in the logs to see why."
echo "perhaps some dependency is missing?"

eval `/usr/share/lmod/lmod/libexec/lmod load toolchains/$TOOLCHAIN`

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
cp ../../../mpsd-software-environments/dev-23a/spack-environments/octopus/$TOOLCHAIN-config.sh .
source $TOOLCHAIN-config.sh --prefix=`pwd`
make
echo "make check is next"




