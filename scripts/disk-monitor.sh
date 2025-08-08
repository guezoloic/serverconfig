#!/bin/bash

source /usr/local/bin/libs/common.sh
source /etc/serverconfig/.env

INSTALLED=$1
if [[ "--install" == $INSTALLED ]]; then 
    info_print "\n\
==================================================\n\
            disk-monitor Installation\n\
--------------------------------------------------"
    CRON_JOB="0 3 * * 1 $SCRIPT_FILE/scripts/disk-monitor.sh"
    crontab -l | grep -F "$CRON_JOB" > /dev/null 2>&1
    if ! crontab -l | grep -Fq "$CRON_JOB"; then
        (crontab -l 2>/dev/null; echo "$CRON_JOB") | crontab -
        info_print "Cron job added." 6
    fi
    exit 0; 
fi

source /usr/local/bin/libs/notifications.sh

usage=80

send_notification "$(
    df -h / | grep / | awk -v max="$usage" '{
        usage = $5;
        gsub("%", "", usage);
        if (usage > max) {
            printf "<b>⚠️ Warning ⚠️:</b>\nDisk usage is at <code>%d%%</code>, which exceeds the threshold of <code>%d%%</code>.\n\n", usage, max;
        }
        printf "<b>💾 Disk Usage Information 💾 :</b>\nTotal: <code>%s</code>, Used: <code>%s</code>, Available: <code>%s</code>\n", $2, $3, $4;
    }'
)"
