#!/bin/sh

print_usage () {
    echo "Determines if a zpool has disks that are currently in standby or if it's fully active."
    echo "If all disks in the pool are active/idle then return 0"
    echo ""
    echo "Usage: $0 [poolname]"
    echo ""
    echo "If no pool name is given then the disks of ALL pools are checked."
    echo "Works only for pools that are created with /disk/by-id/ devices that start with 'scsi-' or 'ata-'"
    echo ""
    echo "returns 1 if at least 1 disk is in standby, else returns the command line's result"
    exit 0
}


# main
if [ "$1" = "--help" ]; then print_usage; fi

ZPOOL=$(env zpool status $1)
DISKS=$(env echo "$ZPOOL" | grep -E -i -o '.*(ata|scsi)-.*')

IFS=' '
ALL_ACTIVE=1
echo "$DISKS" | while read -r whitespace disk state rd wr chk; do
#    echo "disk: [$disk]"
    SPINSTATE=$(env hdparm -C /dev/disk/by-id/$disk | grep -i -o standby)
#    echo "spin: [$SPIN]"
    if [ "$SPINSTATE" = "standby" ]
    then
        # found a disk in standby - don't perform the commandline
        echo "found a disk in standby: do nothing" >&2
        ALL_ACTIVE=0
        exit 1;
    fi
done
# somehow the exit command exits to here in stead of back to shell
# something to do with a bash bug with piped loops, so check for exit flag again
if [ "$?" -eq "1" ]; then exit 1; fi;
exit 0;
