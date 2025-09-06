#!/bin/bash
# secure-server-setup.sh
# Harden your server: create sudo user, secure SSH, set up firewall, and install fail2ban

set -e

# Prompt for new username and password
echo "Enter the new admin username:"
read -r NEW_USER

while id "$NEW_USER" &>/dev/null; do
  echo "User $NEW_USER already exists. Please enter a different username:"
  read -r NEW_USER
done

echo "Enter password for $NEW_USER:"
read -rs NEW_PASS

echo "Confirm password:"
read -rs CONFIRM_PASS

while [[ "$NEW_PASS" != "$CONFIRM_PASS" ]]; do
  echo "Passwords do not match. Try again."
  echo "Enter password for $NEW_USER:"
  read -rs NEW_PASS
  echo "Confirm password:"
  read -rs CONFIRM_PASS
done

# Prompt for new SSH port
echo "Enter new SSH port (1024-65535):"
read -r SSH_PORT

while ! [[ "$SSH_PORT" =~ ^[0-9]+$ ]] || ((SSH_PORT < 1024 || SSH_PORT > 65535)); do
  echo "Invalid port. Enter a port between 1024 and 65535:"
  read -r SSH_PORT
done

# Create new user and set password
adduser --disabled-password --gecos "" "$NEW_USER"
echo "$NEW_USER:$NEW_PASS" | chpasswd
usermod -aG sudo "$NEW_USER"

# Harden SSH config
SSHD_CONFIG="/etc/ssh/sshd_config"
cp "$SSHD_CONFIG" "$SSHD_CONFIG.bak"
sed -i \
  -e "s/^#*PermitRootLogin.*/PermitRootLogin no/" \
  -e "s/^#*PasswordAuthentication.*/PasswordAuthentication yes/" \
  -e "s/^#*Port .*/Port $SSH_PORT/" \
  "$SSHD_CONFIG"

# If Port not present, add it
if ! grep -q "^Port $SSH_PORT" "$SSHD_CONFIG"; then
  echo "Port $SSH_PORT" >> "$SSHD_CONFIG"
fi

# Restart SSH service
if systemctl is-active --quiet ssh; then
  systemctl restart ssh
elif systemctl is-active --quiet sshd; then
  systemctl restart sshd
else
  service ssh restart || service sshd restart
fi

# Set up UFW firewall
ufw allow "$SSH_PORT"/tcp
ufw allow 80/tcp
ufw allow 443/tcp
ufw --force enable

# Install fail2ban
apt-get update && apt-get install -y fail2ban
systemctl enable fail2ban --now

# Update and upgrade system
apt-get upgrade -y

# Output summary
echo "\nServer hardening complete!"
echo "- SSH root login disabled."
echo "- New sudo user: $NEW_USER"
echo "- SSH port set to: $SSH_PORT"
echo "- UFW firewall enabled."
echo "- fail2ban installed."
echo "\nIMPORTANT: Open a new SSH session with the new user and port before closing your current session!"
