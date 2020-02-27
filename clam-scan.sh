#!/bin/bash

message="Malware found in the machine $(uname -a)"
export message

LOGFILE="/var/log/clamav/clamav-$(date +'%Y-%m-%d').log";
DIRTOSCAN="/"; # seperar directorios si hay más de uno

# Refresh database
freshclam

for S in ${DIRTOSCAN}; do
 DIRSIZE=$(du -sh "$S" 2>/dev/null | cut -f1);
 echo "Starting a daily scan of "$S" directory.
 Amount of data to be scanned is "$DIRSIZE".";
 clamscan -ri "$S" >> "$LOGFILE";
 # get the value of "Infected lines"
 MALWARE=$(tail "$LOGFILE"|grep Infected|cut -d" " -f3);
 # if the value is not equal to zero, send an email with the log file attached
 if [ "$MALWARE" -ne "0" ];then
 # using custom python script
 export LOGFILE
 /usr/bin/malwaremail  
 fi 
done
exit 0
