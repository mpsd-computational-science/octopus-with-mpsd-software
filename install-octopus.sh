export TOOLCHAIN=$1
export MPSD_RELEASE=$2
export BUILD_DIR=$3
# Inside the build directory, we create two folders:
# - for the toolchain ($BUILD_DIR/toolchains/)
# - for the octopus compilation ($BUILD_DIR/octopus-compilation)

### Choose the configuration parameters
# Debug mode
export debug_mode=0 # 0 is off; 1 is on
# select toolchain_dir if you dont want to recompile the toolchain
# if you want to compile the toolchain, set toolchain_dir to None
export toolchain_dir=None
# choose the branch of Octopus to compile
# Can also be a commit hash
export octopus_branch=main
# Post compilation options:

# check short?
export check_short=0 # 0 is off 1 is on
# check long?
export check_long=0 # 0 is off 1 is on
# Choose an example from `examples` folder to run at the end of compilation
# use `none` to skip running an example at the end of compilation
export example_to_run=None

### Non configurable parameters
export toolchain_name=toolchains/${TOOLCHAIN}
export OMP_NUM_THREADS=$SLURM_CPUS_PER_TASK
export script_dir=$(pwd)
export OCT_TEST_NJOBS=8
export OCT_TEST_MPI_NPROCS=2
export MPIEXEC=orterun
# Create a module bash function to avoid long cmds
module () {
        eval $(/usr/share/lmod/lmod/libexec/lmod bash "$@")
        }

### BUILD THE TOOLCHAIN ###
# if toolchain_dir is NONE, echo the toolchain name 
if [ $toolchain_dir == None ]; then
    echo "Building the toolchain"
    mkdir -p $BUILD_DIR/toolchains
    cd $BUILD_DIR/toolchains
    git clone https://gitlab.gwdg.de/mpsd-cs/mpsd-software-manager .
    ./mpsd-software.py --help
    ./mpsd-software.py --version
    # build requested toolchain
    ./mpsd-software.py -l debug install ${MPSD_RELEASE} --toolchain ${TOOLCHAIN}

    export toolchain_dir="$BUILD_DIR/toolchains/${MPSD_RELEASE}/$(archspec cpu)/lmod/Core"
else
    echo "Using the toolchain at $toolchain_dir"
fi


### BUILD OCTOPUS ###

module purge
# Module use
if [ $toolchain_dir != None ]; then
    module use $toolchain_dir
else
    mpsd-modules $MPSD_RELEASE
fi
# module load
module load $toolchain_name
# if debugging, print location of gcc mpicc
if [ $debug_mode == 1 ]; then
    echo "gcc is at:"
    which gcc
    echo "mpicc is at:"
    which mpicc
fi

# make the project folder
export project_folder="$BUILD_DIR/octopus-compilation"
mkdir -p $project_folder
cd $project_folder

# Git operations
# if octopus folder dosent exists clone it
if [ ! -d "octopus" ]; then
    git clone https://gitlab.com/octopus-code/octopus.git
    cd octopus
    git checkout $octopus_branch
else
    cd octopus
    git checkout $octopus_branch
    git pull
fi

# if debugging, pprint the current commit hash
if [ $debug_mode == 1 ]; then
    echo " available files:"
    ls -l
    echo "Current commit hash:"
    git rev-parse HEAD
fi

# compile octopus
autoreconf -i
mkdir _build
cd _build
# copy config wrapper from toolchain_dir or MPSD_RELEASE
if [ $toolchain_dir != None ]; then
    cp $toolchain_dir/../../../spack-environments/octopus/$TOOLCHAIN-config.sh .
else
    cp /opt_mpsd/linux-debian11/$MPSD_RELEASE/spack-environments/octopus/$TOOLCHAIN-config.sh .
fi
# if debugging, pprint the config file
if [ $debug_mode == 1 ]; then
    echo "config file:"
    ls -l
    echo "config options:"
    cat $TOOLCHAIN-config.sh
fi
source $TOOLCHAIN-config.sh --prefix=$script_dir/$project_folder/octopus/_build/installed
make -j $SLURM_CPUS_PER_TASK
make install

# make check short and check long
if [ $check_short == 1 ]; then
    make check-short
fi
if [ $check_long == 1 ]; then
    make check-long
fi

# run an example
if [ $example_to_run != None ]; then
    mkdir -p example_run
    cd example_run
    cp -r $script_dir/examples/$example_to_run/* .
    mpirun -np $SLURM_NTASKS ../../octopus/_build/installed/bin/octopus
fi




