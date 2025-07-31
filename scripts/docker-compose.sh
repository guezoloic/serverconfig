#!/bin/bash

INSTALLED=$1
if [[ "--install" == $INSTALLED ]]; then 
    source /usr/local/bin/libs/common.sh

    info_print "\n\
==================================================\n\
            docker-compose Installation\n\
--------------------------------------------------"
    
    if [[ -f "$ETC_DIR/docker-compose.yml" ]]; then
        docker compose -f "$ETC_DIR/docker-compose.yml" up -d && \
        info_print "$ETC_DIR/docker-compose.yml is running." 2;

    else info_print "no docker-compose.yml found at $ETC_DIR" 6;
    fi
    exit 0; 
fi