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

    read -p "Enter endpoint server (leave empty to not define it): " ENDPOINT_server
    [[ -n $ENDPOINT_server ]] && create_env_variable "ENDPOINT" "$ENDPOINT_server"

    info_print "AWS configuration."
    aws configure

    touch "$BACKUP"
    info_print "$BACKUP created."

    while true; do
        read -p "Add backup directory or file name (leave empty to quit): " key
        [[ -z "$key" ]] && break
        create_raw_line_variable "$key" $BACKUP
    done
    info_print "You can add more names later by editing $BACKUP."

    CRON_JOB="0 0 * * * $SCRIPT_FILE/scripts/aws-backup.sh"
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
    if [[ -z "$SOURCE_PATH" || "$SOURCE_PATH" =~ ^[[:space:]]*$ ]]; then
        continue
    fi

    if [[ -d "$SOURCE_PATH" || -f "$SOURCE_PATH" ]]; then
        DEST="s3://$AWS/$(basename "$SOURCE_PATH")"

        if [[ -d "$SOURCE_PATH" ]]; then
            info_print "Syncing directory: $SOURCE_PATH → $DEST"
            aws_cmd=(aws s3 sync "$SOURCE_PATH" "$DEST" --delete)
        elif [[ -f "$SOURCE_PATH" ]]; then
            info_print "Uploading file: $SOURCE_PATH → $DEST"
            aws_cmd=(aws s3 cp "$SOURCE_PATH" "$DEST")
        fi

        if [[ -n "$ENDPOINT" ]]; then
            info_print "Using custom endpoint: $ENDPOINT"
            aws_cmd+=("--endpoint-url" "$ENDPOINT")
        fi

        
        "${aws_cmd[@]}"

        if [ $? -ne 0 ]; then
            info_print "Error while syncing $SOURCE_PATH to the AWS server." 3
            BACKUPSUCCESSED=false
            exit 1

        else 
            info_print "Successfully synced $SOURCE_PATH" 6
            BACKUPSUCCESSED=true 
        fi
    else
        info_print "$SOURCE_PATH not found or inaccessible." 3
        BACKUPSUCCESSED=false
        exit 1
    fi
done < "$BACKUP"

source /usr/local/bin/libs/notifications.sh

if [[ "$BACKUP_SUCCESS" == true ]]; then
    send_notification "<b>AWS Backup:</b> All files successfully backed up."
else
    send_notification "<b>AWS Backup:</b> One or more files failed to back up. Check the log for details."
fi