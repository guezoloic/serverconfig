#!/bin/bash

source /usr/local/bin/libs/common.sh
source /etc/serverconfig/.env

INSTALLED=$1
if [[ "--install" == $INSTALLED ]]; then 
    info_print "\n\
==================================================\n\
            sshd-login Installation\n\
--------------------------------------------------"

    login='session optional pam_exec.so /usr/local/bin/scripts/sshd-login.sh'
    file='/etc/pam.d/common-session'

    if [[ ! -f "$file" ]]; then
        info_print "$file doesn't found." 3
        exit 1
    fi

    if ! grep -Fxq "$login" "$file"; then
        echo "$login" >> "$file"
        info_print "login command added to $file." 6
    else
        info_print "login command already added to $file." 2
    fi
    exit 0; 
fi

source /usr/local/bin/libs/notifications.sh

case "$PAM_TYPE" in
  open_session)
    PAYLOAD="<b>Login Event</b>\nUser <code>$PAM_USER</code> logged in from <code>$PAM_RHOST</code> at <i>$(date)</i>."
    ;;
  close_session)
    PAYLOAD="<b>Logout Event</b>\nUser <code>$PAM_USER</code> logged out from <code>$PAM_RHOST</code> at <i>$(date)</i>."
    ;;
esac

if [ -n "$PAYLOAD" ] ; then
     send_notification "$PAYLOAD"
fi