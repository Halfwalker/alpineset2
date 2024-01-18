#!/bin/sh

# Since non-root containers is a volume, have to set perms
# AFTER container has started up
chown -R podman:podman /home/podman/.local/share/containers

exec "$@"
