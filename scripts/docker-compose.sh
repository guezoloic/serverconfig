#!/bin/bash

INSTALLED=$1
if [[ "--install" == $INSTALLED ]]; then 
    source /usr/local/bin/libs/common.sh

    info_print "\n\
==================================================\n\
            docker-compose Installation\n\
--------------------------------------------------"

    ENV_LIST=("EMAIL" "HOSTNAME")

    for env in "${ENV_LIST[@]}"; do
        read -p "Enter value for $env: " value
        create_env_variable "$env" "$value"
    done

    source /etc/serverconfig/.env

    if [[ -f "$ETC_DIR/docker-compose.yml" ]]; then
        docker compose -f "$ETC_DIR/docker-compose.yml" up -d --force-recreate && \
        info_print "$ETC_DIR/docker-compose.yml is running." 6;

    else info_print "no docker-compose.yml found at $ETC_DIR" 3;
    fi
    exit 0; 
fi