# alpineset2

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

Specifies the docker network to use locally (created above) - needed to allow molecule container to speak to working container (ubuntu2204 here)

```bash
docker run --rm -it --network molecule -e GH_USER=${GH_USER} -e GH_TOKEN=${GH_TOKEN} -e MOLECULE_DISTRO=ubuntu2204 -e DOCKER_HOST=unix:///var/run/docker.sock -v "$(pwd)":"${PWD}" -w "${PWD}" -v /var/run/docker.sock:/var/run/docker.sock quay.io/halfwalker/alpineset2 bash
```

* Set `GH_USER` and `GH_TOKEN` to your github user/token to avoid rate limiting from github. Use them in ansible tasks (optionally)

    ```yaml
    - name: Get latest release for each git package in cloud_tools
      uri:
        url: "https://api.github.com/repos/{{ item.repo }}/releases"
        method: GET
        return_content: true
        status_code: 200
        body_format: json
        validate_certs: false
        user: "{{ lookup('env', 'GH_USER') | default(omit) }}"
        password: "{{ lookup('env', 'GH_TOKEN') | default(omit) }}"
        force_basic_auth: "{% if lookup('env', 'GH_USER') %}yes{% else %}no{% endif %}"
          :
    ```

* `MOLECULE_DISTRO` is a handy way to specify which `geerlingguy` container to use.  Example `molecule.yml`

    ```yaml
    dependency:
      name: galaxy
    driver:
      name: podman

    platforms:
      - name: "cloud_tools-${MOLECULE_DISTRO:-ubuntu2004}"
        # Default to dockerhub unless a local cache is defined
        # Default to ubuntu2004 unless a distro is defined
        image: "${HUB_CACHE:-registry.hub.docker.com}/geerlingguy/docker-${MOLECULE_DISTRO:-ubuntu2004}-ansible:latest"
        # Specify not-rootless, otherwise newer ansible fails with 'msg: could not find job'
        # See https://github.com/ansible-community/molecule-podman/issues/77
        rootless: false
          :
    ```

## Running testinfra pytest manually in container

Can run a test manually, without molecule.

Must set MOLECULE_INVENTORY_FILE env variable first

```bash
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
