# Docker


## Utility files

## [docker.sh](../docker.sh)
It is a wrapper of Docker commands with predefined configurations (see `docker_env.sh`).


## [docker_env.sh](docker_env.sh)
It is a script used to set Docker environment and variables.

### Docker environment configuration

| Variable       | Options                 | Description       |
| -------------- | ----------------------- | ----------------- |
| UBUNTU_RELEASE | 20.04, 22.04            | Ubuntu relese     |
| UBUNTU_USER    |                         | User name         |
| UBUNTU_UID     | 1000                    | User ID           |
| UBUNTU_PSW     |                         | Root password     |
| REPO_AUTHOR    |                         | Repository author |
| REPO_NAME      |                         | Repository name   |
| TAG            | development, deployment | Image tag         |
| BUILD_STAGE    | base-stage, ros-stage   | Stage to use      |



### Commands

```sh
source docker.sh <command>
```

| Command      | Description                                            |
| ------------ | ------------------------------------------------------ |
| `build`      | build the Dockerfile to create the image (dockerimage) |
| `push`       | push dockerimage to GitLab container registry          |
| `run`        | run the dockerimage into a containter                  |
| `exec`       | join to the existing container                         |
| `permission` | add user permissions to docker envoronment             |
| `config`     | configure Docker after installation                    |
| `clean`      | remove not needed images and container                 |
| `info`       | show docker environment info                           |
| `help`       | show script commands                                   |


## Dockerfile

* [Dockerfile_jellyfish_development](Dockerfile_jellyfish_development) -> `ubuntu:jammy`
* [Dockerfile_jellyfish_deployment]() -> `??`



### Credits
ROS2
- [ros:foxy-ros-core](https://github.com/osrf/docker_images/blob/11c613986e35a1f36fd0fa18b49173e0c564cf1d/ros/foxy/ubuntu/focal/ros-core/Dockerfile)
- [ros:foxy-ros-base](https://github.com/osrf/docker_images/blob/df19ab7d5993d3b78a908362cdcd1479a8e78b35/ros/foxy/ubuntu/focal/ros-base/Dockerfile)
- [osrf/ros:foxy-desktop](https://hub.docker.com/layers/osrf/ros/foxy-desktop/images/sha256-16b5de92feb29d59d4bf75f42650f81a7722089f2291cb4fe126d8aa42a93238?context=explore)

PX4
- [PX4 Containers](https://github.com/PX4/PX4-containers/blob/master/README.md#container-hierarchy)
- [PX4 Docker Container](https://docs.px4.io/master/en/test_and_ci/docker.html)



## Links
- [Docker and ROS](https://roboticseabass.com/2021/04/21/docker-and-ros/)
- [Multi-staging building](https://docs.docker.com/develop/develop-images/multistage-build/)

