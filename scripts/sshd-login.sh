#!bin/bash

source /usr/local/bin/notifications.sh

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