export TOOLCHAIN=$1
export MPSD_RELEASE=$2
export BUILD_DIR=$3

# Create a module bash function to avoid long cmds
module () {
        eval $(/usr/share/lmod/lmod/libexec/lmod bash "$@")
        }


### Choose the configuration parameters
# trial number, useful to keep track of different runs
export run_no=1 
# project prefix, is used for the name of the output folder
# assumend format {project-prefix}-{run_no}-{slurm_partition}-{octopus-branch}
export project_prefix=octopus-compilation

# Debug mode
export debug_mode=0 # 0 is off; 1 is on
# choose the branch of Octopus to compile
# Can also be a commit hash
export octopus_branch=13c28011effdfa5e8e636bb0b4780be8c46893dc
# choose the toolchain software stack 
# either set toolchain_dir or mpsd_sft_ver and NOT BOTH
# toolchain_dir is the path to the toolchain directory (if manually compiled)
# mpsd_sft_ver is the version that is provided by default on MPSD HPCs
# ( keep defaults if you dont know what these are)
# toolcain_dir= should be in the format /path/to/lmod/Core
export mpsd_sft_ver=dev-23a
export toolchain_dir=None
# choose the toolchain version
export toolchain_version=foss2022a-mpi

# Post compilation options:

# check short?
export check_short=1 # 0 is off 1 is on
# check long?
export check_long=1 # 0 is off 1 is on
# Choose an example from `examples` folder to run at the end of compilation
# use `none` to skip running an example at the end of compilation
export example_to_run=benzene

### Non configurable parameters
export toolchain_name=toolchains/${toolchain_version}
export OMP_NUM_THREADS=$SLURM_CPUS_PER_TASK
export script_dir=$(pwd)
export OCT_TEST_NJOBS=8
export OCT_TEST_MPI_NPROCS=2
export MPIEXEC=orterun



module purge
# Module use
if [ $toolchain_dir != None ]; then
    module use $toolchain_dir
else
    mpsd-modules $mpsd_sft_ver
fi
# module load
module load $toolchain_name
# if debugging, pprint location of gcc mpicc
if [ $debug_mode == 1 ]; then
    echo "gcc is at:"
    which gcc
    echo "mpicc is at:"
    which mpicc
fi

# make the project folder
export project_folder=${project_prefix}-${run_no}-${SLURM_PARTITION}-${octopus_branch}
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
# copy config wrapper from toolchain_dir or mpsd_sft_ver
if [ $toolchain_dir != None ]; then
    cp $toolchain_dir/../../../spack-environments/octopus/$toolchain_version-config.sh .
else
    cp /opt_mpsd/linux-debian11/$mpsd_sft_ver/spack-environments/octopus/$toolchain_version-config.sh .
fi
# if debugging, pprint the config file
if [ $debug_mode == 1 ]; then
    echo "config file:"
    ls -l
    echo "config options:"
    cat $toolchain_version-config.sh
fi
source $toolchain_version-config.sh --prefix=$script_dir/$project_folder/octopus/_build/installed
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

eval `/usr/share/lmod/lmod/libexec/lmod use "/home/user/mpsd-software/${MPSD_RELEASE}/$(archspec cpu)/lmod/Core"`
eval `/usr/share/lmod/lmod/libexec/lmod avail`
eval `/usr/share/lmod/lmod/libexec/lmod load toolchains/${TOOLCHAIN}`

source ${TOOLCHAIN}-config.sh --prefix=`pwd`/installed
make -j
make install
# run a simple octopus example
echo "CalculationMode = recipe" > inp
installed/bin/octopus
echo "make check is next"




