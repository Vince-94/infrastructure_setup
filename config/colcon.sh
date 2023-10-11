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



# Source ROS2
source /opt/ros/$ROS_DISTRO/setup.bash

# Export Ignition envs
export IGN_CONFIG_PATH=/usr/share/ignition


#! Commands
PKG_SKIP=""
PKG_SELECT=""

if [[ $1 == "build" ]]; then                # build the workspace
    echo "Build ROS2 workspace"

    if [[ $2 == "debug" ]]; then
        colcon build --symlink-install --cmake-args -DCMAKE_BUILD_TYPE=RelWithDebInfo
    else
        colcon build --symlink-install
    fi
    source install/local_setup.sh
    # git submodule update --init --recursive
    # colcon build --symlink-install --packages-skip ${PKG_SKIP}
    # colcon build --symlink-install --packages-select realsense2_camera
elif [[ $1 == "sim" ]]; then                # simulation Gazebo/PX4
    if [[ -d "~/PX4-Autopilot/build/px4_sitl_rtps" ]]; then
        echo "Build PX4"
        cd ~/PX4-Autopilot && make px4_sitl_rtps gazebo
    else
        echo "Simulation PX4"
        source scripts/params.sh & cd ~/PX4-Autopilot && make px4_sitl_rtps gazebo
    fi
elif [[ $1 == "source" ]]; then             # source the workspace
    echo "Source ROS2 workspace"
    source install/local_setup.sh
elif [[ $1 == "clean" ]]; then              # clean the workspace
    echo "Clean /build /install /log directories"
    sudo rm -r build/ install/ log/
else                                        # help
    echo "Commands:
    - [build]:      Build ROS2 workspace
    - [source]:     Source ROS2 workspace
    - [clean]:      Clean ROS2 workspace"
fi


# ROS2 options
export RCUTILS_COLORIZED_OUTPUT=1
# export RCUTILS_CONSOLE_OUTPUT_FORMAT="[{severity} {time}] [{name}]: {message} ({function_name}() at {file_name}:{line_number})"
export RCUTILS_LOGGING_USE_STDOUT=1
export RCUTILS_LOGGING_BUFFERED_STREAM=1
