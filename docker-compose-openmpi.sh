#!/bin/bash

#
# This is a wrapper for docker-compose that performs
# some variable substitution - just sue as you normally would
# docker-compose, except for -f <file.yml>, which is already included
#
#
# See BASEDIR/build.sh for a simpler way to build the docker image, without compose
#

BASEDIR="Docker/OpenMPI"
export BASEDIR
REPO=nix_ubuntu_openmpi
TAG=testing0
export NIX_IMAGE="${REPO}:${TAG}"

docker-compose -f docker-compose-openmpi.yml "$@"


