#!/bin/bash

source /usr/local/bin/notifications.sh
source /usr/local/bin/common.sh

DIR="$(cd "$(dirname "$0")" &&  pwd)"
BACKUP="$DIR/aws-bakup.bak"

SYNCED_FILES=""


if [[ "$1" == "clean" ]] then
        info_print "Cleaning the S3 bucket: s3://$AWS" | tee -a "$LOG"
        aws s3 rm "s3://$AWS/" --recursive | tee -a "$LOG"

        if [ $? -ne 0 ]; then
            info_print "Failed to clean the S3 bucket" 3
            exit 1
        fi

        info_print "Bucket cleaned successfully."
        exit 0
    else
        info_print "Purge aws-bak files."
        rm -f $BACKUP $LOG $DIR/aws-bak.sh
        exit 0
    fi
fi

if [ -n "$1" ]; then
    AWS="$1"
fi

if [ ! -e "$BACKUP" ]; then
    touch "$BACKUP"
    info_print "$BACKUP created. Please only include dirnames." 5
    exit 1
fi

while IFS= read -r SOURCE_PATH || [ -n "$SOURCE_PATH" ]; do
    if [ -z "$SOURCE_PATH" ] || [[ "$SOURCE_PATH" =~ ^[[:space:]]*$ ]]; then
        continue
    fi

    if [ -d "$SOURCE_PATH" ] || [ -f "$SOURCE_PATH" ]; then
        aws s3 sync "$SOURCE_PATH" "s3://$AWS/$(basename "$SOURCE_PATH")" --delete > /dev/null 2>&1

        if [ $? -ne 0 ]; then
            info_print "Error while syncing $SOURCE_PATH to the AWS server." 3
            exit 1
        fi

        SYNCED_FILES="$SYNCED_FILES\n$SOURCE_PATH"
    else
        info_print "$SOURCE_PATH not found or inaccessible." 3
    fi
done < "$BACKUP"

if [ -n "$SYNCED_FILES" ]; then
    info_print "Files synced:$SYNCED_FILES"
else
    info_print "No files synced."  3
    exit 0;
fi

info_print "All files synced to AWS."