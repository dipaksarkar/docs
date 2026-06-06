#!/bin/bash

set -euo pipefail

echo "========================================="
echo " OVH Backup Storage Mount for Proxmox"
echo "========================================="
echo

# Check root

if [[ $EUID -ne 0 ]]; then
echo "Please run as root."
exit 1
fi

# Install dependencies

echo ">>> Installing NFS client..."
apt-get update -qq
apt-get install -y nfs-common >/dev/null

echo

read -rp "OVH Backup Storage Name (e.g. ftpback-rbx2-195.ovh.net): " BACKUP_HOST
read -rp "OVH Backup Storage ID (e.g. ns31202431.ip-51-89-234.eu): " BACKUP_ID

read -rp "Mount Point [/mnt/ovhbackup]: " MOUNT_POINT
MOUNT_POINT=${MOUNT_POINT:-/mnt/ovhbackup}

read -rp "Proxmox Storage ID [ovhbackup]: " STORAGE_ID
STORAGE_ID=${STORAGE_ID:-ovhbackup}

BACKUP_PATH="/export/ftpbackup/${BACKUP_ID}"

echo
echo "Configuration"
echo "-----------------------------------------"
echo "Host       : $BACKUP_HOST"
echo "Path       : $BACKUP_PATH"
echo "Mount Point: $MOUNT_POINT"
echo "Storage ID : $STORAGE_ID"
echo

read -rp "Continue? (y/N): " CONFIRM

if [[ ! "$CONFIRM" =~ ^[Yy]$ ]]; then
echo "Cancelled."
exit 0
fi

echo
echo ">>> Creating mount point..."
mkdir -p "$MOUNT_POINT"

# Unmount old mount if present

if mountpoint -q "$MOUNT_POINT"; then
echo ">>> Existing mount detected."
else
echo ">>> Mounting OVH Backup Storage..."
mount -t nfs -o vers=3,nolock "$BACKUP_HOST:$BACKUP_PATH" "$MOUNT_POINT"
fi

# Verify mount

if ! mountpoint -q "$MOUNT_POINT"; then
echo "ERROR: Mount failed."
exit 1
fi

echo ">>> Mounted successfully."

# Add fstab entry

FSTAB_ENTRY="$BACKUP_HOST:$BACKUP_PATH $MOUNT_POINT nfs vers=3,nolock,_netdev 0 0"

if grep -qF "$BACKUP_HOST:$BACKUP_PATH" /etc/fstab; then
echo ">>> fstab entry already exists."
else
echo "$FSTAB_ENTRY" >> /etc/fstab
echo ">>> Added to /etc/fstab."
fi

# Register storage in Proxmox

if command -v pvesm >/dev/null 2>&1; then
    if grep -q "^dir: $STORAGE_ID\$" /etc/pve/storage.cfg 2>/dev/null; then
        echo ">>> Proxmox storage '$STORAGE_ID' already exists."
    else
        echo ">>> Registering storage in Proxmox..."
        pvesm add dir "$STORAGE_ID" \
            --path "$MOUNT_POINT" \
            --content backup
        echo ">>> Storage '$STORAGE_ID' added."
    fi
else
echo ">>> Proxmox not detected. Skipping storage registration."
fi

echo
echo "========================================="
echo " SUCCESS"
echo "========================================="
echo

df -h "$MOUNT_POINT"

echo
echo "Storage Name : $STORAGE_ID"
echo "Mount Point  : $MOUNT_POINT"
echo

echo "You can now create backup jobs from:"
echo "Datacenter -> Backup -> Add"
echo
echo "Or verify storage with:"
echo "pvesm status"