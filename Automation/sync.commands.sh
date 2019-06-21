#!/usr/bin/env bash

#use sshpass and rsync to update data store backup
#requires you to put your VM server's ssh keys on the backup server or to use sshpass. Otherwise could simply use a cp command to move to an external/networked drive
date

echo SYNCING STUDY NAME

/usr/bin/rsync -raz -v /Users/USERNAME/PATH/Archiver user@URL:/PATH/ODKbackup
/usr/bin/rsync -raz -v /Users/USERNAME/PATH/Analyser user@URL:/PATH/ODKbackup