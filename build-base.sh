#!/bin/bash

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
export NIX_IMAGE="${REPO}:${TAG}"
docker build \
       --build-arg BASEIMG="$BASEIMG" \
       --build-arg ADDUSER="$ADDUSER" \
       --build-arg DISTRO_INSTALL_CMDS="$DISTRO_INSTALL_CMDS" \
       --build-arg nixuser="$NIXUSER" \
       --build-arg ENVSDIR="$ENVSDIR" \
       -t "$NIX_IMAGE" -f Dockerfile-Base .
# docker build --pull --tag kurron/intellij-local:latest .
