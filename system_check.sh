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


##########
# Ckecks #
##########

ubuntu_distro=$(lsb_release -rs)


# Internet connection
echo "Checking internet connection"
    printf "  - %-40s" "google.com:"
    print_result $(ping -q -c1 google.com &> /dev/null)
    echo ""


echo "Checking dependencies"
    check_deb software-properties-common
    check_deb apt-transport-https
    check_deb curl
    check_deb wget
    check_deb zip
    check_deb git
    check_deb ansible
    check_deb docker-ce
    check_deb xterm
    check_deb tmux
    check_deb build-essential
    check_deb cmake
    check_deb python3-dev
    check_deb python3-pip
    check_deb python3-venv
    check_deb python3-future
    check_deb python3-yaml
    check_deb python3-numpy
    check_deb python3-pandas
    check_deb python3-jinja2

