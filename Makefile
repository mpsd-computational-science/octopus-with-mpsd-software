# Using most recent spack version with preferred version of octopus
dev-23a-foss2022a-mpi:
		docker build --progress=plain -f Dockerfile --build-arg MPSD_RELEASE=dev-23a --build-arg TOOLCHAIN=foss2022a-mpi -t octopus-toolchain .

run:
	docker run --rm -v `pwd`:/io -it octopus-toolchain

.PHONY: dev-23a-foss2022a-mpi

