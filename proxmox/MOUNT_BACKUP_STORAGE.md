# 📦 OVH Backup Storage Mount Script

## 🚀 Quick Install

Run as root:

```bash
bash <(wget -qO- https://raw.githubusercontent.com/dipaksarkar/docs/refs/heads/master/proxmox/mount_backup.sh)
```

---

## 📝 Script: `proxmox/mount_backup.sh`

```bash
#!/bin/bash
set -e

BACKUP_IP="your-backup-ip"     # Replace with OVH Backup IP from dashboard
BACKUP_PATH="/export/backup"   # Usually provided by OVH
MOUNT_POINT="/mnt/ovhbackup"

echo ">>> Installing NFS client..."
apt update && apt install -y nfs-common

echo ">>> Creating mount point..."
mkdir -p $MOUNT_POINT

echo ">>> Mounting OVH Backup Storage..."
mount -t nfs $BACKUP_IP:$BACKUP_PATH $MOUNT_POINT

echo ">>> Adding to /etc/fstab for persistence..."
grep -qxF "$BACKUP_IP:$BACKUP_PATH $MOUNT_POINT nfs defaults,_netdev 0 0" /etc/fstab || \
echo "$BACKUP_IP:$BACKUP_PATH $MOUNT_POINT nfs defaults,_netdev 0 0" >> /etc/fstab

echo ">>> Backup storage mounted at $MOUNT_POINT"
df -h | grep $MOUNT_POINT
```

---

## 🔑 Setup Steps

1. Go to your OVH Manager → **Backup Storage**.

   * Note the **Backup IP** (example: `10.0.0.1`).
   * Note the **export path** (example: `/export/backup`).

2. Edit the script and update:

   ```bash
   BACKUP_IP="10.0.0.1"
   BACKUP_PATH="/export/backup"
   ```

3. Run the script.
   It will:

   * Install NFS client
   * Mount the storage
   * Add entry to `/etc/fstab` so it auto-mounts on reboot

4. Check mounted storage:

   ```bash
   df -h | grep ovhbackup
   ```

---

## 🎯 Usage with Proxmox

After mounting, you can add this backup storage into **Proxmox GUI**:

* Go to **Datacenter → Storage → Add → Directory**
* ID: `ovhbackup`
* Directory: `/mnt/ovhbackup`
* Content: `VZDump backup file`

Now Proxmox can store VM backups directly to OVH Backup Storage.

---

👉 Do you want me to also write an **extended version of this script** that directly registers the mounted path inside Proxmox storage configuration (`/etc/pve/storage.cfg`) automatically?
