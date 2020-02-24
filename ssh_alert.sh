#!/bin/bash


subject="New SSH connection to $(uname -a)"
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
	/usr/bin/sshmail
fi

exit 0
