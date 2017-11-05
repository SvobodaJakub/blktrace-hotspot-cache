#!/bin/bash

# displays how much data each cache file will load from disk

origdir=$( pwd ; )

# read temporary dir
tmpdir="$1"
cd "$tmpdir" || { echo "cannot cd to $tmpdir !" ; exit 1 ; }

# obtain the absolute path
tmpdir=$( pwd ; )


totaltotalbytes=$((0))

report_one_file() {
    echo -n "file $1 : "
    totalbytes=$((0))
    totalrequests=$((0))
    while read ddline
    do
        totalrequests=$(( totalrequests + 1 ))
        totalbytes=$(( totalbytes + ( $( echo "$ddline" | sed -r 's#^dd if=.* of=/dev/null bs=([01-9]+) count=([01-9]+) skip.*$#\1 * \2#g' ; ) ) ))
    done < "$1"

    totaltotalbytes=$(( totaltotalbytes + totalbytes ))
    echo "$(( totalbytes / 1024 / 1024 )) MB"
}

report_one_file "$tmpdir/blktrace-ddexec-old19.txt"
report_one_file "$tmpdir/blktrace-ddexec-old18.txt"
report_one_file "$tmpdir/blktrace-ddexec-old17.txt"
report_one_file "$tmpdir/blktrace-ddexec-old16.txt"
report_one_file "$tmpdir/blktrace-ddexec-old15.txt"
report_one_file "$tmpdir/blktrace-ddexec-old14.txt"
report_one_file "$tmpdir/blktrace-ddexec-old13.txt"
report_one_file "$tmpdir/blktrace-ddexec-old12.txt"
report_one_file "$tmpdir/blktrace-ddexec-old11.txt"
report_one_file "$tmpdir/blktrace-ddexec-old10.txt"
report_one_file "$tmpdir/blktrace-ddexec-old09.txt"
report_one_file "$tmpdir/blktrace-ddexec-old08.txt"
report_one_file "$tmpdir/blktrace-ddexec-old07.txt"
report_one_file "$tmpdir/blktrace-ddexec-old06.txt"
report_one_file "$tmpdir/blktrace-ddexec-old05.txt"
report_one_file "$tmpdir/blktrace-ddexec-old04.txt"
report_one_file "$tmpdir/blktrace-ddexec-old03.txt"
report_one_file "$tmpdir/blktrace-ddexec-old02.txt"
report_one_file "$tmpdir/blktrace-ddexec-old01.txt"
report_one_file "$tmpdir/blktrace-ddexec.txt"

echo "total: $(( totaltotalbytes / 1024 / 1024 )) MB"
