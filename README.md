# blktrace-hotspot-cache

tool to pre-cache most frequently used sectors on a slow block device

## introduction

* these scripts are intended to be used on a linux system with a conventional rotating hard disk (HDD) to cache some of the frequent requested sectors into memory before they are needed
* requests to block device are recorded
* recorded requests can later be used to pre-cache the data
* traditionally, if a disk read operation is performed for the second time, it is read from cache and is fast; but if the machine has been rebooted or a large file operation flushed the cache, the same read operation will be read from disk and will be as slow as if performed for the first time
* a large portion of daily work just reads the same set of sectors repeatedly every day
* the idea is to find out which sectors are read frequently and cache them proactively so that disk operations are faster 
* it is more convenient to start your computer, let this script run for 10 minutes (pre-caching a sizable chunk of disk sectors you are about to use) and do something else in the meantime and then return to a fast computer and do your work than to start your computer aanndd eevveerryy aaccttiioonn iiss ssoo ssllooww uunnttiill eevveerryytthhiinngg ffiinnaallyy ccaaccheess iinnttoo rraamm and that is usually the time you are about done with the work and the cache is mostly useless for today
* it's an unpolished turd - I developed the tool in a hurry being fed up with my sloooow HDD that I will use for about another year before finally buying an SSD; it does what I want and that's it; so the future for this tool is not very bright and I chose not to polish it; however, pull requests are welcome because maybe it will be immensely useful for someone else :)


## technical considerations

* the tool caches only blocks of reads smaller than 100000 bytes because rotational HDDs are slowest with the smallest reads and fastest with the most linear reads
* future work - get `blktrace`'s `-f "%u"` working and develop logic that caches only the slowest requests
* nice reads about how little caching is enough if you cache the right things (I am in no way affiliated with Seagate, it's just that there are resources particularly about their products and the resources are very relevant to this tool)
** http://www.silicon.co.uk/workspace/seagate-hybrid-drives-dont-need-more-than-8gb-of-nand-124069
** http://www.tomshardware.com/us/sponsored/Seagate-winning-boot-drive-battles-214-3
** https://www.seagate.com/www-content/product-content/momentus-fam/momentus-xt/_shared/docs/fast-storage-3-sea20802us.pdf (PDF)
* relevant software
** https://hoytech.com/vmtouch/
** https://bcache.evilpiepirate.org/


## setup

* install `blktrace` and `blkparse` tools (fedora: `dnf install blktrace`)
* run `lsblk -a` and see the innermost block device your filesystem is on
* to find the full path to the device, run `find /dev -name '*part-of-the-block-device-name*'`
* adjust the block devices in `record-stats-home.sh` and `record-stats-root.sh` based on what you found with `lsblk -a`

## first recording run

* create a persistent folder where you will store the cache files (these are files that record which blocks were requested and can be executed to request them again)
* quit all your most-used programs
* run `periodically-flush-cache.sh`
* run `record-stats-root.sh /path/to/the/cache/folder`
* run `record-stats-home.sh /path/to/the/cache/folder`
* [now run your most-used programs, try to suspend&resume]
* ctrl-c `record-stats-root.sh` and `record-stats-home.sh`
* ctrl-c `periodically-flush-cache.sh`
* run `process-recorded-stats.sh /path/to/the/cache/folder`
* run `move-cache-fifo.sh /path/to/the/cache/folder`
* run `record-stats-clear-blktracetxt-files.sh /path/to/the/cache/folder`
* run `cache-processed-stats.sh /path/to/the/cache/folder` to load the whole cache (because it has been flushed and the computer will be slow for a while otherwise)

## second recording run and set-and-forget use

* run `continuously-cache-processed-stats-and-record-new.sh /path/to/the/cache/folder`
* if you want something to not be recorded, just hit ctrl-c; you can resume later without losing your recording session

## loading the full cache after reboot

* prerequisite - "first recording run" has already been performed
* run `cache-processed-stats.sh /path/to/the/cache/folder` to load the whole cache
* run `continuously-cache-processed-stats-and-record-new.sh /path/to/the/cache/folder` to continue updating and warming the cache
* for convenience, you can make a short script that runs `cd "/path/to/the/blktrace-hotspot-cache/tool" && bash tune-kernel-caching-hdd.sh && bash cache-processed-stats.sh "/path/to/the/cache/folder" && bash continuously-cache-processed-stats-and-record-new.sh "/path/to/the/cache/folder"` and just run that as root at each startup (it is advisable, though, to run this manually in a terminal window so that you can ctrl-c it any time and resume later) (or you can run this from bash history directly)

## more info

* read the source code of everything

## security considerations

* if someone edits the cache files, they can execute anything as root on your computer!
* everything has to be run as root

## performance considerations

* pre-caching all the blocks using individual `dd` calls is horribly inefficient (even if sorted so as to be partly linear); but it is so simple and convenient to implement
* it is not recorded in any way how slow an individual request is - there's a huge room for improvement in that regard by evaluating this and prioritizng the slowest blocks to be cached most rapidly



