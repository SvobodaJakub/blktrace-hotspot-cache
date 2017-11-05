#!/bin/bash

# unsets kernel page caching parameters that hopefully better fit rotational hdd


echo "250" > /sys/block/sda/queue/iosched/fifo_expire_async
echo "125" > /sys/block/sda/queue/iosched/fifo_expire_sync
echo "40" > /sys/block/sda/queue/iosched/slice_async
echo "1" > /sys/block/sda/queue/iosched/low_latency
echo "8" > /sys/block/sda/queue/iosched/quantum
echo "2" > /sys/block/sda/queue/iosched/slice_async_rq
echo "8" > /sys/block/sda/queue/iosched/slice_idle
echo "100" > /sys/block/sda/queue/iosched/slice_sync
echo "Y" > /sys/module/zswap/parameters/enabled
echo "100" > /proc/sys/vm/vfs_cache_pressure

