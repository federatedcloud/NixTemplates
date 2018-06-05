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

TEST_IMG="${REPO}_${TAG}_TEST"
docker create --name "$TEST_IMG" "$NIX_OMPI_IMAGE"
docker cp "$TEST_IMG:/tmp/.nix_versions" "$BASEDIR"
docker cp "$TEST_IMG:/tmp/env_backup.drv" "$BASEDIR"
docker rm -f "$TEST_IMG"
