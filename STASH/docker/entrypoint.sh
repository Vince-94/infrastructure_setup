#!/bin/bash
set -e

# Ubuntu config
echo "User credentials:
- HOSTNAME: $HOSTNAME
- USERNAME: $USER (UID=$UID, GID=$GROUPS)
"

# Source bashrc
# source /usr/share/colcon_argcomplete/hook/colcon-argcomplete.bash
source ~/.bashrc

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

if [[ -n "$CI" ]]; then
    exec /bin/bash
else
    exec "$@"
fi
