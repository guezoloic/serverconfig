#!/bin/bash

INSTALLED=$1
if [[ "--install" == $INSTALLED ]]; then 
    info_print "\n\
==================================================\n\
            wireguard Installation\n\
--------------------------------------------------"
    source /usr/local/bin/libs/common.sh
    
    if [[ -f "$ETC_DIR/docker-compose.yml" ]]; then
        docker compose up -d -f $ETC_DIR/docker-compose.yml && \
        info_print "$ETC_DIR/docker-compose.yml is running." 2;

    else info_print "no docker-compose.yml found at $ETC_DIR" 6;
    fi
    exit 0; 
fi