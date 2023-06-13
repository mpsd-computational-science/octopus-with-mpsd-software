export TOOLCHAIN=$1
eval `/usr/share/lmod/lmod/libexec/lmod use "/home/user/mpsd-software-environments/dev-23a/$(archspec cpu)/lmod/Core"`
eval `/usr/share/lmod/lmod/libexec/lmod avail`
eval `/usr/share/lmod/lmod/libexec/lmod load toolchains/$TOOLCHAIN`

source $TOOLCHAIN-config.sh --prefix=`pwd`
make -j
make install
# run a simple octopus example
echo "CalculationMode = reci" > inp
bin/octopus
echo "make check is next"




