USER_NAME=root
#needed to install fail2ban
sudo add-apt-repository universe -y

sudo apt-get update -y

#HARDENING

#secure shared memory
echo "tmpfs /run/shm tmpfs defaults,noexec,nosuid 0 0" >> /etc/fstab

#harden ssh
#sed -i "s/.*PubkeyAuthentication.*/PubkeyAuthentication yes/g" /etc/ssh/sshd_config
sed -i "s/.*PasswordAuthentication.*/PasswordAuthentication no/g" /etc/ssh/sshd_config
#sed -i "s/.*PermitRootLogin.*/PermitRootLogin no/g" /etc/ssh/sshd_config
#sed -i "s/.*AllowUsers.*/AllowUsers $USER_NAME/g" /etc/ssh/sshd_config

sudo apt install -y fail2ban

#set up fail2ban
cat > /etc/fail2ban/jail.local << EOL
[DEFAULT]
bantime = 1h
maxretry = 3


backend = auto
mode = normal


# A host is banned if it has generated "maxretry" during the last "findtime"
# seconds.
findtime = 900

#
[sshd]
enabled = true
port = ssh
EOL

#install required software

sudo apt install -y git

#delete the ssh message about how docker is configured
rm -rf /etc/update-motd.d/99-one-click
#disable ufw since digital ocean firewall is enabled
sudo ufw disable

cat > /etc/init/startcontainersatstartup.conf << EOL
start on startup
task
exec /root/startcontainers.sh
EOL

# MOUNT VOLUME FOR PERSISTEN STORAGE IN /mnt/applicationdata
# Create a mount point for your volume:
mkdir -p /mnt/applicationdata

# Mount your volume at the newly-created mount point:
mount -o discard,defaults,noatime /dev/disk/by-id/scsi-0DO_Volume_applicationdata /mnt/applicationdata

# Change fstab so the volume will be mounted after a reboot
echo '/dev/disk/by-id/scsi-0DO_Volume_applicationdata /mnt/applicationdata ext4 defaults,nofail,discard 0 0' | sudo tee -a /etc/fstab

#make sure this droplet has permission to edit the volume
sudo chown -R root:root /mnt/applicationdata
sudo chmod -R o+xwr /mnt/applicationdata

sudo chmod o+x /root/startcontainers.sh
