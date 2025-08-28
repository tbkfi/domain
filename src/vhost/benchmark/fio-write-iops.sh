#!/bin/bash
# https://cloud.google.com/compute/docs/disks/benchmarking-pd-performance-linux

bench_dir=fio
bs=4K
mkdir -p $bench_dir

fio --name=write_iops --directory=$bench_dir --size=4G \
--time_based --runtime=5m --ramp_time=2s --ioengine=libaio --direct=1 \
--verify=0 --bs=$bs --iodepth=256 --rw=randwrite --group_reporting=1  \
--iodepth_batch_submit=256  --iodepth_batch_complete_max=256
