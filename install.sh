#!/bin/bash

source "./scripts/common.sh"

SCRIPT_FILE="/usr/local/bin"

create_env_variable() {
    local key="$1"
    local value="$2"

    if [[ -z "$value" ]]; then
        if grep -q "^$key=*" "$ENV_FILE" 2>/dev/null; then
            datetime_print "$key not updated."
            return
        else 
            datetime_print "$key not set (empty input)."
            return
        fi
    fi

    if grep -q "^$key=" "$ENV_FILE" 2>/dev/null; then
        if $AUTO_CONFIRM; then
            yn="y"
        else
            read -p "$key already set, overwrite? (y/N): " yn
        fi
        case "$yn" in
            [Yy]*) 
                sed -i "s/^$key=.*/$key=$value/" "$ENV_FILE"
                datetime_print "$key updated."
                ;;
            *) 
                datetime_print "$key not changed."
                ;;
        esac
    else
        echo "$key=$value" >> "$ENV_FILE"
        datetime_print "$key \e[32mset\e[0m."
    fi
}

install_file() {
    local filename="$1"
    local pathname="$2"
    local argument="${3:--Dm755}"
    
    datetime_print "Installing $filename to $pathname..."

    if [[ ! -f "scripts/$filename" ]]; then
        datetime_print "Source file scripts/$filename not found." "\e[31mERROR\e[0m"
        exit 1
    fi
    
    if [[ -e "$pathname/$filename" ]]; then
        if $AUTO_CONFIRM; then
            yn="y"
        else
            read -p "$pathname/$filename already set, overwrite? (y/N): " yn
        fi
        case "$yn" in
            [Yy]*)
            ;;
            *) 
                datetime_print "$pathname/$filename not changed."
                return
            ;;
        esac
    fi

    install $argument "scripts/$filename" "$pathname/$filename" && \
        datetime_print "$filename \e[32minstalled.\e[0m" || \
        { datetime_print "Error while installing $filename" "\e[31mERROR\e[0m"; exit 1; }
}

AUTO_CONFIRM=false
[[ "$1" == "--true" ]] && AUTO_CONFIRM=true

INSTALLED_PROG=("curl" "aws")
for prog in ${INSTALLED_PROG[@]}; do
    echo -n "Verifing $prog... "
    if ! command -v $prog &> "/dev/null"; then
        echo -e "\e[31mError: not installed\e[0m" 
        exit 1
    fi
    echo -e "\e[32mDone\e[0m"
done

if [[ $EUID -ne 0 ]]; then
    echo "The script needs to run as root."
    exit 1
fi

touch "$LOG" || { echo "\e[31mCannot create log file $LOG\e[0m"; exit 1; }
chmod 644 "$LOG"

datetime_print "Starting ServerConfig Installation v1.0.0"

mkdir -p "$ETC_DIR" && \
datetime_print "$ETC_DIR ensured."

datetime_print "Installing scripts to $SCRIPT_FILE..."

echo
datetime_print "------------- Install Files -------------"
for element in scripts/*.sh; do install_file    "$(basename $element)"             "$SCRIPT_FILE"  -Dm755; done
install_file                                    "docker-compose.yml"   "$ETC_DIR"      -Dm644


echo
datetime_print "--------- Define .env variables ---------"

ENV_LIST=("AWS" "TELEGRAM_CHAT_ID" "TELEGRAM_TOKEN" "EMAIL" "WG_HOSTNAME_VPN")

touch "$ENV_FILE"
for env in "${ENV_LIST[@]}"; do
    read -p "Enter value for $env: " value
    create_env_variable "$env" "$value"
done

while true; do
    read -p "Add another env variable? (key or leave empty to quit): " key
    [[ -z "$key" ]] && break
    read -p "Enter value for $key: " value
    create_env_variable "$key" "$value"
done

echo
datetime_print "---------- Script Installation ----------"
for element in /usr/local/bin/*.sh; do
    bash "$element" --install
done

echo
datetime_print "--------- Installation Complete ---------"
datetime_print "All config files are in $ETC_DIR"
datetime_print "All scripts are in $SCRIPT_FILE"

echo "Log file written at: $LOG"