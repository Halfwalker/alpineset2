#
# See podmain-image/Containerfile for template
#

FROM alpine as toolset-builder
LABEL maintainer="Halfwalker <halfwalker@gmail.com>"

ENV PATH="/opt/toolset/bin:$PATH"
ENV PIP_INSTALL_ARGS="--upgrade"
ENV PACKAGES="\
git \
py3-yaml \
py3-debian \
py3-virtualenv py3-pip \
"

COPY requirements.in /tmp/requirements.in

RUN \
apk update && \
apk add ${PACKAGES} && \
python3 -m venv /opt/toolset

RUN \
pip3 list --format=freeze | grep -v '^\-e' | cut -d = -f 1 | xargs -n1 pip3 install -U && \
pip install pip-compile-multi && \
pip-compile --allow-unsafe --no-annotate --output-file=/tmp/requirements.txt /tmp/requirements.in && \
python3 -m pip install ${PIP_INSTALL_ARGS} -r /tmp/requirements.txt && \
python3 -m pip install ${PIP_INSTALL_ARGS} ansible-lint urllib3 ruamel.yaml.clib


# Final stage
FROM alpine 

ENV SHELL /bin/bash
ENV PYTHONDONTWRITEBYTECODE=1
ENV ANSIBLE_FORCE_COLOR=1
ENV PATH="/opt/toolset/bin:$PATH"

COPY --from=toolset-builder /opt/toolset /opt/toolset

# nodejs needed for github/gitea actions
RUN \
  apk update && \
  apk add nodejs ca-certificates bash gnupg curl docker-cli podman python3 py3-pip py3-debian git fuse-overlayfs crun cgroup-tools sudo unzip gzip tar && \
  rm -rf /var/cache/apk/*

###    RUN \
###    apt-get update -y && \
###    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends nodejs jq unzip packer vault python3 python3-distutils python3-debian curl git gnupg libseccomp-dev docker.io podman fuse-overlayfs crun uidmap cgroup-tools cgroup-lite libcgroup1 && \
###    apt-get clean && \
###    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN adduser -D podman; \
echo -e "podman:1:999\npodman:1001:64535" > /etc/subuid; \
echo -e "podman:1:999\npodman:1001:64535" > /etc/subgid;
# echo podman:10000:5000 > /etc/subuid; \
# echo podman:10000:5000 > /etc/subgid;

#
# Can pull in containers.conf and storage.conf from podman repo
#
# ADD https://raw.githubusercontent.com/containers/libpod/master/contrib/podmanimage/stable/containers.conf /etc/containers/containers.conf
# ADD https://raw.githubusercontent.com/containers/libpod/master/contrib/podmanimage/stable/podman-containers.conf /home/podman/.config/containers/containers.conf
# chmod containers.conf and adjust storage.conf to enable Fuse storage.
# RUN chmod 644 /etc/containers/containers.conf; sed -i -e 's|^#mount_program|mount_program|g' -e '/additionalimage.*/a "/var/lib/shared",' -e 's|^mountopt[[:space:]]*=.*$|mountopt = "nodev,fsync=0"|g' /etc/containers/storage.conf

#
# Or can use our own copy of containers.conf and storage.conf already modified
#
COPY containers.conf /etc/containers/containers.conf
COPY storage.conf /etc/containers/storage.conf
COPY podman-containers.conf /home/podman/.config/containers/containers.conf
COPY versions.sh /etc/bash/0-versions.sh
COPY bash_aliases.sh /etc/bash/molecule.sh
COPY bash_aliases.sh /home/podman/.bash_aliases

RUN chown podman:podman -R /home/podman

# Note VOLUME options must always happen after the chown call above
# RUN commands can not modify existing volumes
VOLUME /var/lib/containers
VOLUME /home/podman/.local/share/containers

RUN mkdir -p /var/lib/shared/overlay-images /var/lib/shared/overlay-layers /var/lib/shared/vfs-images /var/lib/shared/vfs-layers; touch /var/lib/shared/overlay-images/images.lock; touch /var/lib/shared/overlay-layers/layers.lock; touch /var/lib/shared/vfs-images/images.lock; touch /var/lib/shared/vfs-layers/layers.lock

ENV _CONTAINERS_USERNS_CONFIGURED=""

RUN set -ex && echo "========================================================================" && \
python3 -m pip check && \
molecule --version && \
yamllint --version && \
ansible --version && \
ansible-lint --version && \
docker --version && \
podman --version && \
git --version

# Use a more convenient default command than the base image
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
CMD /bin/bash

