#!/bin/bash
set -euo pipefail

# ==============================
# CONFIGURATION
# ==============================
STORAGE="local-lvm"           # Storage target for disks
BRIDGE="vmbr0"                # Default network bridge
MEM=2048                      # Default memory for template
CORES=2                       # Default CPU cores
DISK_SIZE="10G"               # Resize imported disk
ROOT_PASSWORD="ChangeMe123!"  # Default root password
SSH_KEY="$HOME/.ssh/id_rsa.pub" # Public SSH key for root
HOST_PREFIX="tpl"             # Hostname prefix for templates

# Templates (VMID, name, URL, description tag)
TEMPLATES=(
  "9000 debian-11 https://cloud.debian.org/images/cloud/bullseye/latest/debian-11-genericcloud-amd64.qcow2 Debian 11 Bullseye"
  "9001 debian-12 https://cloud.debian.org/images/cloud/bookworm/latest/debian-12-genericcloud-amd64.qcow2 Debian 12 Bookworm"
  "9002 ubuntu-22.04 https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img Ubuntu 22.04 Jammy"
  "9003 ubuntu-24.04 https://cloud-images.ubuntu.com/releases/noble/current/ubuntu-24.04-server-cloudimg-amd64.img Ubuntu 24.04 Noble"
)

# ==============================
# FUNCTIONS
# ==============================

create_template() {
  local VMID=$1; local NAME=$2; local URL=$3; local DESC=$4
  local IMG="/tmp/${NAME}.img"

  echo "==> Creating template: $NAME ($DESC) [VMID=$VMID]"

  # --- Download image ---
  wget -q -O "$IMG" "$URL"

  # --- Create VM shell ---
  qm create $VMID \
    --name "${NAME}-template" \
    --memory $MEM \
    --cores $CORES \
    --net0 virtio,bridge=$BRIDGE \
    --ostype l26 \
    --scsihw virtio-scsi-pci \
    --agent enabled=1 \
    --description "$DESC - CloudInit ready"

  # --- Import disk ---
  qm importdisk $VMID "$IMG" $STORAGE

  # --- Attach disk + CloudInit ---
  qm set $VMID --scsi0 $STORAGE:vm-${VMID}-disk-0
  qm set $VMID --boot c --bootdisk scsi0
  qm set $VMID --ide2 $STORAGE:cloudinit

  # --- Resize root disk ---
  qm resize $VMID scsi0 $DISK_SIZE

  # --- CloudInit defaults ---
  qm set $VMID --ciuser root --cipassword "$ROOT_PASSWORD"
  [ -f "$SSH_KEY" ] && qm set $VMID --sshkey "$SSH_KEY"
  qm set $VMID --ipconfig0 ip=dhcp
  qm set $VMID --ciupgrade 0
  qm set $VMID --tags "$NAME,cloudinit,template"

  # --- Convert to template ---
  qm template $VMID

  # --- Cleanup ---
  rm -f "$IMG"

  echo "--> Template $NAME ready (VMID=$VMID)"
}

# ==============================
# MAIN
# ==============================

for tpl in "${TEMPLATES[@]}"; do
  create_template $tpl
done

echo ""
echo "✅ All templates created successfully!"
qm list | grep template
