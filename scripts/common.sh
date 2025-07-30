#!/bin/bash

FILENAME="serverconfig"

ETC_DIR="/etc/$FILENAME"
ENV_FILE="$ETC_DIR/.env"
LOG="/var/log/$FILENAME.log"
SCRIPT_FILE="/usr/local/bin"

INFO="\e[34mINFO\e[0m"
SUCCESS="\e[32mSUCCESS\e[0m"
WARN="\e[33mWARN\e[0m"
ERROR="\e[31mERROR\e[0m"
DEBUG="\e[35mDEBUG\e[0m"
ACTION="\e[36mACTION\e[0m"

DATETIME_FORMAT="%d-%m-%Y %H:%M:%S"

info_print() {
    local message="$1"
    local level="${2:-1}"
    local write_log="${3:-true}"

    case $level in 
        1|--) local level=$INFO;;
        2) local level=$WARN;;
        3) local level=$ERROR;;
        4) local level=$DEBUG;;
        5) local level=$ACTION;;
        6) local level=$SUCCESS;;
        *);;
    esac

    local output="[$(date +"$DATETIME_FORMAT")] - $level: $message"

    if [ "$write_log" = true ]; then echo -e "$output" | tee -a "$LOG"
    else echo -e "$output"
    fi
}

create_env_variable() {
    local key="$1"
    local value="$2"
    local file="${3:-$ENV_FILE}"

    if [[ -z "$value" ]]; then
        if grep -q "^$key=*" "$file" 2>/dev/null; then
            info_print "$key not updated."
            return
        else 
            info_print "$key not set (empty input)."
            return
        fi
    fi

    if grep -q "^$key=" "$file" 2>/dev/null; then
        if $AUTO_CONFIRM; then
            yn="y"
        else
            read -p "$key already set, overwrite? (y/N): " yn
        fi
        case "$yn" in
            [Yy]*) 
                sed -i "s/^$key=.*/$key=$value/" "$file"
                info_print "$key updated."
                ;;
            *) 
                info_print "$key not changed."
                ;;
        esac
    else
        echo "$key=$value" >> "$file"
        info_print "$key \e[32mset\e[0m."
    fi
}