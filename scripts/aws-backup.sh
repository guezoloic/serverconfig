#!/bin/bash

source /usr/local/bin/libs/common.sh
source /etc/serverconfig/.env

DIR="$(cd "$(dirname "$0")" &&  pwd)"
BACKUP="$ETC_DIR/aws-backup.bak"

INSTALLED=$1
if [[ "--install" == $INSTALLED ]]; then
    info_print "\n\
==================================================\n\
            AWS-backup Installation\n\
--------------------------------------------------"

    read -p "Enter aws server: " AWS_client
    create_env_variable "AWS" "$AWS_client"
    
    touch "$BACKUP"
    info_print "$BACKUP created." 

    while true; do
        read -p "Add backup directory or file name (key or leave empty to quit): " key
        [[ -z "$key" ]] && break
        read -p "Enter value for $key: " value
        create_env_variable "$key" "$value" $BACKUP
    done
    info_print "You can add more names later by editing $BACKUP."

    CRON_JOB="0 0 * * * $SCRIPT_FILE/aws-backup.sh"
    crontab -l | grep -F "$CRON_JOB" > /dev/null 2>&1
    if ! crontab -l | grep -Fq "$CRON_JOB"; then
        (crontab -l 2>/dev/null; echo "$CRON_JOB") | crontab -
        info_print "Cron job added." 6
    fi

    exit 0
fi

if [[ "$1" == "clean" ]]; then
    info_print "Purge aws-bak files."
    rm -f $BACKUP
    exit 0
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
    else
        info_print "$SOURCE_PATH not found or inaccessible." 3
    fi
done < "$BACKUP"

source /usr/local/bin/libs/notifications.sh 
send_notification "All AWS-backup file have been linked"