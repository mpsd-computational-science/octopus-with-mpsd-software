TOOLCHAIN="foss2022a-serial"
MPSD_RELEASE="dev-23a"

docker-dev-23a-foss2022a-serial:
		docker build --no-cache --progress=plain -f Dockerfile --build-arg MPSD_RELEASE=$(MPSD_RELEASE) --build-arg TOOLCHAIN=foss2022a-serial -t octopus-toolchain .

docker-dev-23a-foss2022a-mpi:
		docker build --progress=plain -f Dockerfile --build-arg MPSD_RELEASE=$(MPSD_RELEASE) --build-arg TOOLCHAIN=foss2022a-mpi -t octopus-toolchain .

docker-run:
	docker run --rm -v `pwd`:/io -it octopus-toolchain

docker-build-base-environment:
	docker build  --target base-environment --progress=plain -f Dockerfile -t octopus-base-environment .

docker-build-octopus: docker-build-base-environment
	docker build  --target build-environment  --progress=plain -f Dockerfile --build-arg MPSD_RELEASE=$(MPSD_RELEASE) --build-arg TOOLCHAIN=$(TOOLCHAIN) -t octopus-binary-environment .

.PHONY: dev-23a-foss2022a-mpi

clean:
	rm -rf mpsd-software-environments
	rm -rf build-octopus
