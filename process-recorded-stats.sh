#!/bin/bash

# pre-caches disk sectors based on past activity from recorded statistics

# TODO tweak how many are selected - it depends on your preferences, RAM size, working set size (what you usually do on your computer)
# how many requests are cached
NUMCACHE="15000"

origdir=$( pwd ; )

# read temporary dir
tmpdir="$1"
cd "$tmpdir" || { echo "cannot cd to $tmpdir !" ; exit 1 ; }

# obtain the absolute path
tmpdir=$( pwd ; )

cat "$tmpdir/blktrace_"*".txt" | sort | uniq -c | sort -nr >  "$tmpdir/blktrace-stats.txt"

# tell me the number of cached requests in total
echo "$(cat "$tmpdir/blktrace-stats.txt" | wc -l ; ) requests"

# tell me the number of repeated cached requests in total (those that occured only once are not included)
cat "$tmpdir/blktrace-stats.txt" | grep -E -v '^ *1 *dd' > "$tmpdir/blktrace-stats-morethan1.txt"
echo "$(cat "$tmpdir/blktrace-stats-morethan1.txt" | wc -l ; ) repeated requests"

cat "$tmpdir/blktrace-stats.txt" | grep -E '^ *1 *dd' > "$tmpdir/blktrace-stats-only1.txt"

# perform prioritization & reordering of the requests
# reason: there can be many more requests than the allotted capacity ($NUMCACHE) and just sorting it would result in one end of the block device being prefered over the other one
# by shuffling most of the requests, it is at least possible to cache a certain percentage of the hot areas across the whole block device

# get the top requests that would amount to 20% of what fits into the configured limit
cat "$tmpdir/blktrace-stats-morethan1.txt" | head -n $(( NUMCACHE / 5 )) > "$tmpdir/blktrace-stats-prioritized.txt"

# get the other requests that are below the 20%-of-cache-limit mark and shuffle them
cat "$tmpdir/blktrace-stats-morethan1.txt" | tail -n "+"$(( NUMCACHE / 5 )) | shuf >> "$tmpdir/blktrace-stats-prioritized.txt"

# get the rest of the recorded requests and shuffle them as well
cat "$tmpdir/blktrace-stats-only1.txt" | shuf >> "$tmpdir/blktrace-stats-prioritized.txt"

# then only the top $NUMCACHE will be used


# read the temporary file, deduplicate, get the $NUMCACHE most common requests, clean the output, validate that the dd commands are unclipped > save to a temporary file
# sort so that at least some similar requests are near each other
cat "$tmpdir/blktrace-stats.txt" | head -n "$NUMCACHE" | sed -r 's/^[^d]*dd if/dd if/g' | grep -E '^dd if=.* of=.* bs=.* coun.* skip.*' | sort | uniq > "$tmpdir/blktrace-ddexec.txt"


totalbytes=$((0))
totalrequests=$((0))
while read ddline
do
    totalrequests=$(( totalrequests + 1 ))
    totalbytes=$(( totalbytes + ( $( echo "$ddline" | sed -r 's#^dd if=.* of=/dev/null bs=([01-9]+) count=([01-9]+) skip.*$#\1 * \2#g' ; ) ) ))
done < "$tmpdir/blktrace-ddexec.txt"

echo "data queued for caching:"
echo "$totalrequests requests"
echo "$totalbytes B"
echo "$(( totalbytes / 1024 / 1024 )) MB"

