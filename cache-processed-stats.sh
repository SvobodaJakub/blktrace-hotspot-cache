#!/bin/bash

# pre-caches disk sectors based on past activity from recorded statistics


origdir=$( pwd ; )

# read temporary dir
tmpdir="$1"
cd "$tmpdir" || { echo "cannot cd to $tmpdir !" ; exit 1 ; }

# obtain the absolute path
tmpdir=$( pwd ; )


# execute the files to cache the data
# in order from oldest to newest so that if anything is overwritten, it's the oldest&least-used data


ionice -c 3 nice -n 19 bash "$tmpdir/blktrace-ddexec-old19.txt"
ionice -c 3 nice -n 19 bash "$tmpdir/blktrace-ddexec-old18.txt"
ionice -c 3 nice -n 19 bash "$tmpdir/blktrace-ddexec-old17.txt"
ionice -c 3 nice -n 19 bash "$tmpdir/blktrace-ddexec-old16.txt"
ionice -c 3 nice -n 19 bash "$tmpdir/blktrace-ddexec-old15.txt"
ionice -c 3 nice -n 19 bash "$tmpdir/blktrace-ddexec-old14.txt"
ionice -c 3 nice -n 19 bash "$tmpdir/blktrace-ddexec-old13.txt"
ionice -c 3 nice -n 19 bash "$tmpdir/blktrace-ddexec-old12.txt"
ionice -c 3 nice -n 19 bash "$tmpdir/blktrace-ddexec-old11.txt"
ionice -c 3 nice -n 19 bash "$tmpdir/blktrace-ddexec-old10.txt"
ionice -c 3 nice -n 19 bash "$tmpdir/blktrace-ddexec-old09.txt"
ionice -c 3 nice -n 19 bash "$tmpdir/blktrace-ddexec-old08.txt"
ionice -c 3 nice -n 19 bash "$tmpdir/blktrace-ddexec-old07.txt"
ionice -c 3 nice -n 19 bash "$tmpdir/blktrace-ddexec-old06.txt"
ionice -c 3 nice -n 19 bash "$tmpdir/blktrace-ddexec-old05.txt"
ionice -c 3 nice -n 19 bash "$tmpdir/blktrace-ddexec-old04.txt"
ionice -c 3 nice -n 19 bash "$tmpdir/blktrace-ddexec-old03.txt"
ionice -c 3 nice -n 19 bash "$tmpdir/blktrace-ddexec-old02.txt"
ionice -c 3 nice -n 19 bash "$tmpdir/blktrace-ddexec-old01.txt"
ionice -c 3 nice -n 19 bash "$tmpdir/blktrace-ddexec.txt"

true

