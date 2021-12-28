smbtool
=======

Small script for your personal home samba server. Using whiptail or dialog and acl for manage users / shares / groups.
Its modified to Work on Proxmox Host with Debian 11 and Btrfs Snapshots. Bevore You use this script you shuld create and mount a new Btrfs Subvolume. The mount Point you shuld specify in Line 41 in smbtool.sh

Create Mountpoints for samba share with share name "Test"

mkdir /mnt/samba
mkdir /mnt/samba/test  #first Share for files
mkdir /mnt/samba/test.snapshots  #first Share Snapshot subvolume

BTRFS subvolume for files:
btrfs subvolume create /mnt/ssdstorage/sambatest

BTRFS subvolume for snapshots:
btrfs subvolume create /mnt/ssdstorage/sambatest.snapshots

Now mount Subvolumes with UUID from raid1 (get id with /sbin/blkid) 
nano /etc/fstab 

UUID=XXXXXXXXXXXXXXXXXXXXXXXXXXX /mnt/samba/test btrfs subvol=sambatest 0 0
UUID=XXXXXXXXXXXXXXXXXXXXXXXXXXX /mnt/samba/test.snapshots btrfs subvol=sambatest.snapshots 0 0

mount -a

install samba
=================

apt install samba samba-common-bin whois acl -y

use smbtool.sh to create a user, then a group add user to group and share with the name of your samba folder

create automatic snapshots with btrfs-snapshot.sh and cronjob
==============================================================

timer		path/to/script 				path/to/share		path/to/snapshots/	sharename 	number of snapshots 
1 0 * * * /smbtool/btrfs-snapshot.sh /mnt/samba/test /mnt/samba/test.snapshots/ test 		14 -q

old part of the docs:

All documentation : https://smbtool.readthedocs.org

* Installation : https://smbtool.readthedocs.org/en/latest/install.html
* Configuration : https://smbtool.readthedocs.org/en/latest/config.html
* Screenshot : https://smbtool.readthedocs.org/en/latest/screenshots.html

