#!/bin/bash
#
# Patch NEEO firmware image with additional SSH keys to gain ssh access
#
# FW_KEY  by Dgi
# Patch script by ZED
# Method by Niels de Klerk
# 
#

# root only!
if [[ $(id -u) -ne 0 ]] ; then echo "Must be run as root! We don't want to mess up uid, gid & permissions :-)" ; exit 1 ; fi

# exit on all command errors
set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# input firmware image to hack
#  - official recovery image from: https://neeo-cp6-recovery.s3.amazonaws.com/neeo_firmware_0.50.6-20180424-481315c-0523-151625_emmc.img
# FW_DIR=$(dirname $0)/cp6-fw-0.50.6
# FW_VERSION=0.50.6-20180424-481315c-0523-151625
#  - latest known version https://neeo-firmware.s3.amazonaws.com/neeo_firmware_0.53.8-20180424-05eb8e2-0201-092014_emmc.img
FW_DIR=${DIR}/cp6-fw-0.53.8
FW_VERSION=0.53.8-20180424-05eb8e2-0201-092014
FW_PREFIX=neeo_firmware_
FW_SUFFIX=_emmc
FW_ENDING=.img

FW_FILE=${FW_DIR}/${FW_PREFIX}${FW_VERSION}${FW_SUFFIX}${FW_ENDING}

# secrets
FW_KEY=***********************************
SSH_KEY_FILE=${DIR}/key/authorized_keys

# output
FW_TARGET=${FW_DIR}/firmware
HACKED_FW_FILE=${FW_DIR}/${FW_PREFIX}${FW_VERSION}${FW_SUFFIX}-hacked${FW_ENDING}


if [ ! -d "$FW_DIR" ]; then
  echo "Firmware directory doesn't exist: $FW_DIR"
  exit 1
fi
if [ ! -f "$FW_FILE" ]; then
    echo "Firmware file not found: $FW_FILE"
    exit 1
fi
if [ -d "$FW_TARGET" ]; then
  echo "Extracted firmware directory already exists: $FW_TARGET"
  exit 1
fi
if [ ! -f "$SSH_KEY_FILE" ]; then
    echo "SSH authorized key file not found: $SSH_KEY_FILE"
    exit 1
fi
if [ -f "$HACKED_FW_FILE" ]; then
    echo "Hacked firmware file already exists: $HACKED_FW_FILE"
    exit 1
fi

echo "Decrypting fw image '$FW_FILE' and extracting to '$FW_TARGET'..."
mkdir -p $FW_TARGET
openssl aes-256-cbc -d -salt -in $FW_FILE -k $FW_KEY -md md5 | tar -C $FW_TARGET -x

if [ ! -d "${FW_TARGET}/${FW_PREFIX}${FW_VERSION}" ]; then
  echo "Invalid directory structure inside extracted firmware image! Expected to find directory: ${FW_PREFIX}${FW_VERSION}"
  exit 1
fi

echo "Extracting root file system..."
cd ${FW_TARGET}/${FW_PREFIX}${FW_VERSION}
mkdir rootfs
tar -C rootfs -xf rootfs.tar.gz

echo "Adding our own ssh key(s) from '$SSH_KEY_FILE'..."
cat $SSH_KEY_FILE >> rootfs/home/neeo/.ssh/authorized_keys

# TODO patch whatever you like :-)

echo "Repacking root file system..."
rm rootfs.tar.gz
tar -C rootfs -czf rootfs.tar.gz .
rm -Rf rootfs

echo "Taring firmware image..."
cd ${FW_DIR}
tar -C $FW_TARGET -cf ${FW_PREFIX}${FW_VERSION}_hacked.tar .

echo "Creating encrypted firmware image '$HACKED_FW_FILE' ..."
openssl enc -aes-256-cbc -salt -k $FW_KEY  -in ${FW_PREFIX}${FW_VERSION}_hacked.tar -md md5 -out $HACKED_FW_FILE

echo "Testing decryption of hacked fw image..."
mkdir ${FW_TARGET}-test
openssl aes-256-cbc -d -salt -in $HACKED_FW_FILE -k $FW_KEY -md md5 | tar -C ${FW_TARGET}-test -x

echo "Cleaning up..."
rm -Rf ${FW_TARGET}-test
rm ${FW_PREFIX}${FW_VERSION}_hacked.tar

echo "Done!"
