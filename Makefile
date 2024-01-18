.EXPORT_ALL_VARIABLES:

# Keep docker before podman due to:
# https://github.com/containers/podman/issues/7602
ENGINE ?= $(shell command -v docker podman|head -n1)
IMAGE_TAG=halfwalker/alpineset2
QUAY_TAG=quay.io/halfwalker/alpineset2

all:
	$(ENGINE) build -t $(IMAGE_TAG) -t $(QUAY_TAG) .
	@echo "Image size: $$($(ENGINE) image inspect --format='scale=0; {{.Size}}/1024/1024' $(IMAGE_TAG) | bc)MB"

deps:
	pip-compile --allow-unsafe --no-annotate --output-file=requirements.txt requirements.in
	# tox -e deps

into:
	$(ENGINE) run -h alpineset2 -it $(IMAGE_TAG) /bin/bash

push:
	$(ENGINE) push $(QUAY_TAG)
	$(ENGINE) push $(IMAGE_TAG)
