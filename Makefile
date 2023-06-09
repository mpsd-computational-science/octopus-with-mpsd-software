bare-metal-dev-23a-foss2022a-serial:
		bash -x -e install-octopus.sh foss2022a-serial


docker-dev-23a-foss2022a-serial:
		docker build --no-cache --progress=plain -f Dockerfile --build-arg MPSD_RELEASE=dev-23a --build-arg TOOLCHAIN=foss2022a-serial -t octopus-toolchain .

docker-dev-23a-foss2022a-mpi:
		docker build --progress=plain -f Dockerfile --build-arg MPSD_RELEASE=dev-23a --build-arg TOOLCHAIN=foss2022a-mpi -t octopus-toolchain .

docker-run:
	docker run --rm -v `pwd`:/io -it octopus-toolchain

.PHONY: dev-23a-foss2022a-mpi

