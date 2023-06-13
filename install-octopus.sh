export TOOLCHAIN=$1
export MPSD_RELEASE=$2
eval `/usr/share/lmod/lmod/libexec/lmod use "/home/user/mpsd-software-environments/${MPSD_RELEASE}/$(archspec cpu)/lmod/Core"`
eval `/usr/share/lmod/lmod/libexec/lmod avail`
eval `/usr/share/lmod/lmod/libexec/lmod load toolchains/${TOOLCHAIN}`

source ${TOOLCHAIN}-config.sh --prefix=`pwd`/installed
make -j
make install
# run a simple octopus example
echo "CalculationMode = recipe" > inp
installed/bin/octopus
echo "make check is next"




