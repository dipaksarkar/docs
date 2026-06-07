#!/bin/bash
set -e

# Interactive Password Prompt
echo "=================================================="
read -p "Enter the new root password: " MANUAL_ROOT_PASSWORD
echo "=================================================="

# Enforce non-interactive environment for backend package configurations
export DEBIAN_FRONTEND=noninteractive

echo ">>> Updating system base layers..."
apt update && apt -y full-upgrade

echo ">>> Installing systems monitoring & utility tools..."
apt install -y htop iotop iftop nvme-cli curl wget gnupg2 ufw fail2ban sudo

echo ">>> Updating root password via chpasswd..."
echo "root:$MANUAL_ROOT_PASSWORD" | chpasswd

# Clear the variable from memory immediately after use for security
unset MANUAL_ROOT_PASSWORD

echo ">>> Automated Storage: Building Snapshot-Ready LVM-Thin Pool..."
lvcreate -l 100%FREE -n pve-thinpool vg
lvconvert --type thin-pool -y vg/pve-thinpool

echo ">>> Configuring Proxmox 9 No-Subscription Repositories..."
if [ -f /etc/apt/sources.list.d/pve-enterprise.list ]; then
    sed -i 's/^deb/#deb/' /etc/apt/sources.list.d/pve-enterprise.list
fi

echo "deb http://download.proxmox.com/debian/pve trixie pve-no-subscription" > /etc/apt/sources.list.d/pve-no-sub.list
apt update && apt -y dist-upgrade

echo ">>> Creating secure user 'goazh'..."
if ! id "goazh" &>/dev/null; then
    useradd -m -s /bin/bash -g sudo goazh
    passwd -d goazh
fi

echo ">>> Setting up production SSH keys for 'goazh'..."
mkdir -p /home/goazh/.ssh
chmod 700 /home/goazh/.ssh

echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCbeYfOKRxq2SAc8WwyOrCdkTnD1Cct3CKLwgZQeh49Cw2oFTezIw+NaTAkhaw5RuYAOgSHWiAiZ+BdF+zIehIXWcwBB6UPZ+vh0V2XdMO6liVBA13ry9IsvAH2HMu1ZzxrD07JfzU5+HgcuoJofyL+dsBzgn6dp6Nvg6PUpCn5Mcoz0xYhomhCNQK4TnJEMbochXCj/wZJlJ+46OA8LMaseReN9jKVfobh4CxRqiP5kAnDY4SKCrGJY0BhXPxJulNPLy4gl/XHj9sP4R0JsJKaMNpID840i6oqPRCnMCqgAUvCm+s4t9aatdiYx4BfzYxV8bIzkbjJgpgIXJZ1gzdADj1unF8GiH0eGS69Y1TSeGsezLOld+DFSW+kDPklE8pvoMztyRVO+h8xqB2AHhV52d01/HR6Evgv5peshawltZygsCyOOui/7LsAOmPriLDQXO/p8pM7Wtda1hFF2Ym6qVCI4xa7fJMJ6EM2nM3oYMHhpcu8oL6ntt2WCFEU5FpsqHjFqdByDnkI1WmzBOaQKC5zgFNr0N0RIpCCFTS/o/2Kn/28WNIPAobognqwxMvQbMWlT5ZCYM+QPZxLCWc77xtLlgUxqqBlHALQvLPjrlA+JJY2FELYayPa//cYKWMGcQObs8xuac1jCeZL53fTiktiHJhOOzWYHooJehqw1Q== dipak@coderstm.com" > /home/goazh/.ssh/authorized_keys

chmod 600 /home/goazh/.ssh/authorized_keys
chown -R goazh:goazh /home/goazh/.ssh

echo ">>> Securing SSH Service Daemons..."
SSH_PORT=2222
sed -i "s/^#\?Port .*/Port $SSH_PORT/" /etc/ssh/sshd_config 2>/dev/null || echo "Port $SSH_PORT" >> /etc/ssh/sshd_config
sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config
sed -i 's/^#\?PasswordAuthentication.*/PasswordAuthentication no/' /etc/ssh/sshd_config
systemctl restart sshd || systemctl restart ssh

echo ">>> Configuring UFW Network Firewall Elements..."
ufw default deny incoming
ufw default allow outgoing
ufw allow ${SSH_PORT}/tcp
ufw allow 8006/tcp
ufw --force enable

echo ">>> Activating Fail2Ban Security Profiles..."
systemctl enable fail2ban --now

echo ">>> Post-installation execution completed successfully."