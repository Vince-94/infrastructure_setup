# Configuring Environment

- [Configuring Environment](#configuring-environment)
  - [Docker](#docker)
    - [Commands](#commands)
    - [Dockerfile](#dockerfile)
  - [Roadmap](#roadmap)


## Docker

### Commands

```sh
source docker.sh <command>
```

| Command      | Description                                                  |
| ------------ | ------------------------------------------------------------ |
| `build`      | build the Dockerfile to create the image (dockerimage)       |
| `push`       | push dockerimage to GitLab container registry                |
| `run`        | run the dockerimage into a containter                        |
| `exec`       | join to the existing container                               |
| `permission` | add user permissions to docker envoronment                   |
| `install`    | install and configure Docker                                 |
| `inspect`    | show information of images, containers, volumes and networks |
| `clean`      | remove not needed images and container                       |
| `info`       | show docker environment info                                 |
| `help`       | show script commands                                         |


### Dockerfile
* Dockerfile
  * ubuntu:22.04
* Dockerfile_ros
  * ros:humble-ros-core -> NOT TESTED
  * ros:humble -> NOT TESTED
  * ros:humble-perception -> NOT TESTED
  * osrf/ros:humble-desktop -> NOT TESTED
  * osrf/ros:humble-desktop-full -> development image
* Dockerfile_ros_deployment


Links:
* [ROS2 DockerHub](https://github.com/osrf/docker_images/tree/3f4fbca923d80f834f3a89b5960bad5582652519)




## Roadmap
- [ ] Improve dockerfile in order to build libs and delete source
- [ ] Create dockerfile for deployment (arm)
- Dockerfile renaming:
  - [ ] Dockerfile_ros -> Dockerfile_development
  - [ ] config.env -> development_conf.env + user_conf.env + project_conf.env
- [x] Improve architecture
  - [x] load at runtime the project workspace
  - [x] load at runtime the external libraries
  ```sh
    # local architecture
    HOME/
    ├── infrastructure_setup/
    │   ├── .devcontainer/
    │   ├── docker/
    │   │   ├── Dockefile
    │   │   ├── ros2_entrypoint.sh
    │   │   └── config.env
    │   ├── config/
    │   │   └── .vscode/
    │   │       └── colcon.sh
    │   ├── docker.sh
    │   └── README.md
    ├── workspace/
    │   └── src/
    │       └── pkg/
    └── libs/
        └── src/
  ```

  ```sh
  # container architecture
    HOME/
    ├── workspace/
    │   ├── .vscode/
    │   ├── src/
    │   │   └── pkg/
    │   └── colcon.sh
    └── libs/
        └── src/
  ```
- [ ] Implement .devcontainer (WSL -> VS Code GUI -> Docker container -> VS Code server)
  - https://www.youtube.com/playlist?list=PL2dJBq8ig-vihvDVw-D5zAYOArTMIX0FA
  - https://github.com/polyhobbyist/jetbot
  - https://www.allisonthackston.com/articles/vscode-docker-ros2.html
- [ ] Implement Docker-compose
- [x] Implement a metapackage strategy that clone all requirements
- [x] Install git in the container and enable auto-completation
  - sudo apt install -y bash-completion
  - source /usr/share/bash-completion/completions/git
