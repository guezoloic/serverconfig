source /usr/local/bin/libs/common.sh
source /etc/serverconfig/.env

INSTALLED=$1

if [[ "--install" == $INSTALLED ]]; then
    info_print "\n\
==================================================\n\
            notifications Installation\n\
--------------------------------------------------"

    ENV_LIST=("TELEGRAM_CHAT_ID" "TELEGRAM_TOKEN")

    for env in "${ENV_LIST[@]}"; do
        read -p "Enter value for $env: " value
        create_env_variable "$env" "$value"
    done

    exit 0
fi

send_notification() {
    local message="$1"
    curl -X POST "https://api.telegram.org/bot$TELEGRAM_TOKEN/sendMessage" \
        -d "chat_id=$TELEGRAM_CHAT_ID" \
        -d "text=$message" \
        -d "parse_mode=HTML"
}