#!/bin/bash

# NIXUSER="$(whoami)"

GITROOT=$(git rev-parse --show-toplevel)
# shellcheck source=/dev/null
source "$GITROOT/Utils/image_tag.sh"
NIXUSER="nixuser"
REPO=nix_ubuntu_base
TAG=$(git_image_tag)
ENVSDIR="/nixenv/$NIXUSER"
export NIX_IMAGE="${REPO}:${TAG}"
docker build \
       --build-arg nixuser="$NIXUSER" \
       --build-arg ENVSDIR="$ENVSDIR" \
       -t "$NIX_IMAGE" -f Dockerfile .
# docker build --pull --tag kurron/intellij-local:latest .
