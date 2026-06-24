#!/bin/bash
set -e

# Enforce non-interactive environment for backend package configurations
export DEBIAN_FRONTEND=noninteractive

echo ">>> Generating secure random system credentials..."
RANDOM_ROOT_PW=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 16)
RANDOM_USER_PW=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 16)
TARGET_SSH_PORT=22

echo ">>> Fetching official Proxmox Archive Keys..."
wget -q https://enterprise.proxmox.com/debian/proxmox-archive-keyring-trixie.gpg -O /usr/share/keyrings/proxmox-archive-keyring.gpg

echo ">>> Configuring Proxmox 9 Trixie No-Subscription Repositories (DEB822 Format)..."
# Wipe the legacy /etc/apt/sources.list to prevent Bookworm mismatch errors
truncate -s 0 /etc/apt/sources.list

# Build the correct multi-line Trixie sources configuration
cat > /etc/apt/sources.list.d/proxmox.sources << 'EOF'
Types: deb
URIs: http://download.proxmox.com/debian/pve
Suites: trixie
Components: pve-no-subscription
Signed-By: /usr/share/keyrings/proxmox-archive-keyring.gpg
EOF

# Safely disable the enterprise license repository flags
if [ -f /etc/apt/sources.list.d/pve-enterprise.sources ]; then
    if ! grep -q "Enabled: no" /etc/apt/sources.list.d/pve-enterprise.sources; then
        echo "Enabled: no" >> /etc/apt/sources.list.d/pve-enterprise.sources
    fi
fi

if [ -f /etc/apt/sources.list.d/ceph.sources ]; then
    if ! grep -q "Enabled: no" /etc/apt/sources.list.d/ceph.sources; then
        echo "Enabled: no" >> /etc/apt/sources.list.d/ceph.sources
    fi
fi

echo ">>> Syncing repository indices and running full framework upgrades..."
apt update && apt -y full-upgrade

echo ">>> Installing systems monitoring & utility tools..."
apt install -y htop iotop iftop nvme-cli curl wget gnupg2 fail2ban sudo

echo ">>> Applying new root password baseline..."
echo "root:$RANDOM_ROOT_PW" | chpasswd

echo ">>> Running distro specific component upgrades..."
apt -y dist-upgrade

# ==============================================================================
# USER & GROUP MANAGEMENT LAYER
# ==============================================================================
if ! getent group goazh &>/dev/null; then
    echo ">>> Creating missing group 'goazh'..."
    groupadd goazh
fi

if id "goazh" &>/dev/null; then
    echo ">>> User 'goazh' already exists. Ensuring correct group mappings..."
    usermod -aG sudo,goazh goazh
else
    echo ">>> Creating new secure user 'goazh'..."
    useradd -m -s /bin/bash -g goazh -G sudo goazh
fi

echo ">>> Updating password for 'goazh'..."
echo "goazh:$RANDOM_USER_PW" | chpasswd

# ==============================================================================
# SSH SECURITY CONFIGURATION (Key-Only Enforcement)
# ==============================================================================
PUBLIC_KEY_STRING="ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKi6LUOo/D8SX4gNLak7FxMY2RbHYA6vIgtqFwFjpXvO dipak@coderstm.com"

# Set up keys for goazh user
mkdir -p /home/goazh/.ssh
echo "$PUBLIC_KEY_STRING" > /home/goazh/.ssh/authorized_keys
chmod 700 /home/goazh/.ssh && chmod 600 /home/goazh/.ssh/authorized_keys
chown -R goazh:goazh /home/goazh/.ssh

# Set up keys for root user (Ensures backup recovery links stay active)
mkdir -p /root/.ssh
echo "$PUBLIC_KEY_STRING" > /root/.ssh/authorized_keys
chmod 700 /root/.ssh && chmod 600 /root/.ssh/authorized_keys

echo ">>> Securing SSH Service Configuration..."
sed -i "s/^#\?Port .*/Port $TARGET_SSH_PORT/" /etc/ssh/sshd_config
sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin prohibit-password/' /etc/ssh/sshd_config
sed -i 's/^#\?PasswordAuthentication.*/PasswordAuthentication no/' /etc/ssh/sshd_config

# Verify config syntax before bouncing daemon to prevent locks
if sshd -t; then
    systemctl restart sshd || systemctl restart ssh
else
    echo ">>> ERROR: SSH config validation failed! Reverting modifications..."
    exit 1
fi

# ==============================================================================
# LOCAL BRIDGED INTEGRATION (UFW Warning Clean)
# ==============================================================================
echo ">>> Disabling redundant system UFW layers to let Proxmox Firewall control vmbr0..."
ufw disable || true

echo ">>> Activating Fail2Ban Security Profiles..."
systemctl enable fail2ban --now

# ==============================================================================
# RESOLVE SERVER IP
# ==============================================================================
echo ">>> Resolving public server IP address..."
SERVER_IP=$(curl -s --max-time 5 https://ipinfo.io/ip || curl -s --max-time 5 https://api.ipify.org || curl -s --max-time 5 https://ifconfig.me || ip route get 1.1.1.1 2>/dev/null | awk '{print $7}' || hostname -I | awk '{print $1}')
SERVER_IP=$(echo "$SERVER_IP" | xargs)
if [ -z "$SERVER_IP" ]; then
    SERVER_IP="65.109.56.203"
fi

# Define ANSI colors for styling
BOLD='\033[1m'
GREEN='\033;32m'
RED='\033;31m'
YELLOW='\033;33m'
BLUE='\033;34m'
CYAN='\033;36m'
MAGENTA='\033;35m'
RESET='\033[0m'

clear
echo -e "${CYAN}======================================================================${RESET}"
echo -e "                    ${BOLD}${GREEN}🎉 POST-INSTALLATION COMPLETE 🎉${RESET}"
echo -e "${CYAN}======================================================================${RESET}"
echo -e ""
echo -e "  ${BOLD}${YELLOW}🔒 SECURITY CREDENTIALS GENERATED:${RESET}"
echo -e "  ${BLUE}----------------------------------------------------------------------${RESET}"
echo -e "  ${BOLD}SSH Port:${RESET}        ${GREEN}$TARGET_SSH_PORT${RESET}"
echo -e "  ${BOLD}Root Password:${RESET}   ${MAGENTA}$RANDOM_ROOT_PW${RESET}"
echo -e "  ${BOLD}goazh Password:${RESET}  ${MAGENTA}$RANDOM_USER_PW${RESET}"
echo -e ""
echo -e "  ${BOLD}${RED}⚠️  IMPORTANT REMINDER:${RESET}"
echo -e "  ${BLUE}----------------------------------------------------------------------${RESET}"
echo -e "  Password authentication is now ${BOLD}${RED}DISABLED${RESET}."
echo -e "  You must connect using your SSH private key matching:"
echo -e "  ${CYAN}dipak@coderstm.com${RESET}"
echo -e ""
echo -e "  ${BOLD}${YELLOW}🚀 ACCESS COMMANDS:${RESET}"
echo -e "  ${BLUE}----------------------------------------------------------------------${RESET}"
echo -e "  ${BOLD}SSH Connection:${RESET}  ${CYAN}ssh -p $TARGET_SSH_PORT goazh@$SERVER_IP${RESET}"
echo -e "  ${BOLD}Root Direct:${RESET}     ${CYAN}ssh -p $TARGET_SSH_PORT root@$SERVER_IP${RESET}"
echo -e "  ${BOLD}Proxmox Web UI:${RESET}  ${CYAN}https://$SERVER_IP:8006${RESET}"
echo -e ""
echo -e "${CYAN}======================================================================${RESET}"