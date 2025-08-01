#!/bin/bash

echo "🚀 Starting Cleanup & Securing Script"

# Exit on error
set -e

USERNAME="goazh"

# 1. Create the new sudo user
echo "🧑 Creating user $USERNAME..."
adduser --disabled-password --gecos "" "$USERNAME"
usermod -aG sudo "$USERNAME"

# Prompt to set password
echo "🔐 Please set a password for the new user:"
passwd "$USERNAME"

# 2. Setup SSH access for the new user (copy from root if it exists)
echo "🔐 Setting up SSH for $USERNAME..."
mkdir -p /home/$USERNAME/.ssh
if [ -f /root/.ssh/authorized_keys ]; then
    cp /root/.ssh/authorized_keys /home/$USERNAME/.ssh/
    echo "📁 Copied authorized_keys from root."
fi
chown -R $USERNAME:$USERNAME /home/$USERNAME/.ssh
chmod 700 /home/$USERNAME/.ssh
chmod 600 /home/$USERNAME/.ssh/authorized_keys

# 3. Remove known malicious files
echo "🧹 Removing known malware files and directories..."
rm -rf /root/.configrc7
rm -rf /tmp/.X2A-unix
rm -rf /tmp/.kswapd00

# 4. Clean up malicious cron jobs from root
echo "🧼 Cleaning root's crontab..."
crontab -l | grep -vE '(/root/.configrc7|/tmp/.X2A-unix)' | crontab -

# 5. Disable root SSH access
echo "🔒 Disabling root SSH login..."
sed -i 's/^#*PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config
sed -i 's/^#*PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config
systemctl restart sshd

# 6. Install security packages
echo "🛡️ Installing fail2ban, rkhunter, and unattended-upgrades..."
apt update -y
apt install -y fail2ban rkhunter unattended-upgrades

# 7. Enable automatic updates
dpkg-reconfigure --priority=low unattended-upgrades

# 8. Run rkhunter check
echo "🔎 Running rootkit check..."
rkhunter --update
rkhunter --check --skip-keypress

echo "✅ Cleanup and hardening complete."
echo "👉 Now login as '$USERNAME' and disable this script:"
echo "    rm -- '$0'"
