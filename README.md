# Configuring Environment

- [Configuring Environment](#configuring-environment)
  - [Docker](#docker)
    - [Commands](#commands)
    - [Images](#images)
    - [Working with docker in WSL](#working-with-docker-in-wsl)


## Docker

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


### Images
* Ubuntu:
  * ubuntu:20.04
  * ubuntu:22.04
* [ROS2](https://github.com/osrf/docker_images/tree/3f4fbca923d80f834f3a89b5960bad5582652519):
  * foxy:
    * [ros:foxy-ros-core](https://github.com/osrf/docker_images/blob/11c613986e35a1f36fd0fa18b49173e0c564cf1d/ros/foxy/ubuntu/focal/ros-core/Dockerfile)
    * [ros:foxy](https://github.com/osrf/docker_images/blob/df19ab7d5993d3b78a908362cdcd1479a8e78b35/ros/foxy/ubuntu/focal/ros-base/Dockerfile)
    * ros:foxy-perception
    * [osrf/ros:foxy-desktop](https://hub.docker.com/layers/osrf/ros/foxy-desktop/images/sha256-16b5de92feb29d59d4bf75f42650f81a7722089f2291cb4fe126d8aa42a93238?context=explore)
    * osrf/ros:foxy-desktop-full
  * humble:
    * ros:humble-ros-core
    * ros:humble
    * ros:humble-perception
    * osrf/ros:humble-desktop
    * osrf/ros:humble-desktop-full

### Working with docker in WSL
Requisites:
- VS Code Remote Pack

Steps:
WSL -> VS Code GUI -> Docker container -> VS COde server

https://www.youtube.com/playlist?list=PL2dJBq8ig-vihvDVw-D5zAYOArTMIX0FA
https://github.com/polyhobbyist/jetbot
https://www.allisonthackston.com/articles/vscode-docker-ros2.html
