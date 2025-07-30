#!/bin/bash

FILENAME="serverconfig"

ETC_DIR="/etc/$FILENAME"
ENV_FILE="$ETC_DIR/.env"
LOG="/var/log/$FILENAME.log"

DATETIME_FORMAT="%d-%m-%Y %H:%M:%S"

info_print() {
    local message="$1"
    local level="${2:-1}"
    local timestamp="[$(date +"$DATETIME_FORMAT")]"

    case $level in 
        1) local level="\e[34mINFO\e[0m";;
        2) local level="\e[33mWARN\e[0m";;
        3) local level="\e[31mERROR\e[0m";;
        4) local level="\e[35mDEBUG\e[0m";;
        5) local level="\e[36mACTION\e[0m";;
        *);;
    esac

    echo -e "$timestamp - $level: $message" | tee -a "$LOG"
}