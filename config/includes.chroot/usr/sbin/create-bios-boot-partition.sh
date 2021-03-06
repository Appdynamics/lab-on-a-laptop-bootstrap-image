#!/bin/bash

USAGE="
Usage: create-bios-boot-partition.sh </dev/block_device>

Creates a bios boot partition for the GRUB bootloader on the specified block
device.

Options:
    -h | --help     Print this help message and exit"

if [ "$1" == '-h' ] || [ "$1" == '--help' ]; then
    >&2 echo "$USAGE"
    exit 1
fi

# include common functions
SCRIPT_DIR=$(dirname ${BASH_SOURCE[0]})
LIB="$SCRIPT_DIR/../lib"
source "$LIB/bootstrap-zfs-root/partition_functions.sh"

if [ -n "$1" ] && is_block_device "$1" && ! is_partition "$1"; then
    PARTNUM=`get_first_available_partition_number "$1"`
    sgdisk -a 1 --new=$PARTNUM:48:2047 --typecode=$PARTNUM:EF02 --change-name=$PARTNUM:"BIOS boot partition" "$1"
    partprobe $1
else
    >&2 echo "Error: Argument must be a block device and not a partition."
    exit 1
fi
