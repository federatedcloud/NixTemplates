#!/bin/bash

GITROOT=$(git rev-parse --show-toplevel)
BASEDIR=$(dirname "${BASH_SOURCE[0]}")

#
# **** Pick a Distro to build below by uncommenting a section ****
#
# shellcheck source=/dev/null
# source "$GITROOT/Base/ubuntu_envs.sh"
source "$GITROOT/Base/alpine_envs.sh"

# shellcheck source=/dev/null
source "$GITROOT/Utils/image_tag.sh"
REPO="nix_${BASEOS}_openmpi"
TAG=$(git_image_tag)
export NIX_OMPI_IMAGE="${REPO}:${TAG}"
echo "NIX_OMPI_IMAGE is $NIX_OMPI_IMAGE"
docker build \
       --build-arg BASEDIR="$BASEDIR" \
       --build-arg ADDUSER="$ADDUSER" \
       --build-arg BASEOS="$BASEOS" \
       -t "$NIX_OMPI_IMAGE" -f "$BASEDIR/Dockerfile" .

TEST_IMG="${REPO}_${TAG}_TEST"
docker create --name "$TEST_IMG" "$NIX_OMPI_IMAGE"
docker cp "$TEST_IMG:/tmp/.nix_versions" "$BASEDIR"
docker cp "$TEST_IMG:/tmp/env_backup.drv" "$BASEDIR"
docker rm -f "$TEST_IMG"

# echo "SINGULARITY_DOCKER_USERNAME is set to ${SINGULARITY_DOCKER_USERNAME}"
# echo "SINGULARITY_DOCKER_PASSWORD is set to ${SINGULARITY_DOCKER_PASSWORD}"
cat SingTemplate | envsubst '${BASEDIR} ${BASEOS}' > "Singularity.${NIX_OMPI_IMAGE}"
sudo singularity --debug build "${NIX_OMPI_IMAGE}.img" "Singularity.${NIX_OMPI_IMAGE}"
