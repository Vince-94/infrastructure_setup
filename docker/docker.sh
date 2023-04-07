#!/bin/bash

source docker/docker_env.sh

#! Environment variables

# Docker path
DOCKER_HOME=/home/$UBUNTU_USER
LOCAL_WS_PATH=$PWD/$WS_VOLUME
DOCKER_WS_PATH=$DOCKER_HOME/$WS_VOLUME

# ROS2 version
if [[ $UBUNTU_RELEASE == 20.04 ]]; then
	UBUNTU_CODENAME=focal
elif [[ $UBUNTU_RELEASE == 22.04 ]]; then
    UBUNTU_CODENAME=jellyfish
else
	echo "Error: Unsupported Ubuntu release"
	return 0
fi

# Docker file/image/container
DOCKER_FILE=Dockerfile_${UBUNTU_CODENAME}_${TAG}
DOCKER_IMAGE=registry.gitlab.com/${REPO_AUTHOR}/${REPO_NAME}-image
DOCKER_CONTAINER=${REPO_NAME}-${TAG}-container

# Print info
echo "Ubuntu: $UBUNTU_CODENAME ($UBUNTU_RELEASE LTS)"
echo ""


#! Commands

# build
if [[ $1 == "build" ]]; then
    echo "Build docker image:
    - Dockerfile name:  $DOCKER_FILE
    - Dockerimage name: $DOCKER_IMAGE:$TAG
    "

    docker build --rm \
                 --build-arg UBUNTU_USER=$UBUNTU_USER \
                 --build-arg UBUNTU_UID=$UBUNTU_UID \
                 --build-arg UBUNTU_PSW=$UBUNTU_PSW \
                 -f $PWD/docker/$DOCKER_FILE \
                 --target $BUILD_STAGE \
                 -t $DOCKER_IMAGE:$TAG .

# push
elif [[ $1 == "push" ]]; then
    echo "Push dockerimage to GitLab container registry
    "

    docker login registry.gitlab.com
    docker push $DOCKER_IMAGE:$TAG

# run
elif [[ $1 == "run" ]]; then
    echo "Run $DOCKER_CONTAINER -> $DOCKER_IMAGE:$TAG
    "

    xhost +     # enable access to xhost from the container

    docker run  -it --rm --privileged \
                -h $USER \
                -v /etc/localtime:/etc/localtime:ro \
                -e LOCAL_USER_ID=$UBUNTU_UID \
                -e USER=$UBUNTU_USER \
                -e DISPLAY=$DISPLAY \
                -e QT_X11_NO_MITSHM=1 \
                -e XAUTHORITY=/tmp/.docker.xauth \
                -v /tmp/.X11-unix:/tmp/.X11-unix \
                -v /tmp/.docker.xauth:/tmp/.docker.xauth \
                -p 14556:14556/udp \
                -v $LOCAL_WS_PATH:$DOCKER_WS_PATH:rw \
                -w $DOCKER_WS_PATH \
                --name $DOCKER_CONTAINER \
                $DOCKER_IMAGE:$TAG /bin/bash

# exec
elif [[ $1 == "exec" ]]; then
    echo "Join $DOCKER_CONTAINER"

    docker exec -it -w $DOCKER_WS_PATH $DOCKER_CONTAINER bash -c "/ubuntu_entrypoint.sh ; bash"

# permission
elif [[ $1 == "permission" ]]; then
    echo "Change folder permission to USER"

    sudo chown -R $USER:$USER $PWD/$WS_VOLUME           # set user ownership
    sudo chmod -R a+rwx $PWD/$WS_VOLUME                 # set user permissions

# config
elif [[ $1 == "config" ]]; then
    echo "Configuring Docker permission/ownership"

    sudo chown -R $USER:$USER /home/$USER/.docker       # set docker ownership
    sudo chmod -R g+rwx "$HOME/.docker"                 # set docker permissions

    sudo groupadd docker                                # create the docker group
    sudo usermod -aG docker $USER                       # add your user to the docker group
    newgrp docker                                       # activate the changes to groups

# clean
elif [[ $1 == "clean" ]]; then
    echo "Clean all the not needed images and container"

    docker image prune -f
    docker container prune -f

# info
elif [[ $1 == "info" ]]; then
    echo "Show docker environment info
    "
    echo "Project info
    - Project name:             $REPO_NAME
    - Project author:           $REPO_AUTHOR"
    echo "Ubuntu info
    - Ubuntu distro:            $UBUNTU_CODENAME ($UBUNTU_RELEASE LTS)
    - Ubuntu user:              $UBUNTU_USER ($UBUNTU_UID)"
    echo "Container info
    - Dockerfile name:          $DOCKER_FILE
    - Docker image name:        $DOCKER_IMAGE:$TAG
    - Docker image tag:         $TAG
    - Docker container name:    $DOCKER_CONTAINER"

# help
elif [[ $1 == "help" ]]; then
    echo "Command list:
    - [build]:      build the Dockerfile to create the image (dockerimage)
    - [push]:       push dockerimage to GitLab container registry
    - [run]:        run the dockerimage into a containter
    - [exec]:       join to the existing container
    - [permission]: add user permissions to docker envoronment
    - [config]:     configure Docker after installation
    - [clean]:      remove not needed images and container
    - [info]:       show docker environment info
    - [help]:       show script commands"

# default
else
    echo "Use `source docker.sh help` to see all the commands"

fi