#!/bin/bash

# shellcheck source=/dev/null
source "Utils/singularity-build-common.sh"

# NIXUSER="$(whoami)"

#
# **** Pick a Distro to build below by uncommenting a section ****
#
# source "ubuntu_envs.sh"
source "Base/alpine_envs.sh"

source "Utils/image_tag.sh"
NIXUSER="nixuser"
REPO="nix_${BASEOS}_base"
TAG=$(git_image_tag)
export ENVSDIR="/nixenv/$NIXUSER"
export NIX_IMAGE="${REPO}_${TAG}"
source "$HOME/.singularity_docker_creds.sh"
cat "$HOME/.singularity_docker_creds.sh"
echo "SINGULARITY_DOCKER_USERNAME is set to ${SINGULARITY_DOCKER_USERNAME}"
echo "SINGULARITY_DOCKER_PASSWORD is set to ${SINGULARITY_DOCKER_PASSWORD}"
cat SingTemplateBase | envsubst '${BASEIMG} ${ENVSDIR} ${DISTRO_INSTALL_CMDS}' > "Singularity.${NIX_IMAGE}"
sudo singularity --debug build "${NIX_IMAGE}.img" "Singularity.${NIX_IMAGE}"
sudo chown "$SING_USER:$SING_GROUP" "${NIX_IMAGE}.img"


