#!/bin/bash

GITROOT=$(git rev-parse --show-toplevel)
BASEDIR=$(dirname "${BASH_SOURCE[0]}")
# shellcheck source=/dev/null
source "$GITROOT/Utils/image_tag.sh"
REPO=nix_ubuntu_openmpi
TAG=$(git_image_tag)
export NIX_OMPI_IMAGE="${REPO}:${TAG}"
echo "NIX_OMPI_IMAGE is $NIX_OMPI_IMAGE"
docker build \
       --build-arg BASEDIR="$BASEDIR" \
       -t "$NIX_OMPI_IMAGE" -f "$BASEDIR/Dockerfile" .
