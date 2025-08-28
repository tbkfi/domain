#!/bin/bash
# https://cloud.google.com/compute/docs/disks/benchmarking-pd-performance-linux

bench_dir=fio
bs=512K
mkdir -p $bench_dir

fio --name=read_throughput --directory=$bench_dir --numjobs=16 \
--size=4G --time_based --runtime=5m --ramp_time=2s --ioengine=libaio \
--direct=1 --verify=0 --bs=$bs --iodepth=64 --rw=read --group_reporting=1 \
--iodepth_batch_submit=64 --iodepth_batch_complete_max=64 \
--iodepth_batch_complete_max=64
