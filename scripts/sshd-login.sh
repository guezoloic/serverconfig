#!bin/bash

source /usr/local/bin/notifications.sh

# initialize_config() {
#     local isInstalling="$1"
#     local target_file="$2"
#     local crontab_configuration="$3"
#     local link_path="$4"

#     if [[ $isInstalling != "--install" ]]; then
#         return;
#     fi

#     echo "$crontab_configuration $0" | crontab -
# }

# install_para="$1"
# if [[ $install_para == "--install" ]]; then

# fi

case "$PAM_TYPE" in
     open_session)
	     PAYLOAD=" { \"text\": \"$PAM_USER logged in (remote host: $PAM_RHOST) at $(date).\" }"
         ;;
     close_session)
         PAYLOAD=" { \"text\": \"$PAM_USER logged out (remote host: $PAM_RHOST) at $(date).\" }"
         ;;
esac

if [ -n "$PAYLOAD" ] ; then
     send_notification "$PAYLOAD"
fi