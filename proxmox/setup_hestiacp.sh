#!/bin/bash
# Bash script to create a Proxmox LXC container and install HestiaCP

# -------- CONFIGURATION --------
CTID=200
HOSTNAME="hestiacp.local"
PASSWORD="YourStrongPassword"
STORAGE="local-lvm"
TEMPLATE="local:vztmpl/debian-12-standard_12.0-1_amd64.tar.zst"
MEMORY=2048     # RAM in MB
CORES=2
DISK=30         # GB
IP="192.168.1.200/24"
GATEWAY="192.168.1.1"

# -------- CREATE LXC --------
echo "[+] Creating LXC container $CTID..."
pct create $CTID $TEMPLATE \
    -hostname $HOSTNAME \
    -password $PASSWORD \
    -storage $STORAGE \
    -net0 name=eth0,bridge=vmbr0,ip=$IP,gw=$GATEWAY \
    -cores $CORES \
    -memory $MEMORY \
    -rootfs $STORAGE:$DISK \
    -features nesting=1

# -------- START LXC --------
echo "[+] Starting LXC container..."
pct start $CTID
sleep 10

# -------- INSTALL HESTIA --------
echo "[+] Installing HestiaCP inside LXC..."
pct exec $CTID -- bash -c "
    apt update && apt upgrade -y &&
    apt install -y wget curl &&
    wget https://raw.githubusercontent.com/hestiacp/hestiacp/release/install/hst-install.sh &&
    bash hst-install.sh --interactive no --email admin@$HOSTNAME --password $PASSWORD --hostname $HOSTNAME
"

echo "[✓] HestiaCP LXC ($CTID) is ready!"
echo "Login URL: https://$IP:8083"
echo "Username: admin"
echo "Password: $PASSWORD"
