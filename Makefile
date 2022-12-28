install:
	@./install.sh \
	$(if $(dir),-d $(dir)) \
	$(if $(shell),-s $(shell)) \
	$(if $(filter true 1,$(yes)),-y) \
	$(if $(filter true 1,$(local)),-l)

ubuntu:
	@docker build -t dotfiles-ubuntu \
		$(if $(dir),--build-arg dir=$(dir)) \
		$(if $(shell),--build-arg shell=$(shell)) \
		$(if $(filter true 1,$(yes)),--build-arg yes=1) \
		$(if $(filter true 1,$(local)),--build-arg local=1) \
		$(if $(filter true 1,$(quiet)),--quiet) \
	-f os/docker/Dockerfile.ubuntu .
	@docker run -it --rm dotfiles-ubuntu

ubuntu-push:
	@docker build -t davidduarte/dotfiles:ubuntu -f os/docker/Dockerfile.ubuntu .
	@docker push davidduarte/dotfiles:ubuntu

fedora:
	@docker build -t dotfiles-fedora \
		$(if $(dir),--build-arg dir=$(dir)) \
		$(if $(shell),--build-arg shell=$(shell)) \
		$(if $(filter true 1,$(yes)),--build-arg yes=1) \
		$(if $(filter true 1,$(local)),--build-arg local=1) \
		$(if $(filter true 1,$(quiet)),--quiet) \
	-f os/docker/Dockerfile.fedora .
	@docker run -it --rm dotfiles-fedora

fedora-push:
	@docker build -t davidduarte/dotfiles:fedora -f os/docker/Dockerfile.fedora .
	@docker push davidduarte/dotfiles:fedora

.PHONY: install ubuntu fedora ubuntu-push fedora-push
