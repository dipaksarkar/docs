#!/bin/bash
set -e

# Enforce non-interactive environment for backend package configurations
export DEBIAN_FRONTEND=noninteractive

echo ">>> Generating secure random credentials..."
# Generates random 16-character passwords
RANDOM_ROOT_PW=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 16)
RANDOM_USER_PW=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 16)

# Pick a truly random, non-conflicting port
while true; do
    RANDOM_SSH_PORT=$(shuf -i 2000-9999 -n 1)
    
    # List of common service ports to actively avoid
    case "$RANDOM_SSH_PORT" in
        2000|2049|2181|3000|3306|3389|4443|5000|5432|5672|5900|6379|8000|8006|8080|8443|9000|9092|9200)
            continue
            ;;
        *)
            break
            ;;
    esac
done

echo ">>> Updating system base layers..."
apt update && apt -y full-upgrade

echo ">>> Installing systems monitoring & utility tools..."
apt install -y htop iotop iftop nvme-cli curl wget gnupg2 ufw fail2ban sudo

echo ">>> Applying random root password..."
echo "root:$RANDOM_ROOT_PW" | chpasswd

echo ">>> Automated Storage: Building Snapshot-Ready LVM-Thin Pool..."
# Checks if the thin pool already exists to prevent script errors on multiple runs
if ! lvs | grep -q "pve-thinpool"; then
    lvcreate -l 100%FREE -n pve-thinpool vg
    lvconvert --type thin-pool -y vg/pve-thinpool
else
    echo ">>> LVM-Thin Pool 'pve-thinpool' already exists. Skipping creation..."
fi

echo ">>> Configuring Proxmox 9 No-Subscription Repositories..."
if [ -f /etc/apt/sources.list.d/pve-enterprise.list ]; then
    sed -i 's/^deb/#deb/' /etc/apt/sources.list.d/pve-enterprise.list
fi

echo "deb http://download.proxmox.com/debian/pve trixie pve-no-subscription" > /etc/apt/sources.list.d/pve-no-sub.list
apt update && apt -y dist-upgrade

echo ">>> Managing secure user 'goazh'..."
if id "goazh" &>/dev/null; then
    echo ">>> User 'goazh' already exists. Skipping creation..."
else
    echo ">>> Creating new user 'goazh'..."
    useradd -m -s /bin/bash -g sudo goazh
fi

echo ">>> Updating password for 'goazh'..."
echo "goazh:$RANDOM_USER_PW" | chpasswd

echo ">>> Setting up production SSH keys for 'goazh'..."
mkdir -p /home/goazh/.ssh
chmod 700 /home/goazh/.ssh

echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCbeYfOKRxq2SAc8WwyOrCdkTnD1Cct3CKLwgZQeh49Cw2oFTezIw+NaTAkhaw5RuYAOgSHWiAiZ+BdF+zIehIXWcwBB6UPZ+vh0V2XdMO6liVBA13ry9IsvAH2HMu1ZzxrD07JfzU5+HgcuoJofyL+dsBzgn6dp6Nvg6PUpCn5Mcoz0xYhomhCNQK4TnJEMbochXCj/wZJlJ+46OA8LMaseReN9jKVfobh4CxRqiP5kAnDY4SKCrGJY0BhXPxJulNPLy4gl/XHj9sP4R0JsJKaMNpID840i6oqPRCnMCqgAUvCm+s4t9aatdiYx4BfzYxV8bIzkbjJgpgIXJZ1gzdADj1unF8GiH0eGS69Y1TSeGsezLOld+DFSW+kDPklE8pvoMztyRVO+h8xqB2AHhV52d01/HR6Evgv5peshawltZygsCyOOui/7LsAOmPriLDQXO/p8pM7Wtda1hFF2Ym6qVCI4xa7fJMJ6EM2nM3oYMHhpcu8oL6ntt2WCFEU5FpsqHjFqdByDnkI1WmzBOaQKC5zgFNr0N0RIpCCFTS/o/2Kn/28WNIPAobognqwxMvQbMWlT5ZCYM+QPZxLCWc77xtLlgUxqqBlHALQvLPjrlA+JJY2FELYayPa//cYKWMGcQObs8xuac1jCeZL53fTiktiHJhOOzWYHooJehqw1Q== dipak@coderstm.com" > /home/goazh/.ssh/authorized_keys

chmod 600 /home/goazh/.ssh/authorized_keys
chown -R goazh:goazh /home/goazh/.ssh

echo ">>> Securing SSH Service Daemons..."
sed -i "s/^#\?Port .*/Port $RANDOM_SSH_PORT/" /etc/ssh/sshd_config 2>/dev/null || echo "Port $RANDOM_SSH_PORT" >> /etc/ssh/sshd_config
sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config
sed -i 's/^#\?PasswordAuthentication.*/PasswordAuthentication no/' /etc/ssh/sshd_config
systemctl restart sshd || systemctl restart ssh

echo ">>> Configuring UFW Network Firewall Elements..."
ufw default deny incoming
ufw default allow outgoing
ufw allow ${RANDOM_SSH_PORT}/tcp
ufw allow 8006/tcp
ufw --force enable

echo ">>> Activating Fail2Ban Security Profiles..."
systemctl enable fail2ban --now

clear
echo "========================================================"
echo "          🎉 POST-INSTALLATION COMPLETE 🎉"
echo "========================================================"
echo ""
echo "  🔒 SECURITY CREDENTIALS GENERATED:"
echo "  ------------------------------------------------------"
echo "  SSH Port:        $RANDOM_SSH_PORT (Verified Uncommon)"
echo "  Root Password:   $RANDOM_ROOT_PW"
echo "  goazh Password:  $RANDOM_USER_PW"
echo ""
echo "  🚀 ACCESS COMMANDS:"
echo "  ------------------------------------------------------"
echo "  SSH Connection:  ssh -p $RANDOM_SSH_PORT goazh@your-server-ip"
echo "  Proxmox Web UI:  https://your-server-ip:8006"
echo ""
echo "========================================================"
echo " PLEASE SAVE THESE DETAILS IN YOUR PASSWORD MANAGER NOW!"
echo "========================================================"