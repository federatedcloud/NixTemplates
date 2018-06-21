#!/bin/bash

# NIXUSER="$(whoami)"

#
# **** Pick a Distro to build below by uncommenting a section ****
#
# source "ubuntu_envs.sh"
source "alpine_envs.sh"

GITROOT=$(git rev-parse --show-toplevel)
# shellcheck source=/dev/null
source "$GITROOT/Utils/image_tag.sh"
export NIXUSER="nixuser"
REPO="nix_${BASEOS}_base"
TAG=$(git_image_tag)
export ENVSDIR="/nixenv/$NIXUSER"
export NIX_IMAGE="${REPO}:${TAG}"
source "$HOME/.singularity_docker_creds.sh"
cat "$HOME/.singularity_docker_creds.sh"
echo "SINGULARITY_DOCKER_USERNAME is set to ${SINGULARITY_DOCKER_USERNAME}"
echo "SINGULARITY_DOCKER_PASSWORD is set to ${SINGULARITY_DOCKER_PASSWORD}"
singularity build "${NIX_IMAGE}.img" Singularity
# docker build --pull --tag kurron/intellij-local:latest .
