#!/bin/bash


# Parse arguments:
SOURCE=$1
TARGET=$2
SNAP=$3
COUNT=$4
QUIET=$5

# Function to display usage:
usage() {
    scriptname=$(/usr/bin/basename "$0")
cat <<EOF
$scriptname: Take and rotate snapshots on a btrfs file system

  Usage:
  $scriptname source target snap_name count [-q]
 
  source:    path to make snaphost of
  target:    snapshot directory
  snap_name: Base name for snapshots, to be appended to 
             "date +%Y.%m.%d-%H.%M.%S"
  count:     Number of snapshots in the timestamp-@snap_name format to
             keep at one time for a given snap_name. 
  [-q]:      Be quiet.

Example for crontab:
15,30,45  * * * *   root    /usr/local/bin/btrfs-snapshot / /.btrfs quarterly 4 -q
0         * * * *   root    /usr/local/bin/btrfs-snapshot / /.btrfs hourly 8 -q

Example for anacrontab:
1             10      daily_snap      /usr/local/bin/btrfs-snapshot / /.btrfs daily 8
7             30      weekly_snap     /usr/local/bin/btrfs-snapshot / /.btrfs weekly 5
@monthly      90      monthly_snap    /usr/local/bin/btrfs-snapshot / /.btrfs monthly 3


EOF
    exit
}

# Basic argument checks:
if [ -z "$COUNT" ] ; then
	echo "COUNT is not provided."
	usage
fi

if [ ! -z "$6" ] ; then
	echo "Too many options."
	usage
fi

if [ -n "$QUIET" ] && [ "x$QUIET" != "x-q"	] ; then
	echo "Option 4 is either -q or empty. Given: \"$QUIET\""
	usage
fi


# $max_snap is the highest number of snapshots that will be kept for $SNAP.
max_snap=$COUNT

# Create new snapshot:
cmd="btrfs subvolume snapshot -r $SOURCE $TARGET/$(date +%Y.%m.%d-%H.%M.%S)-@${SNAP}"
if [ -z "$QUIET" ]; then
	echo "$cmd"
	$cmd
else
	$cmd >/dev/null
fi

# Clean up older snapshots:
for i in $(find "$TARGET" -maxdepth 1|sort |grep @"${SNAP}"\$|head -n -${max_snap}); do
	cmd="btrfs subvolume delete $i"
	if [ -z "$QUIET" ]; then
		echo "$cmd"
		$cmd
	else
		$cmd >/dev/null
	fi
done
