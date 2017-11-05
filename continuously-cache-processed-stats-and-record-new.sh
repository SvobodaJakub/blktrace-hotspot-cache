#!/bin/bash

# pre-caches disk sectors based on past activity from recorded statistics AND records the current activity so that the cache is continuously adjusted
# when pre-caching is taking place, recording of activity is suspended (so that it doesn't record already recorded data and spoil the stats)
# it will eventually push out a random old portion of useful blocks out of the cache and after that, it will record them again if requested

origdir=$( pwd ; )

# read temporary dir
tmpdir="$1"
cd "$tmpdir" || { echo "cannot cd to $tmpdir !" ; exit 1 ; }

# obtain the absolute path
tmpdir=$( pwd ; )

cd "$origdir" # because of the relative "$0"
scriptname=$(basename "$0")
# relative path
scriptdirname=$(dirname "$0")
# obtain the absolute path
cd "$scriptdirname"
scriptdirname=$( pwd ; )

cd "$tmpdir"

date >>"$tmpdir/log_continually-cache-processed-stats-and-record-new.txt" 2>&1 


blktrace_ddexec_into_lines_var() {
    # number of lines
    lines=$( ionice -c 3 nice -n 19 cat "$tmpdir/blktrace-ddexec-old"*".txt" | wc -l ; )

    # a selected fraction of that number
    fraction=$(( lines / 15 ))
}
blktrace_ddexec_into_lines_var # so that the vars are initialized

blktrace_ddexec_prepare_most_frequent() {
    ionice -c 3 nice -n 19 cat "$tmpdir/blktrace-ddexec-old"*".txt" | nice -n 19 sort | nice -n 19 uniq -c | nice -n 19 sort -nr | nice -n 19 head -n 1000 | nice -n 19 sed -r 's/^[^d]*dd if/dd if/g' | nice -n 19 grep -E '^dd if=.* of=.* bs=.* coun.* skip.*' > "$tmpdir/blktrace-ddexec-most-frequent.txt"
}
blktrace_ddexec_prepare_most_frequent # so that the file is initialized

cache_fraction_of_blktrace_ddexec_lines() {
    # caching only the -old* files so that the new recording is ignored, so that the new (undeduplicated) recording doesn't monopolize the caching by its sheer number of lines, so that if the new requested blocks (those recorded in the new recording) are moved out of cache and needed again, they are fetched by the OS again and recorded again

    echo -n "."
    # to log that it works at all, a few requests's dd stderrs are not redirected to /dev/null
    ionice -c 3 nice -n 19 cat "$tmpdir/blktrace-ddexec-old"*".txt" | nice -n 19 head -n 3 | nice -n 19 sort | ionice -c 3 nice -n 19 bash 2>&1 | head -n 10 >>"$tmpdir/log_continually-cache-processed-stats-and-record-new.txt" 2>&1 

    echo -n "."
    # and now properly and with redirection to /dev/null (saves a lot of power)
    ionice -c 3 nice -n 19 cat "$tmpdir/blktrace-ddexec-old"*".txt" | nice -n 19 shuf | nice -n 19 head -n "$fraction" | nice -n 19 sort | ionice -c 3 nice -n 19 bash  >/dev/null 2>&1 

    echo -n "."
    # get the 1000 most frequent requests (remember that each cache file contains only deduplicated lines, so we're filtering for requests that happen again and again across the cache files)
    # this will result in these requests being almost always cached (and almost never recorded again because they are already in cache) for the next several FIFO moves until they fall off the FIFO and (if still relevant), the system will request those blocks from disk again, they will be recorded again, and after several FIFO moves will be again duplicated enough as to be cached by the following command again
    # most probably, various blocks will appear randomly across the individual cache files, so random portions will fall off the FIFO cache and the system will always have some hot blocks cached by the following command and some hot blocks missed by the following command and hopefully, the performance impact will average out (always helping a bit)
    ionice -c 3 nice -n 19 cat "$tmpdir/blktrace-ddexec-most-frequent.txt" | ionice -c 3 nice -n 19 bash 2> /dev/null

    echo " "
}

stop_recording() {
    killall blktrace >>"$tmpdir/log_continually-cache-processed-stats-and-record-new.txt" 2>&1 
    sleep 1
    killall -9 blktrace >>"$tmpdir/log_continually-cache-processed-stats-and-record-new.txt" 2>&1 
    sleep 1
    killall blkparse >>"$tmpdir/log_continually-cache-processed-stats-and-record-new.txt" 2>&1 
}

clear_recording_files() {
    bash "$scriptdirname/record-stats-clear-blktracetxt-files.sh" "$tmpdir" >>"$tmpdir/log_continually-cache-processed-stats-and-record-new.txt" 2>&1 
}

start_recording_files() {
    bash "$scriptdirname/record-stats-root.sh" "$tmpdir" >>"$tmpdir/log_continually-cache-processed-stats-and-record-new.txt" 2>&1 &
    bash "$scriptdirname/record-stats-home.sh" "$tmpdir" >>"$tmpdir/log_continually-cache-processed-stats-and-record-new.txt" 2>&1 &
}

process_recorded_caches_and_move_cache_fifo() {
    ionice -c 3 nice -n 2 bash "$scriptdirname/process-recorded-stats.sh" "$tmpdir" 
    ionice -c 3 nice -n 2 bash "$scriptdirname/move-cache-fifo.sh" "$tmpdir" >>"$tmpdir/log_continually-cache-processed-stats-and-record-new.txt" 2>&1 
}

hour_long_block_of_recording_and_caching() {

    # this can be done only once to save resources because the data won't change until the following loop finishes
    blktrace_ddexec_into_lines_var 
    blktrace_ddexec_prepare_most_frequent

    # 120 mins / 3.5 mins == 34
    for i in {1..34} ; do
        echo "    iteration $i of 34"
        echo "    stopping recording"
        stop_recording

        echo "    starting recording"
        start_recording_files 

        echo "    sleeping for 180 secs"
        sleep 180

        echo "    stopping recording"
        stop_recording

        # might take about 30 seconds
        echo "    caching a fraction of data recorded in past sessions (excluding the current recording session)"
        cache_fraction_of_blktrace_ddexec_lines

    done
}

# function called by trap
trap_quit() {
    echo ""
    echo "SIGINT caught"
    echo "stopping recording"
    stop_recording
    echo "Thank you for flying HDD Magnetic Heads"
    exit 0
}

trap 'trap_quit' SIGINT


loopcount=$((0))

while true ; do
    # start with continuing with the existing recording files and clear them only after the hour so that it is possible to ctrl-c this script at any time when the user doesn't wish a future action to be cached and then resume without rotating the fifo too much; a longer session will just result in a more sparse coverage of the least requested blocks

    date
    echo "a ~ two hour long caching and recording is starting; continuing with the existing recording session"
    hour_long_block_of_recording_and_caching

    date
    echo "caching and recording has stopped; processing of the recording is starting"
    process_recorded_caches_and_move_cache_fifo

    echo "clearing the temporary recording files so that a new recording session can begin"
    clear_recording_files

    echo " "
done


