#!/bin/bash

# sets kernel page caching parameters that hopefully better fit rotational hdd


# https://unix.stackexchange.com/questions/30286/can-i-configure-my-linux-system-for-more-aggressive-file-system-caching

echo "old params:"

# echo "250" > /sys/block/sda/queue/iosched/fifo_expire_async
# echo "125" > /sys/block/sda/queue/iosched/fifo_expire_sync
# echo "40" > /sys/block/sda/queue/iosched/slice_async
# echo "1" > /sys/block/sda/queue/iosched/low_latency
# echo "8" > /sys/block/sda/queue/iosched/quantum
# echo "2" > /sys/block/sda/queue/iosched/slice_async_rq
# echo "8" > /sys/block/sda/queue/iosched/slice_idle
# echo "100" > /sys/block/sda/queue/iosched/slice_sync
# echo "Y" > /sys/module/zswap/parameters/enabled
# echo "100" > /proc/sys/vm/vfs_cache_pressure

echo "echo \"$( cat /sys/block/sda/queue/iosched/fifo_expire_async ; )\" > /sys/block/sda/queue/iosched/fifo_expire_async"
echo "echo \"$( cat /sys/block/sda/queue/iosched/fifo_expire_sync ; )\" > /sys/block/sda/queue/iosched/fifo_expire_sync"
echo "echo \"$( cat /sys/block/sda/queue/iosched/slice_async ; )\" > /sys/block/sda/queue/iosched/slice_async"
echo "echo \"$( cat /sys/block/sda/queue/iosched/low_latency ; )\" > /sys/block/sda/queue/iosched/low_latency"
echo "echo \"$( cat /sys/block/sda/queue/iosched/quantum ; )\" > /sys/block/sda/queue/iosched/quantum"
echo "echo \"$( cat /sys/block/sda/queue/iosched/slice_async_rq ; )\" > /sys/block/sda/queue/iosched/slice_async_rq"
echo "echo \"$( cat /sys/block/sda/queue/iosched/slice_idle ; )\" > /sys/block/sda/queue/iosched/slice_idle"
echo "echo \"$( cat /sys/block/sda/queue/iosched/slice_sync ; )\" > /sys/block/sda/queue/iosched/slice_sync"

# not setting this, the default 60 is usually fine for my workload
# echo 15 > /proc/sys/vm/swappiness

# enable zswap https://lwn.net/Articles/528817/
echo "echo \"$( cat /sys/module/zswap/parameters/enabled ; )\" > /sys/module/zswap/parameters/enabled"

# tell kernel to prefer keeping directory hierarchy in memory over file contents in case some RAM needs to be freed (again, if everything fits in RAM, this setting does nothing)
echo "echo \"$( cat /proc/sys/vm/vfs_cache_pressure ; )\" > /proc/sys/vm/vfs_cache_pressure"


echo "setting new values"

# "The worst case latency for a read is (quantum * slice_sync) + (slice_async_rq * slice_async) ms if I've understood the kernel behavior correctly. "
echo 10000 > /sys/block/sda/queue/iosched/fifo_expire_async
echo 250 > /sys/block/sda/queue/iosched/fifo_expire_sync
echo 80 > /sys/block/sda/queue/iosched/slice_async
echo 1 > /sys/block/sda/queue/iosched/low_latency
echo 6 > /sys/block/sda/queue/iosched/quantum
echo 5 > /sys/block/sda/queue/iosched/slice_async_rq
echo 3 > /sys/block/sda/queue/iosched/slice_idle
echo 100 > /sys/block/sda/queue/iosched/slice_sync

# not setting this, the default 60 is usually fine for my workload
# echo 15 > /proc/sys/vm/swappiness

# enable zswap https://lwn.net/Articles/528817/
echo 1 > /sys/module/zswap/parameters/enabled

# tell kernel to prefer keeping directory hierarchy in memory over file contents in case some RAM needs to be freed (again, if everything fits in RAM, this setting does nothing)
echo 10 > /proc/sys/vm/vfs_cache_pressure


