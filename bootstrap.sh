#!/bin/sh 

export DEBIAN_FRONTEND=noninteractive

PACKAGES="curl cron monit python3-gi unattended-upgrades dbus jq clamav vim"

# Install packages 

cp -a /etc/apt/sources.list /etc/apt/sources.list.backup

cp sources.list /etc/apt

apt-get update -y && apt-get install $PACKAGES -y 

# Bashrc for root (specially because I want umask 077 (700) permissions for root)

cp .bashrc /root/

# Custom editor
rm -f /etc/alternatives/editor
ln -s /usr/bin/vim /etc/alternatives/editor

# Copy init.sh script usefull to up docker containers
cp init.sh /root
chmod +x /root/init.sh
chown root:root /root/init.sh
chmod 700 /root/init.sh 

# Copy custom vim configuration

cp vimrc /etc/vim/

# Copy the cron for daily upgrades at 1:00

cp upgrade.sh /root/
chmod 700 /root/upgrade.sh
mkdir /var/log/upgrade
cp cron-upgrade /etc/cron.d/upgrade

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
chmod 0700 /etc/pam.scripts
cp ssh_alert.sh /etc/pam.scripts/
chmod 0700 /etc/pam.scripts/ssh_alert.sh
chown root:root /etc/pam.scripts/ssh_alert.sh

cp python-ssh-login.py /usr/bin/sshmail
chown root:root /usr/bin/sshmail
chmod 700 /usr/bin/sshmail

cp whitelist.txt /etc/pam.scripts/
chmod 700 /etc/pam.scripts/whitelist.txt
#Put your ip line by line without a mask '/ 32 ..' into the whitelist.txt file.

echo " # SSH Alert script
session required pam_exec.so /etc/pam.scripts/ssh_alert.sh
" >> /etc/pam.d/sshd

#Setup clamav for daily scann security && email send when a malware is found! Clamav freshclam service are always enabled but if you create a cron called 'clamav-freshclam' 
#Info:There is a service called clamav-freshclam that keeps the database update active. This can consume a lot of ram, so if the cron called 'clamav-freshclam' is created, this service is deactivated and has to be done by hand. In our case we will do it by hand in the script by executing the freshclam command. Check it /etc/systemd/system/multi-user.target.wants/clamav-freshclam.service 

cp clamscan-email.py /usr/bin/malwaremail
chown root:root /usr/bin/malwaremail
chmod 700 /usr/bin/malwaremail

### Copy the script of clamav that will execute the cron to scan the directories

cp clam-scan.sh /root/
chmod 700 /root/clam-scan.sh
# Copy the cron to /etc/cron.d that will execute every day the script at 00:00
cp cron-clamscan /etc/cron.d/clamav-freshclam
#I should stop the clamav demon when there is the cron file that I comment ... but just in case we do it manually
systemctl stop clamav-freshclam 
systemctl disable clamav-freshclam

# Configure monit
echo "Configure monit"
cat monitrc  > /etc/monit/monitrc
/etc/init.d/monit restart

# Configure logrotate
echo "Configure logrotate"
cat logrotate.d-docker > /etc/logrotate.d/docker
cat logrotate.d-upgrade > /etc/logrotate.d/upgrade

# Tune sysctl
echo "Kernel tune"
cat sysctl.conf > /etc/sysctl.conf

# Cleanup - Remove the directory bootstrap where have you cloned. In this case, I cloned the directory on /root (git clone http://git.... /root)

cd /root/ && rm -rf bootstrap/
apt-get autoremove -y 
