# To enable using pytest right on cmdline
# pytest --ansible-inventory /root/.cache/molecule/$(basename ${PWD})/default/inventory --connection ansible  --debug -p no:cacheprovider -s molecule/default/tests/test_default.py -vvv
#
export MOLECULE_INVENTORY_FILE=/root/.cache/molecule/$(basename ${PWD})/default/inventory/ansible_inventory.yml
alias testit='pytest --ansible-inventory /root/.cache/molecule/$(basename ${PWD})/default/inventory --connection ansible  --debug -p no:cacheprovider -s molecule/default/tests/test_default.py -vvv'

echo "----------------------------------------------------------"
echo "Use 'testit' alias to run pytest against running container"
echo "MOLECULE_INVENTORY_FILE = ${MOLECULE_INVENTORY_FILE}"
echo "podman playbooks in /opt/toolset/lib/python3.11/site-packages/molecule_plugins/podman/playbooks"
echo "----------------------------------------------------------"
