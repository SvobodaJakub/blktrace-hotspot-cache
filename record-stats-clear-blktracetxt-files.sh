#!/bin/bash

# empties the files used by record-stats-home.sh and record-stats-root.sh so that it is possible to start recording a new session

# note - use this to drop caches:
# echo 3 > /proc/sys/vm/drop_caches

origdir=$( pwd ; )

# read temporary dir
tmpdir="$1"
cd "$tmpdir" || { echo "cannot cd to $tmpdir !" ; exit 1 ; }

# obtain the absolute path
tmpdir=$( pwd ; )

echo "" > "$tmpdir/blktrace_home.txt"
echo "" > "$tmpdir/blktrace_root.txt"
