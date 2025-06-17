#!bin/bash

source /etc/serverconfig/.env

case "$PAM_TYPE" in
     open_session)
	     PAYLOAD=" { \"text\": \"$PAM_USER logged in (remote host: $PAM_RHOST) at $(date).\" }"
         ;;
     close_session)
         PAYLOAD=" { \"text\": \"$PAM_USER logged out (remote host: $PAM_RHOST) at $(date).\" }"
         ;;
esac

if [ -n "$PAYLOAD" ] ; then
     curl -X POST "https://api.telegram.org/bot$TOKEN/sendMessage" \
          -d "chat_id=$CHAT_ID" \
          -d "text=$PLAYLOAD" \
          -d "parse_mode=HTML"
fi