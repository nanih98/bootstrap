#!/bin/sh 

export DEBIAN_FRONTEND=noninteractive

PACKAGES="curl git cron monit python3-gi unattended-upgrades dbus jq clamav"


# Install packages 

apt-get install $PACKAGES -y 


# Install docker
curl https://get.docker.com | sh 
usermod -aG docker root 
systemctl enable docker
systemctl start docker
# Install docker-compose (only for root)
curl -L "https://github.com/docker/compose/releases/download/1.25.3/docker-compose-$(uname -s)-$(uname -m)" -o /usr/bin/docker-compose
chmod +x /usr/bin/docker-compose


# Setup email alert for ssh login 

mkdir /etc/pam.scripts
chmod 0755 /etc/pam.scripts
cp ssh_alert.sh /etc/pam.scripts/
chmod 0700 /etc/pam.scripts/ssh_alert.sh
chown root:root /etc/pam.scripts/ssh_alert.sh

cp python-ssh-login.py /usr/bin/sshmail
chown root:root /usr/bin/sshmail
chmod 700 /usr/bin/sshmail

echo " # SSH Alert script
session required pam_exec.so /etc/pam.scripts/ssh_alert.sh
" >> /etc/pam.d/sshd

#Setup clamav for daily scann security && email send when a malware is found!

cp clamscan-email.py /usr/bin/malwaremail
chown root:root /usr/bin/malwaremail
chmod 700 /usr/bin/malwaremail



# Configure monit
echo "Configure monit"
cat monitrc  > /etc/monit/monitrc
/etc/init.d/monit restart

# Configure logrotate
echo "Configure logrotate"
cat logrotate.d-docker > /etc/logrotate.d/docker

# Tune sysctl
echo "Kernel tune"
cat sysctl.conf > /etc/sysctl.conf

