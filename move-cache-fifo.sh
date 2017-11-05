#!/bin/bash

# removes the oldest cache file and renames the newest to make room for a new cache recording

origdir=$( pwd ; )

# read temporary dir
tmpdir="$1"
cd "$tmpdir" || { echo "cannot cd to $tmpdir !" ; exit 1 ; }

# obtain the absolute path
tmpdir=$( pwd ; )

rm -f "$tmpdir/blktrace-ddexec-old19.txt"
mv "$tmpdir/blktrace-ddexec-old18.txt" "$tmpdir/blktrace-ddexec-old19.txt"
mv "$tmpdir/blktrace-ddexec-old17.txt" "$tmpdir/blktrace-ddexec-old18.txt"
mv "$tmpdir/blktrace-ddexec-old16.txt" "$tmpdir/blktrace-ddexec-old17.txt"
mv "$tmpdir/blktrace-ddexec-old15.txt" "$tmpdir/blktrace-ddexec-old16.txt"
mv "$tmpdir/blktrace-ddexec-old14.txt" "$tmpdir/blktrace-ddexec-old15.txt"
mv "$tmpdir/blktrace-ddexec-old13.txt" "$tmpdir/blktrace-ddexec-old14.txt"
mv "$tmpdir/blktrace-ddexec-old12.txt" "$tmpdir/blktrace-ddexec-old13.txt"
mv "$tmpdir/blktrace-ddexec-old11.txt" "$tmpdir/blktrace-ddexec-old12.txt"
mv "$tmpdir/blktrace-ddexec-old10.txt" "$tmpdir/blktrace-ddexec-old11.txt"
mv "$tmpdir/blktrace-ddexec-old09.txt" "$tmpdir/blktrace-ddexec-old10.txt"
mv "$tmpdir/blktrace-ddexec-old08.txt" "$tmpdir/blktrace-ddexec-old09.txt"
mv "$tmpdir/blktrace-ddexec-old07.txt" "$tmpdir/blktrace-ddexec-old08.txt"
mv "$tmpdir/blktrace-ddexec-old06.txt" "$tmpdir/blktrace-ddexec-old07.txt"
mv "$tmpdir/blktrace-ddexec-old05.txt" "$tmpdir/blktrace-ddexec-old06.txt"
mv "$tmpdir/blktrace-ddexec-old04.txt" "$tmpdir/blktrace-ddexec-old05.txt"
mv "$tmpdir/blktrace-ddexec-old03.txt" "$tmpdir/blktrace-ddexec-old04.txt"
mv "$tmpdir/blktrace-ddexec-old02.txt" "$tmpdir/blktrace-ddexec-old03.txt"
mv "$tmpdir/blktrace-ddexec-old01.txt" "$tmpdir/blktrace-ddexec-old02.txt"
mv "$tmpdir/blktrace-ddexec.txt"       "$tmpdir/blktrace-ddexec-old01.txt"


