#!/bin/bash
image=$1
loopdev=$(losetup --find --show --partscan ${image})
echo "Created loopback device ${loopdev}"
echo "*** lsblk ***"
lsblk
echo "*** parted ***"
partprobe -s "${loopdev}"
parted "${loopdev}" print
losetup --detach "${loopdev}"