#!/bin/bash

# source exe_docker.sh <CMD> <PROJECT_NAME> <STAGE>

source docker/config.env $2 $3

if [ $? -ne 0 ]; then
    return 1
fi


#! Environment variables

# Docker path
DOCKER_HOME=/home/$UBUNTU_USER
LOCAL_WS_PATH=$WS_PATH/$WS_NAME
DOCKER_WS_PATH=$DOCKER_HOME/$WS_NAME
PROJECT_FOLDER=$REPO_AUTHOR/$REPO_NAME

# Docker file/image/container
# DOCKER_FILE=Dockerfile
DOCKER_IMAGE=${PROJECT_FOLDER}-image
DOCKER_REG_IMAGE=registry.gitlab.com/drone5205538/infrastructure_setup
DOCKER_CONTAINER=${REPO_NAME}-container


#! Commands

# build
if [[ $1 == "build" ]]; then
    echo "Build docker image:
    - Dockerfile name:  $DOCKER_FILE
    - Dockerimage name: $DOCKER_IMAGE:$TAG
    - Stage:            $BUILD_STAGE
    "

    build_args=(
        "UBUNTU_USER":$UBUNTU_USER
        "UBUNTU_PSW":$UBUNTU_PSW
        "UBUNTU_UID":$UBUNTU_UID
        "UBUNTU_GID":$UBUNTU_GID
    )

    DOCKER_BUILD_ARGS=()
    for key in "${build_args[@]}" ; do
        DOCKER_BUILD_ARGS+="--build-arg ${key%%:*}=${key#*:} "
    done

    docker build --pull --rm \
                 --build-arg BASE_IMAGE=$BASE_IMAGE \
                 $DOCKER_BUILD_ARGS \
                 -f $PWD/docker/$DOCKER_FILE \
                 --target $BUILD_STAGE \
                 -t $DOCKER_IMAGE:$TAG .

# push
elif [[ $1 == "push" ]]; then
    echo "Push dockerimage to GitLab container registry: $DOCKER_IMAGE -> $DOCKER_REG_IMAGE
    "
    docker login registry.gitlab.com

    # docker push $DOCKER_IMAGE:$TAG

    docker tag $DOCKER_IMAGE:$TAG $DOCKER_REG_IMAGE:$TAG
    docker push $DOCKER_REG_IMAGE:$TAG
    docker rmi $DOCKER_REG_IMAGE:$TAG

# run
elif [[ $1 == "run" ]]; then
    echo "Run $DOCKER_CONTAINER -> $DOCKER_IMAGE:$TAG
    "
    xhost +     # enable access to xhost from the container
    echo

    # Check workspace folder validity
    echo "Workspace dir: ${LOCAL_WS_PATH}"
    if [ -d "$LOCAL_WS_PATH" ]; then
        DOCKER_VOLUMES="-v ${LOCAL_WS_PATH}:${DOCKER_WS_PATH}:rw"
    else
        echo "ERROR: No workspace provided!"
        return
    fi

    # Check libraries folder validity
    if [ -d "$LIBS_PATH" ]; then
        echo "External libraries dir: $LIBS_PATH"
        for item in "$LIBS_PATH"/*; do
            if [ -e "$item" ]; then
                filename=$(basename "$item")
                DOCKER_VOLUMES+=" -v $LIBS_PATH/$filename:$DOCKER_HOME/$filename:rw"
            fi
        done
    fi

    # Check config folder validity
    if [ -d "$CONFIG_PATH" ]; then
        echo "Config dir: $CONFIG_PATH"
        shopt -s dotglob
        for item in "$CONFIG_PATH"/*; do
            if [ -e "$item" ]; then
                filename=$(basename "$item")
                DOCKER_VOLUMES+=" -v $CONFIG_PATH/$filename:$DOCKER_WS_PATH/$filename:rw"
            fi
        done
    fi

    # Docker container command
    echo "Docker container cmd: $DOCKER_RUN_CMD"

    docker run  -it --rm --privileged \
                -h $HOSTNAME \
                -e LOCAL_USER_ID=$UBUNTU_UID \
                -e USER=$UBUNTU_USER \
                -e UID=${UBUNTU_UID} \
                -e GROUPS=${UBUNTU_GID} \
                -e DISPLAY=$DISPLAY \
                -e QT_X11_NO_MITSHM=1 \
                -e XAUTHORITY=/tmp/.docker.xauth \
                -p 14556:14556/udp \
                --network=host \
                -v /etc/localtime:/etc/localtime:ro \
                -v /tmp/.X11-unix:/tmp/.X11-unix \
                -v /tmp/.docker.xauth:/tmp/.docker.xauth \
                ${DOCKER_VOLUMES} \
                -v /dev:/dev \
                --device /dev:/dev \
                -w $DOCKER_WS_PATH \
                --name $DOCKER_CONTAINER \
                $DOCKER_IMAGE:$TAG $DOCKER_RUN_CMD

# exec
elif [[ $1 == "exec" ]]; then
    echo "Join $DOCKER_CONTAINER"
    docker exec -it -w $DOCKER_WS_PATH $DOCKER_CONTAINER bash -c "/ubuntu_entrypoint.sh ; bash"

# permission
elif [[ $1 == "permission" ]]; then
    echo "Change folder permission to USER"
    sudo chown -R $USER:$USER $PWD/$WS_VOLUME           # set user ownership
    sudo chmod -R a+rwx $PWD/$WS_VOLUME                 # set user permissions
    chmod +x docker/*entrypoint.sh

# install
elif [[ $1 == "install" ]]; then
    echo "Install Docker"
    sudo apt update
    sudo apt install -y ca-certificates curl gnupg

    sudo install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    sudo chmod a+r /etc/apt/keyrings/docker.gpg

    echo \
        "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
        "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
        sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

    sudo apt update
    sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

	echo "Setting Docker permission/ownership"
	sudo chown -R $USER:$USER $DOCKER_HOME/.docker      # set docker ownership
	sudo chmod -R g+rwx "$DOCKER_HOME/.docker"        	# set docker permissions

	sudo apt autoremove -y

    echo "Configure Docker"
	sudo groupadd docker                                # create the docker group
	sudo usermod -aG docker ${USER}                     # add your user to the docker group
	newgrp docker                                       # activate the changes to groups

    sudo apt install -y x11-xserver-utils

    if [ "$ARCH" == "x86_64" ]; then
        sudo apt install -y qemu qemu-user-static binfmt-support  # install QEMU
    fi

# inspect
elif [[ $1 == "inspect" ]]; then
    echo -e "Resume:"
    docker system df
    echo

    echo -e "Images:"
    docker images
    echo

    echo -e "Volumes:"
    docker volume ls
    echo

    echo -e "Containers:"
    docker ps -a
    echo

    echo -e "Network:"
    docker network ls
    echo

# clean
elif [[ $1 == "clean" ]]; then
    echo "Clean all the not needed images and container"
    docker image prune -f
    docker container prune -f
    docker system prune -f

# info
elif [[ $1 == "info" ]]; then
    echo "Show docker environment info
    "
    echo "Project info
    - Project name:             $REPO_NAME
    - Project author:           $REPO_AUTHOR"
    echo "Ubuntu info
    - Ubuntu distro:            ${lsb_release -rs}
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
    - [install]:    install and configure Docker
    - [inspect]:    show information of images, containers, volumes and networks
    - [clean]:      remove not needed images and container
    - [info]:       show docker environment info
    - [help]:       show script commands"

# default
else
    echo "Use `source docker.sh help` to see all the commands"

fi
