#!/bin/bash

BASEDIR=$(dirname "${BASH_SOURCE[0]}")
REPO=nix_ubuntu_openmpi
TAG=testing0
export NIX_IMAGE="${REPO}:${TAG}"
docker build \
       --build-arg BASEDIR="$BASEDIR" \
       -t "$NIX_IMAGE" -f "$BASEDIR/Dockerfile" .
# docker build --pull --tag kurron/intellij-local:latest .
