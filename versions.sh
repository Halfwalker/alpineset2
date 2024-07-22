#!/bin/bash
pip-check --hide-unchanged --show-update
python3 -m pip check
molecule --version
ansible --version
ansible-lint --version
yamllint --version
echo "Docker versions"
docker version
podman --version
git --version
