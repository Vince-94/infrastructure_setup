#!/bin/bash

#############
# Functions #
#############

# Custom print function
function print_result() {
    if [ $? -eq 0 ]; then   # check command result
        echo -e "\e[00;32m[OK]\e[00m"
    else
        echo -e "\e[00;31m[FAIL]\e[00m"
    fi
}

# Check packages function
function check_deb() {
    printf "  - %-40s" "$1:"
    print_result $(dpkg-query -s $1 &> /dev/null)
}

# List of regex packages
function check_deb_regex() {
    local pattern="$1"  # Input regex pattern
    pattern="${pattern//'*'/'.*'}"
    local packages=$(dpkg-query -W -f='${Package}\n' | grep -E "$pattern")

    if [[ -z "$packages" ]]; then
        check_deb $1
    else
        for item in $packages; do
            check_deb $item
        done
    fi

    # echo "$packages"

}



##########
# Ckecks #
##########

echo "Regex"

    check_deb_regex python3-dev
    check_deb_regex ros-*
    check_deb_regex ros-*-rviz
    check_deb_regex ros-*-perception
    check_deb_regex ros-*-gazebo-ros-pkgs
    check_deb_regex gazebo


