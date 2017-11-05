#!/bin/bash

# periodically flushes cache so that repeated reads are recorded repeatedly
# this is useful when you want to record the very first session to catch the most frequently used blocks


while true ; do
    echo 3 > /proc/sys/vm/drop_caches
    sleep 10
done

