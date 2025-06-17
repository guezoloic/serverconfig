#!/bin/bash

FILENAME="serverconfig"

ENV_DIR="/etc/$FILENAME"
ENV_FILE="$ENV_DIR/.env"
LOG="/var/log/$FILENAME.log"

DATETIME_FORMAT="%d-%m-%Y %H:%M:%S"

datetime_print() {
    local message="$1"
    local level="${2:-INFO}"
    local timestamp="[$(date +"$DATETIME_FORMAT")]"

    echo "$timestamp - $level: $message" | tee -a "$LOG"
}