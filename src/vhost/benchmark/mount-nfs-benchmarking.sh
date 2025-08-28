#!/bin/bash
# Mount NFS benchmarking resources directory.
SRV_ADDR="vnas.lan.tbk.fi"
LOCAL_PATH="/mnt/benchmark"
REMOTE_PATH=""

if [[ -z "$REMOTE_PATH" ]]; then
	echo "please set REMOTE_PATH !"
	exit 1
fi

mkdir -p "$LOCAL_PATH"
if [[ -b "$LOCAL_PATH" ]]; then
	umount "$LOCAL_PATH"
	if (( $? )); then
		echo "couldn't unmount LOCAL_PATH !"
		exit 1
	fi
fi

mount -t nfs \
	-o hard,tcp,rsize=1048576,wsize=1048576 \
	"$SRV_ADDR":"$REMOTE_PATH" "$LOCAL_PATH"
