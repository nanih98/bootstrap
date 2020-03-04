#!/bin/bash

subject="New SSH connection to $(uname -n)-machine"
export subject 

message="
	A SSH login was successful, so here are some information for security:
  	User:        "$PAM_USER"
	User IP Host: "$PAM_RHOST"
	Service:     "$PAM_SERVICE"
	TTY:         "$PAM_TTY"
	Date:        `date`
	Server:      `uname -a`
"
export message

if [ "${PAM_TYPE}" = 'open_session' ]; then
   if grep -Fxq "$PAM_RHOST" whitelist.txt  
   then
	/usr/bin/sshmail
   fi
fi

exit 0
