#!/bin/bash

# observes disk activity for statistics

DEVICE="/dev/mapper/luks-109e4949-5d78-4a97-9bf3-526c83034001"

# note - use this to drop caches:
# echo 3 > /proc/sys/vm/drop_caches

origdir=$( pwd ; )

# read temporary dir
tmpdir="$1"
cd "$tmpdir" || { echo "cannot cd to $tmpdir !" ; exit 1 ; }

# obtain the absolute path
tmpdir=$( pwd ; )


# TODO find out how to make -f "%u" working

# read trace of read requests to "$DEVICE" | print block number, num of blocks | select only stats with requests less than 1000000 bytes | rewrite the stats into dd commands to read the same requests again                    > save to a temporary file
blktrace "$DEVICE" -a read -o - | blkparse -f "MYSTATS %12S %12n %12N \n" -q -i  - | uniq | grep -E "^MYSTATS" | grep -E "^.* [0-9]?[0-9]?[0-9]?[0-9]?[0-9]?[0-9] $"  | sed -r 's~MYSTATS +([01-9]+) +([01-9]+) +[01-9]+~dd if='"$DEVICE"' of=/dev/null bs=512 count=\2 skip=\1~' >> "$tmpdir/blktrace_root.txt"
