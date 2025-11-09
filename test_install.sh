#!/bin/bash
# set -uo pipefail

image=$1
additional_mb=$2

# Install required packages
# sudo apt-get update
# sudo apt-get install -y wget xz-utils

wget -nv -O base_image.img.xz "${image}"
xz -T0 -d base_image.img.xz

ls

if [[ ${additional_mb} -gt 0 ]]; then
    dd if=/dev/zero bs=1M count=${additional_mb} >> ${image}
fi

loopdev=$(losetup --find --show --partscan base_image.img)

echo "Before resize"
lsblk ${loopdev}

if [[ ${additional_mb} -gt 0 ]]; then
    if ( (parted --script $loopdev print || false) | grep "Partition Table: gpt" > /dev/null); then
        sgdisk -e "${loopdev}"
    fi
    parted --script "${loopdev}" resizepart ${rootpartition} 100%
    e2fsck -p -f "${loopdev}p${rootpartition}"
    resize2fs "${loopdev}p${rootpartition}"
    echo "Finished resizing disk image."
fi

sync

echo "After resize"
lsblk ${loopdev}


losetup --detach "${loopdev}"

echo "All done"

echo "image=base_image.img" >> "$GITHUB_OUTPUT"