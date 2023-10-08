#! /usr/bin/env bash

dir=$HOME

# Find
echo "Folders space:"
du -s --one-file-system $dir/* $dir/.[A-Za-z0-9]* | sort -rn | head

echo "Removing files holder than 7 days"
find $dir/.cache/ $dir/.ccache/ $dir/.local/ -type f -atime +7 -delete


# Remove old apt cache
sudo du -sh /var/cache/apt
sudo apt-get clean
sudo apt autoremove -y
sudo apt autopurge --purge -y
sudo apt autoclean -y



#! Old kernel
# sudo rm -rv ${TMPDIR:-/var/tmp}/mkinitramfs-*

IN_USE=$(uname -r)
echo "Your in use kernel is $USE"

OLD_KERNELS=$(
  dpkg --list |
    grep -v "$IN_USE" |
    grep -v linux-headers-generic-hwe-20.04 |
    grep -v linux-image-generic-hwe-20.04 |
    grep -Ei 'linux-image|linux-headers|linux-modules' |
    awk '{ print $2 }'
)
echo "Old Kernels to be removed:"
echo "$OLD_KERNELS"

for PACKAGE in $OLD_KERNELS; do
  sudo dpkg --purge $PACKAGE
done
