#! Load docker env settings
include docker/docker_env.sh

#! Environment variables
# Docker path
DOCKER_HOME = /home/${UBUNTU_USER}
LOCAL_WS_PATH = ${PWD}/${ROS_WS}
DOCKER_WS_PATH = ${DOCKER_HOME}/${ROS_WS}
PROJECT_FOLDER = ${REPO_AUTHOR}/${REPO_NAME}

# ROS distro check (to be improved)
ifeq (${UBUNTU_RELEASE}, 20.04)
	UBUNTU_CODENAME = focal
	ROS_DISTRO = foxy
else ifeq (${UBUNTU_RELEASE}, 22.04)
	UBUNTU_CODENAME = jellyfish
	ROS_DISTRO = humble
else
	$(error Error: Unsupported Ubuntu release)
endif

# System Architecture check
ifeq ($(HOSTTYPE),x86_64)
    TAG ?= development
else ifeq ($(HOSTTYPE),arm)
    TAG ?= deployment
else
	$(error Error: Unrecognized System Architecture)
endif

# Docker file/image/container
DOCKER_FILE = Dockerfile_${ROS_DISTRO}_${TAG}
DOCKER_IMAGE = registry.gitlab.com/${PROJECT_FOLDER}/ros-${ROS_DISTRO}-image
DOCKER_CONTAINER = ros-${ROS_DISTRO}-${TAG}-container


#! Docker commands variables
# Docker build arguments
DOCKER_BUILD_ARGS = \
	--build-arg UBUNTU_USER=${UBUNTU_USER} \
	--build-arg UBUNTU_PSW=${UBUNTU_PSW} \
	--build-arg UBUNTU_UID=${UBUNTU_UID} \
	--build-arg UBUNTU_GID=${UBUNTU_GID} \
	--build-arg ROS_DISTRO=${ROS_DISTRO}

# Docker run arguments
DOCKER_RUN_ARGS = \
	-h ${USER} \
	-e LOCAL_USER_ID=${UBUNTU_UID} \
	-e USER=${UBUNTU_USER} \
	-e UID=${UBUNTU_UID} \
	-e GROUPS=${UBUNTU_GID} \
	-e DISPLAY=${DISPLAY} \
	-e QT_X11_NO_MITSHM=1 \
	-e XAUTHORITY=/tmp/.docker.xauth \
	-v /etc/localtime:/etc/localtime:ro \
	-v /tmp/.X11-unix:/tmp/.X11-unix \
	-v /tmp/.docker.xauth:/tmp/.docker.xauth \
	-v /dev/dri:/dev/dri \
	-p 14556:14556/udp \
	--device /dev:/dev


# Check for workspace
ifeq (${ROS_WS}, )
	$(warning WARN: ROS workspace not defined)
else
	DOCKER_RUN_ARGS += \
		-v ${LOCAL_WS_PATH}:${DOCKER_WS_PATH}:rw
endif


# Platform docker arguments
ifeq (${NVIDIA_GPU}, true)
	DOCKER_BUILD_ARGS += \
		--platform=linux/arm64
	DOCKER_RUN_ARGS += \
		-e "NVIDIA_DRIVER_CAPABILITIES=all" \
		--gpus all \
		--runtime nvidia
else
	DOCKER_BUILD_ARGS += \
		--platform=linux/amd64
endif


#! Commands
.DEFAULT_GOAL := docker-help

# docker build
.PHONY: docker-build
docker-build:	## build docker container
	$(info Build docker image: \
		- Dockerfile name:  ${DOCKER_FILE} \
		- Dockerimage name: ${DOCKER_IMAGE} \
		- Stage:            ${TAG})

	@docker build --rm \
		${DOCKER_BUILD_ARGS} \
		-f ${PWD}/docker/${DOCKER_FILE} \
		-t ${DOCKER_IMAGE}:${TAG} .


# docker push
.PHONY: docker-push
docker-push:	## push docker container
	$(info Push dockerimage to GitLab container registry)

	@docker login registry.gitlab.com
	@docker push ${DOCKER_IMAGE}:${TAG}


