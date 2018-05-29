#!/bin/bash

# NIXUSER="$(whoami)"
NIXUSER="nixuser"
REPO=nix_ubuntu_base
TAG=testing0
ENVSDIR="/nixenv/$NIXUSER"
export NIX_IMAGE="${REPO}:${TAG}"
docker build \
       --build-arg nixuser="$NIXUSER" \
       --build-arg ENVSDIR="$ENVSDIR" \
       -t "$NIX_IMAGE" -f Dockerfile .
# docker build --pull --tag kurron/intellij-local:latest .
