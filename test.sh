#!/bin/bash
set -uo pipefail

image=$1
# additional_mb=$2

# Install required packages
# sudo apt-get update
# sudo apt-get install -y wget xz-utils

wget -nv -O base_image.img.xz "${image}"
xz -T0 -d base_image.img.xz

ls

# if [ ${additional_mb} -gt 0]; then
#     dd if=/dev/zero bs=1M count=${additional_mb} >> ${image}
# fi

loopdev=$(losetup --find --show --partscan ${image})
lsblk ${loopdev}

losetup --detach "${loopdev}"

printf '%s\n' "FINAL_IMAGE=${image}" >> "$GITHUB_ENV"
