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
# Prompt for SSH port and key
read -p "Enter SSH port [2222]: " SSH_PORT
SSH_PORT=${SSH_PORT:-2222}
ufw allow ${SSH_PORT}/tcp
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
read -p "Enter SSH public key (leave blank for default): " SSH_KEY
DEFAULT_SSH_KEY="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCbeYfOKRxq2SAc8WwyOrCdkTnD1Cct3CKLwgZQeh49Cw2oFTezIw+NaTAkhaw5RuYAOgSHWiAiZ+BdF+zIehIXWcwBB6UPZ+vh0V2XdMO6liVBA13ry9IsvAH2HMu1ZzxrD07JfzU5+HgcuoJofyL+dsBzgn6dp6Nvg6PUpCn5Mcoz0xYhomhCNQK4TnJEMbochXCj/wZJlJ+46OA8LMaseReN9jKVfobh4CxRqiP5kAnDY4SKCrGJY0BhXPxJulNPLy4gl/XHj9sP4R0JsJKaMNpID840i6oqPRCnMCqgAUvCm+s4t9aatdiYx4BfzYxV8bIzkbjJgpgIXJZ1gzdADj1unF8GiH0eGS69Y1TSeGsezLOld+DFSW+kDPklE8pvoMztyRVO+h8xqB2AHhV52d01/HR6Evgv5peshawltZygsCyOOui/7LsAOmPriLDQXO/p8pM7Wtda1hFF2Ym6qVCI4xa7fJMJ6EM2nM3oYMHhpcu8oL6ntt2WCFEU5FpsqHjFqdByDnkI1WmzBOaQKC5zgFNr0N0RIpCCFTS/o/2Kn/28WNIPAobognqwxMvQbMWlT5ZCYM+QPZxLCWc77xtLlgUxqqBlHALQvLPjrlA+JJY2FELYayPa//cYKWMGcQObs8xuac1jCeZL53fTiktiHJhOOzWYHooJehqw1Q== dipak@coderstm.com"
SSH_KEY=${SSH_KEY:-$DEFAULT_SSH_KEY}
mkdir -p /home/goazh/.ssh
chmod 700 /home/goazh/.ssh
echo "$SSH_KEY" > /home/goazh/.ssh/authorized_keys
chmod 600 /home/goazh/.ssh/authorized_keys
chown -R goazh:goazh /home/goazh/.ssh

echo ">>> Securing SSH..."
if grep -q "^#\?Port " /etc/ssh/sshd_config; then
	sed -i "s/^#\?Port .*/Port $SSH_PORT/" /etc/ssh/sshd_config
else
	echo "Port $SSH_PORT" >> /etc/ssh/sshd_config
fi
sed -i 's/^#PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config
sed -i 's/^#PasswordAuthentication.*/PasswordAuthentication no/' /etc/ssh/sshd_config
systemctl restart sshd

echo ">>> Post-installation finished."
echo "Login with: ssh -p $SSH_PORT goazh@your-server-ip"