# docker run
.PHONY: docker-run
docker-run:		## run docker container

	@xhost +     # enable access to xhost from the container
	@docker run  -it --rm --privileged \
				${DOCKER_RUN_ARGS} \
				-w ${DOCKER_WS_PATH} \
				--name ${DOCKER_CONTAINER} \
				${DOCKER_IMAGE}:${TAG} /bin/bash


# docker exec
.PHONY: docker-exec
docker-exec:
	$(info Join ${DOCKER_CONTAINER})

	@docker exec -it -w ${DOCKER_WS_PATH} ${DOCKER_CONTAINER} bash -c "/entrypoint.sh ; bash"


# docker network
.PHONY: docker-network
docker-network:
	$(info Create Docker Network)

	@docker network create -d bridge \
	    --subnet 192.168.80.0/24 \
		-o parent=wlp60s0 leo_net; \
		mkdir -p .build && touch $@


# docker permission
.PHONY: docker-permission
docker-permission:
	$(info Change folder permission to USER)

	@sudo chown -R ${USER}:${USER} ${PWD}/${ROS_WS}              # set user ownership
	@sudo chmod -R a+rwx ${PWD}/${ROS_WS}                    # set user permissions


# docker install
.PHONY: docker-install
docker-install:
	$(info Installing Docker)

	@sudo apt update
	@sudo apt install -y ca-certificates curl gnupg

	@sudo install -m 0755 -d /etc/apt/keyrings
	@curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
	@sudo chmod a+r /etc/apt/keyrings/docker.gpg
	@echo "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu "$(. /etc/os-release && echo "${VERSION_CODENAME}")" stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

	@sudo apt update
	@sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

	@echo "Setting Docker permission/ownership"
	@sudo chown -R ${USER}:${USER} ${DOCKER_HOME}/.docker       	# set docker ownership
	@sudo chmod -R g+rwx "${DOCKER_HOME}/.docker"        		# set docker permissions

	@sudo groupadd docker                                	# create the docker group
	@sudo usermod -aG docker ${USER}                       	# add your user to the docker group
	@newgrp docker                                       	# activate the changes to groups

	@sudo apt autoremove


# docker clean
.PHONY: docker-clean
docker-clean:
	$(info Clean all the not needed images and container)

	@docker image prune -f
	@docker container prune -f


# docker info
.PHONY: docker-info
docker-info:
	$(info Show docker environment info)
	@echo ""
	@echo "Project info:"
	@echo "- Project name:             ${REPO_NAME}"
	@echo "- Project author:           ${REPO_AUTHOR}"
	@echo "Ubuntu info:"
	@echo "- Ubuntu distro:            ${UBUNTU_CODENAME} (${UBUNTU_RELEASE} LTS)"
	@echo "- Ubuntu user:              ${UBUNTU_USER} (${UBUNTU_PSW})"
	@echo "- ROS distro:               ${ROS_DISTRO}"
	@echo "Container info"
	@echo "- Dockerfile name:          ${DOCKER_FILE}"
	@echo "- Docker image name:        ${DOCKER_IMAGE}"
	@echo "- Docker image tag:         ${TAG}"
	@echo "- Docker container name:    ${DOCKER_CONTAINER}"


# docker help
.PHONY: docker-help
docker-help:	## display this help message
	@echo "Command list:"
	@echo "- [build]:      build the Dockerfile to create the image (dockerimage)"
	@echo "- [push]:       push dockerimage to GitLab container registry"
	@echo "- [run]:        run the dockerimage into a containter"
	@echo "- [exec]:       join to the existing container"
	@echo "- [permission]: add user permissions to docker envoronment"
	@echo "- [install]:    install Docker and configure it"
	@echo "- [clean]:      remove not needed images and container"
	@echo "- [clean]:      remove not needed images and container"
	@echo "- [info]:       show docker environment info"
	@echo "- [help]:       show script commands"
