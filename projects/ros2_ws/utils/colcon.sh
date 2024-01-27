#!/bin/bash

# ROS2 distro check
ros_distros=("foxy" "humble")
distro_match=false

for distro in "${ros_distros[@]}"; do
    if [[ "$distro" == "$ROS_DISTRO" ]]; then
        echo "ROS_DISTRO: $ROS_DISTRO"
        distro_match=true
        break
    fi
done

if ! $distro_match; then
    if [ -z "$ROS_DISTRO" ]; then
        echo "ERROR: ROS_DISTRO not defined"
    else
        echo "ERROR: ROS_DISTRO $ROS_DISTRO not correct"
    fi
    return
fi


#! Commands
PKG_SKIP="px4_msgs px4_ros_com"
PKG_SELECT=""

# build the workspace
if [[ $1 == "build" ]] || [[ $1 == "b" ]]; then
    echo "Build ROS2 workspace"

    build_args="--symlink-install"

    for arg in "$@"; do
        case "$arg" in
            "debug")
                echo "- debug mode"
                build_args+=" --cmake-args -DCMAKE_BUILD_TYPE=RelWithDebInfo"
                ;;
            "skip")
                echo "- skipping pkgs"
                build_args+=" --packages-skip ${PKG_SKIP}"
                ;;
            "select")
                echo "- selected pkgs"
                build_args+=" --packages-select ${PKG_SELECT}"
                ;;
            *)
        esac

    done

    echo "colcon build $build_args"
    colcon build $build_args
    source install/local_setup.sh

# source the workspace
elif [[ $1 == "source" ]] || [[ $1 == "s" ]]; then
    echo "Source ROS2 workspace"
    source install/local_setup.sh

# clean the workspace
elif [[ $1 == "clean" ]] || [[ $1 == "c" ]]; then
    echo "Clean /build /install /log directories"
    sudo rm -r build/ install/ log/

# help
else
    echo "Commands:
    - [build]:      Build ROS2 workspace
    - [source]:     Source ROS2 workspace
    - [clean]:      Clean ROS2 workspace"
fi
