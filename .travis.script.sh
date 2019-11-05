#!/bin/bash -xe

DOCKER_ORG="brunovalere"
DOCKER_IMAGE="example-webserver"
DOCKER_TAG="latest"

MANIFEST=${DOCKER_ORG}/${DOCKER_IMAGE}:${DOCKER_TAG}

platforms=(arm arm64 amd64)
manifest_args=(${MANIFEST})

#
# remove any previous builds
#

rm -Rf target
mkdir target

#
# generate image for each platform
#

for platform in "${platforms[@]}"; do 
    docker run -it --rm --privileged -v ${PWD}:/tmp/work --entrypoint buildctl-daemonless.sh moby/buildkit:master \
           build \
           --frontend dockerfile.v0 \
           --opt platform=linux/${platform} \
           --opt filename=./Dockerfile \
           --output type=docker,name=${MANIFEST}-${platform},dest=/tmp/work/target/${DOCKER_IMAGE}-${platform}.docker.tar \
           --local context=/tmp/work \
           --local dockerfile=/tmp/work \
           --progress plain

    manifest_args+=("${MANIFEST}-${platform}")
    
done

#
# login to docker hub
#
