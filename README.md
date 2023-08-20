# Configuring Environment

- [Configuring Environment](#configuring-environment)
  - [Docker](#docker)
    - [Commands](#commands)
    - [Images](#images)


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
    * ros:foxy-ros-core
    * ros:foxy
    * ros:foxy-perception
    * osrf/ros:foxy-desktop
    * osrf/ros:foxy-desktop-full
  * humble:
    * ros:humble-ros-core
    * ros:humble
    * ros:humble-perception
    * osrf/ros:humble-desktop
    * osrf/ros:humble-desktop-full


