#!/bin/bash

# NIXUSER="$(whoami)"

#
# **** Pick a Distro to build below by uncommenting a section ****
#

#
# For Alpine
#
BASEIMG="alpine:3.7"
BASEOS="alpine"
ADDUSER="adduser -D -g \"\""
DISTRO_INSTALL_CMDS="alpine_install_cmds.sh"

#
# For Ubuntu
#
#
# # BASEIMG="nvidia/cuda:8.0-cudnn7-runtime-ubuntu16.04"
# BASEIMG="ubuntu:18.04"
# BASEOS="ubuntu"
# ADDUSER="adduser --disabled-password --gecos \"\""
# DISTRO_INSTALL_CMDS="ubuntu_install_cmds.sh"

GITROOT=$(git rev-parse --show-toplevel)
# shellcheck source=/dev/null
source "$GITROOT/Utils/image_tag.sh"
NIXUSER="nixuser"
REPO="nix_${BASEOS}_base"
TAG=$(git_image_tag)
ENVSDIR="/nixenv/$NIXUSER"
export NIX_IMAGE="${REPO}:${TAG}"
docker build \
       --build-arg BASEIMG="$BASEIMG" \
       --build-arg ADDUSER="$ADDUSER" \
       --build-arg DISTRO_INSTALL_CMDS="$DISTRO_INSTALL_CMDS" \
       --build-arg nixuser="$NIXUSER" \
       --build-arg ENVSDIR="$ENVSDIR" \
       -t "$NIX_IMAGE" -f Dockerfile .
# docker build --pull --tag kurron/intellij-local:latest .
