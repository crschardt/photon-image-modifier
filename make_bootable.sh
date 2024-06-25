#!/bin/bash
image = $1
loopdev = $(sudo losetup --find --show --partscan ${image})
echo "Created loopback device ${loopdev}"
echo "*** lsblk ***"
lsblk
echo "*** parted ***"
sudo parted "${loopdev}" print
sudo losetup --detach "${loopdev}"