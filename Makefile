install:
	@./install.sh \
	$(if $(dir),-d $(dir)) \
	$(if $(shell),-s $(shell)) \
	$(if $(filter true 1,$(yes)),-y) \
	$(if $(filter true 1,$(local)),-l)

ubuntu:
	@docker build -t dotfiles-ubuntu-minimal \
		$(if $(dir),--build-arg dir=$(dir)) \
		$(if $(shell),--build-arg shell=$(shell)) \
		$(if $(filter true 1,$(yes)),--build-arg yes=1) \
		$(if $(filter true 1,$(local)),--build-arg local=1) \
		$(if $(filter true 1,$(quiet)),--quiet) \
	-f docker/Dockerfile.ubuntu .
	@docker run -it --rm dotfiles-ubuntu-minimal

ubuntu-push:
	@docker build -t davidduarte/dotfiles:ubuntu-minimal -f docker/Dockerfile.ubuntu .
	@docker push davidduarte/dotfiles:ubuntu-minimal

fedora:
	@docker build -t dotfiles-fedora-minimal \
		$(if $(dir),--build-arg dir=$(dir)) \
		$(if $(shell),--build-arg shell=$(shell)) \
		$(if $(filter true 1,$(yes)),--build-arg yes=1) \
		$(if $(filter true 1,$(local)),--build-arg local=1) \
		$(if $(filter true 1,$(quiet)),--quiet) \
	-f docker/Dockerfile.fedora .
	@docker run -it --rm dotfiles-fedora-minimal

fedora-push:
	@docker build -t davidduarte/dotfiles:fedora-minimal -f docker/Dockerfile.fedora .
	@docker push davidduarte/dotfiles:fedora-minimal

.PHONY: install ubuntu fedora ubuntu-push fedora-push
