#! /bin/bash

apt-get update -y && apt-get upgrade -y && apt-get dist-upgrade -y
apt-get autoremove -y 
unattended-upgrade -d
