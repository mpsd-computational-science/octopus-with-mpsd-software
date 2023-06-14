export TOOLCHAIN=$1
export MPSD_RELEASE=$2
cd ~
git clone https://gitlab.gwdg.de/mpsd-cs/mpsd-software.git
ls -l
./mpsd-software.py --help
./mpsd-software.py --version
# build requested toolchain
./mpsd-software.py -l debug install ${MPSD_RELEASE} --toolchain ${TOOLCHAIN}
