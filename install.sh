#!/bin/bash

source ./libs/common.sh

mkdir -p $ETC_DIR
rm -f $LOG

ISERROR=false
INSTALLED_DEP=( $(grep -v '^#' $(pwd)/requirements.txt) )


if [[ $EUID -ne 0 ]]; then
    echo "The script needs to run as root."
    exit 1
fi

touch "$LOG" || ISERROR=true
if $ISERROR; then 
    info_print "Failed to Create $LOG" 3 false; exit 1 
fi

chmod 644 "$LOG"

info_print "\n\
==================================================\n\
         ServerConfig Installation v1.0.0\n\
--------------------------------------------------"
info_print "License     : MIT"
info_print "Repository  : https://github.com/guezoloic/serverconfig"
info_print "Date        : Installation $(date '+%Y-%m-%d %H:%M:%S')"


if $ISERROR; then 
    info_print "Failed to move some scripts to $SCRIPT_FILE, See log $LOG" 3 false; exit 1 
fi

info_print "\n\
==================================================\n\
   Installing config files to $ETC_DIR\n\
--------------------------------------------------" -- false

for config in config/*; do
    filename=$(basename "$config")
    info_print "Moving $filename to $SCRIPT_FILE"

    install $argument "$config" "$ETC_DIR/$filename"  -Dm755 \
    && { info_print "$ETC_DIR/$filename installed." 6; } \
    || { info_print "$ETC_DIR/$filename failed." 3; ISERROR=true; }
done

if $ISERROR; then 
    info_print "Failed to move some scripts to $ENV_FILE, See log $LOG" 3 false; exit 1 
fi

info_print "\n\
==================================================\n\
              Checking dependencies \n\
--------------------------------------------------" -- false

for dep in ${INSTALLED_DEP[@]}; do
    if command -v "$dep" &>/dev/null; then
        info_print "$dep is installed." 6
    else
        info_print "$dep is not installed." 3
        ISERROR=true
    fi
done

if $ISERROR; then 
    info_print "Some Dependencies are missing. Please check requirements.txt." 3 false; exit 1 
fi

info_print "\n\
==================================================\n\
        Installing scripts to $SCRIPT_FILE \n\
--------------------------------------------------" -- false

for scripts in libs/*.sh scripts/*.sh; do
    info_print "Moving $scripts to $SCRIPT_FILE"
    output="$SCRIPT_FILE/$scripts"

    install $argument "$scripts" $output -Dm755 \
    && { info_print "$output installed." 6; } \
    || { info_print "$output failed." 3; ISERROR=true; }
done

touch $ENV_FILE
for element in $SCRIPT_FILE/*/*.sh; do
    bash "$element" --install
done

info_print "\n\
==================================================\n\
             Installation Complete\n\
--------------------------------------------------" 
info_print "All config files are in $ETC_DIR"
info_print "All scripts are in $SCRIPT_FILE"

echo "Log file written at: $LOG"