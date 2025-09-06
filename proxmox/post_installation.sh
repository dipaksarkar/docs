#!/bin/bash
set -e

echo ">>> Updating system..."
apt update && apt -y full-upgrade

echo ">>> Installing useful tools..."
apt install -y htop iotop iftop nvme-cli zfsutils-linux curl wget gnupg2 ufw fail2ban sudo

echo ">>> Tuning ZFS..."
echo "options zfs zfs_arc_max=8589934592" > /etc/modprobe.d/zfs.conf
update-initramfs -u
zfs set atime=off data || true
zfs set compression=lz4 data || true

echo ">>> Updating fstab to reduce disk writes..."
sed -i 's/errors=remount-ro/defaults,noatime,errors=remount-ro/' /etc/fstab

echo ">>> Configuring firewall..."
ufw default deny incoming
ufw default allow outgoing
ufw allow 2252/tcp
ufw allow 8006/tcp
ufw --force enable

echo ">>> Configuring Fail2Ban..."
systemctl enable fail2ban --now

echo ">>> Configuring Proxmox no-subscription repo..."
sed -i 's/^deb/#deb/' /etc/apt/sources.list.d/pve-enterprise.list || true
echo "deb http://download.proxmox.com/debian/pve bookworm pve-no-subscription" > /etc/apt/sources.list.d/pve-no-sub.list
apt update && apt -y dist-upgrade

echo ">>> Creating secure user 'goazh'..."
adduser --gecos "" goazh
usermod -aG sudo goazh

echo ">>> Setting up SSH keys for 'goazh'..."
mkdir -p /home/goazh/.ssh
chmod 700 /home/goazh/.ssh
# Replace with your public key
echo "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMYOURPUBLICKEYHERE user@pc" > /home/goazh/.ssh/authorized_keys
chmod 600 /home/goazh/.ssh/authorized_keys
chown -R goazh:goazh /home/goazh/.ssh

echo ">>> Securing SSH..."
sed -i 's/^#Port.*/Port 2252/' /etc/ssh/sshd_config
sed -i 's/^#PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config
sed -i 's/^#PasswordAuthentication.*/PasswordAuthentication no/' /etc/ssh/sshd_config
systemctl restart sshd

echo ">>> Post-installation finished."
echo "Login with: ssh -p 2252 goazh@your-server-ip"