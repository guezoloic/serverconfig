#!/bin/bash

source "./scripts/common.sh"

if [[ $EUID -ne 0 ]]; then
    echo "the script needs to be as root."
    exit 1
fi

# if [ ! -d "$ENV_DIR" ]; then
#     echo "$ENV_DIR is missing..., "
#     mkdir -p $ENV_DIR
# fi