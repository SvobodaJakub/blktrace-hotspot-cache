#!/bin/bash

# pre-caches disk sectors based on past activity from recorded statistics
# it will eventually overwrite any newer cache so it's not good if you need to work on something different than what has been recorded - it will slow your disk accesses because they will be continuously un-cached

origdir=$( pwd ; )

# read temporary dir
tmpdir="$1"
cd "$tmpdir" || { echo "cannot cd to $tmpdir !" ; exit 1 ; }

# obtain the absolute path
tmpdir=$( pwd ; )


while true ; do
    echo -n "*"

    echo -n "."
    # caching only the -old* files so that the new recording is ignored, so that the new (undeduplicated) recording doesn't monopolize the caching by its sheer number of lines, so that if the new requested blocks (those recorded in the new recording) are moved out of cache and needed again, they are fetched by the OS again and recorded again
    lines=$( ionice -c 3 nice -n 19 cat "$tmpdir/blktrace-ddexec-old"*".txt" | wc -l ; )

    fraction=$(( lines / 15 ))

    echo -n "."
    # caching only the -old* files so that the new recording is ignored, so that the new (undeduplicated) recording doesn't monopolize the caching by its sheer number of lines, so that if the new requested blocks (those recorded in the new recording) are moved out of cache and needed again, they are fetched by the OS again and recorded again
    ionice -c 3 nice -n 19 cat "$tmpdir/blktrace-ddexec-old"*".txt" | nice -n 19 shuf | head -n "$fraction" | nice -n 19 sort | ionice -c 3 nice -n 19 bash 2> /dev/null

    echo -n "."
    # get the 1000 most frequent requests (remember that each cache file contains only deduplicated lines, so we're filtering for requests that happen again and again across the cache files)
    # this will result in these requests being almost always cached (and almost never recorded again because they are already in cache) for the next several FIFO moves until they fall off the FIFO and (if still relevant), the system will request those blocks from disk again, they will be recorded again, and after several FIFO moves will be again duplicated enough as to be cached by the following command again
    # most probably, various blocks will appear randomly across the individual cache files, so random portions will fall off the FIFO cache and the system will always have some hot blocks cached by the following command and some hot blocks missed by the following command and hopefully, the performance impact will average out (always helping a bit)
    ionice -c 3 nice -n 19 cat "$tmpdir/blktrace-ddexec-old"*".txt" | nice -n 19 sort | nice -n 19 uniq -c | nice -n 19 sort -nr | nice -n 19 head -n 1000 | nice -n 19 sed -r 's/^[^d]*dd if/dd if/g' | nice -n 19 grep -E '^dd if=.* of=.* bs=.* coun.* skip.*' |  ionice -c 3 nice -n 19 bash 2> /dev/null

    echo -n "_"

    sleep 161
done

