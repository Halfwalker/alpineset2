# aplineset2

Toolset bundles Ansible developing and testing tools in a single container.

## Install a couple of things first

```bash
pip install --user pip-compile-multi
docker network create molecule
```

## Rebuild the requirements.txt

This is done during the `docker build` but can be done here to see exactly what will be installed

```bash
pip-compile --allow-unsafe --no-annotate --output-file=requirements.txt requirements.in
```

## Build the container image with docker or podman

```bash
make all
docker run --rm halfwalker/alpineset2 molecule --version
```

## Run the container with bash to use any of the tools

```bash
docker run --rm -it quay.io/halfwalker/alpineset2 bash
```

## More detailed run

Specifies the docker network to use locally - needed to allow molecule container to speak to working container (ubuntu2204)
```
docker run --rm -it --network molecule -e GH_USER=${GH_USER} -e GH_TOKEN=${GH_TOKEN} -e MOLECULE_DISTRO=ubuntu2204 -e DOCKER_HOST=unix:///var/run/docker.sock -v "$(pwd)":"${PWD}" -w "${PWD}" -v /var/run/docker.sock:/var/run/docker.sock quay.io/halfwalker/alpineset2 bash
```

## Running testinfra pytest manually in container

Can run a test manually, without molecule.  Example here is with the `ansible-vim` role

Must set MOLECULE_INVENTORY_FILE env variable first

```
export MOLECULE_INVENTORY_FILE=/root/.cache/molecule/$(basename ${PWD})/default/inventory/ansible_inventory.yml
pytest --ansible-inventory /root/.cache/molecule/$(basename ${PWD})/default/inventory --connection ansible  --debug -p no:cacheprovider -s molecule/default/tests/test_default.py -vvv
```

## What is bundled inside the container

Generally the containers should bundle the latest stable versions of the tools below. An exact list can be seen in [requirements.txt](https://github.com/ansible-community/toolset/blob/main/requirements.txt) file used for building the container.

* [ansible](https://pypi.org/project/ansible/)
* [ansible-lint](https://pypi.org/project/ansible-lint/)
* [molecule](https://pypi.org/project/molecule/) and most of its plugins
* [yamllint](https://yamllint.readthedocs.io/en/stable/) (used by ansible-lint)
* [vault](https://www.vaultproject.io/downloads)
* [Packer](https://www.terraform.io/downloads)
* docker
* podman
