#!/bin/bash

FILENAME="serverconfig"

ETC_DIR="/etc/$FILENAME"
ENV_FILE="$ETC_DIR/.env"
LOG="/var/log/$FILENAME.log"

DATETIME_FORMAT="%d-%m-%Y %H:%M:%S"

datetime_print() {
    local message="$1"
    local level="${2:-INFO}"
    local timestamp="[$(date +"$DATETIME_FORMAT")]"

    echo -e "$timestamp - $level: $message" | tee -a "$LOG"
}