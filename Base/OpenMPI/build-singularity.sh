#!/bin/bash

GITROOT=$(git rev-parse --show-toplevel)
BASEDIR=$(dirname "${BASH_SOURCE[0]}")
export BASEDIR

#
# **** Pick a Distro to build below by uncommenting a section ****
#
# shellcheck source=/dev/null
# source "$GITROOT/Base/ubuntu_envs.sh"
source "$GITROOT/Base/alpine_envs.sh"

# shellcheck source=/dev/null
source "$GITROOT/Utils/image_tag.sh"
NIXUSER="nixuser"
REPO="nix_${BASEOS}_openmpi"
TAG=$(git_image_tag)
export ENVSDIR="/nixenv/$NIXUSER"
export NIX_OMPI_IMAGE="${REPO}_${TAG}"
echo "NIX_OMPI_IMAGE is $NIX_OMPI_IMAGE"

# echo "SINGULARITY_DOCKER_USERNAME is set to ${SINGULARITY_DOCKER_USERNAME}"
# echo "SINGULARITY_DOCKER_PASSWORD is set to ${SINGULARITY_DOCKER_PASSWORD}"
cat "${BASEDIR}/SingTemplate" | envsubst '${BASEDIR} ${BASEOS} ${ENVSDIR}' > "${BASEDIR}/Singularity.${NIX_OMPI_IMAGE}"
sudo singularity --debug build "${BASEDIR}/${NIX_OMPI_IMAGE}.img" "${BASEDIR}/Singularity.${NIX_OMPI_IMAGE}"
