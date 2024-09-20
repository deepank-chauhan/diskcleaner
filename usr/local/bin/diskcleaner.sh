#!/bin/bash

LOGFILE="/var/log/diskcleaner.log"

echo "$(date): Cleanup started" >> $LOGFILE

# Check if /mnt/data/backups directory exists before proceeding
if [ -d "/mnt/data/backups" ]; then
    # Delete setup backup files in /mnt/data/backups
    echo "$(date): Deleting old backup files in /mnt/data/backups" >> $LOGFILE
    cd /mnt/data/backups || { echo "Failed to change directory to /mnt/data/backups" >> $LOGFILE; exit 1; }
    date >> $LOGFILE
    ls -lt | grep '^d' | tail -n +3 | awk '{print $9}' | xargs -I {} sudo rm -r -- {} >> $LOGFILE 2>&1
    ls -ltrh >> $LOGFILE
else
    echo "$(date): /mnt/data/backups directory does not exist, skipping backup cleanup" >> $LOGFILE
fi

# Check if /mnt/data/butler_data_dir/mnesia_backups directory exists before proceeding
if [ -d "/mnt/data/butler_data_dir/mnesia_backups" ]; then
    # Delete old .bup files, keeping only the 2 most recent ones
    echo "$(date): Deleting old .bup files in /mnt/data/butler_data_dir/mnesia_backups" >> $LOGFILE
    cd /mnt/data/butler_data_dir/mnesia_backups || { echo "Failed to change directory to /mnt/data/butler_data_dir/mnesia_backups" >> $LOGFILE; exit 1; }
    ls -lt *.bup | tail -n +3 | awk '{print $9}' | xargs -I {} sudo rm -f -- {} >> $LOGFILE 2>&1
    ls -ltrh *.bup >> $LOGFILE
else
    echo "$(date): /mnt/data/butler_data_dir/mnesia_backups directory does not exist, skipping mnesia backup cleanup" >> $LOGFILE
fi

# Delete butler_server debug logs, leaving only debug.log and debug.log.[0-5]
echo "$(date): Deleting old butler_server debug logs" >> $LOGFILE
find /var/log/butler_server/log -type f -regextype posix-extended -regex ".*/debug\.log\.[6-9]|.*/debug\.log\.[1-9][0-9]+" -delete >> $LOGFILE 2>&1
ls -ltrh /var/log/butler_server/log >> $LOGFILE

# Report disk usage
echo "$(date): Disk usage report" >> $LOGFILE
df -h >> $LOGFILE

echo "$(date): Cleanup completed" >> $LOGFILE
