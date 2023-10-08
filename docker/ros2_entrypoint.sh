#!/bin/bash

set -e

# Source bashrc
source /usr/share/bash-completion/completions/git
source /usr/share/colcon_argcomplete/hook/colcon-argcomplete.bash
source ~/.bashrc

# git configuration
git config --global core.editor "code --wait"

# Source ROS2 distro
if [[ -n "${ROS_DISTRO}" ]]; then
	source /opt/ros/$ROS_DISTRO/setup.bash
	export ROS_DOMAIN_ID=0
fi

# Source ROS2 workspace
if [[ -d "../install" ]]; then
	source ~/ros2_esa_ws/install/setup.sh
fi

# Print information
if [[ $USER == $UBUNTU_USER ]] && [[ $UID == $UBUNTU_UID ]]; then
	echo "User credentials:
	- USERNAME: ($USER:$UID)
	- HOSTNAME: $HOSTNAME
	- PASSWORD: $UBUNTU_PSW
	"
else
	echo "User is not set correctly!"
	if ![[ $USER == $UBUNTU_USER ]]; then
		echo "$USER is not $UBUNTU_USER"
	else
		echo "$UID is not $UBUNTU_UID"
	fi
	return
fi

echo "ROS2 environment:
	- ROS_DISTRO: $ROS_DISTRO
	- ROS_VERSION: $ROS_VERSION
	- ROS_PYTHON_VERSION: $ROS_PYTHON_VERSION
"


if [[ -n "$CI" ]]; then
    exec /bin/bash
else
    exec "$@"
fi