#!/bin/bash
# ==========================================
# Proxmox Multi-OS Cloud Template Builder
# Author: Dipak’s Senior Proxmox Engineer
# ==========================================

set -e

# Where to store temporary qcow2 images
TMP_DIR="/tmp"

# Storage to use for disks
STORAGE="local"

# Network bridge to use
BRIDGE="vmbr0"

# Template definitions (VMID, NAME, IMAGE_URL, OS_TYPE)
TEMPLATES=(
  "9000 debian-12-base https://cloud.debian.org/images/cloud/bookworm/latest/debian-12-genericcloud-amd64.qcow2 debian"
  "9001 ubuntu-2204-base https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img ubuntu"
  "9002 ubuntu-2404-base https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img ubuntu"
  "9003 almalinux-9-base https://repo.almalinux.org/almalinux/9/cloud/x86_64/images/AlmaLinux-9-GenericCloud-latest.x86_64.qcow2 centos"
  "9004 rockylinux-9-base https://dl.rockylinux.org/pub/rocky/9/images/x86_64/Rocky-9-GenericCloud.latest.x86_64.qcow2 centos"
)

create_template() {
  local VMID="$1"
  local NAME="$2"
  local URL="$3"
  local OSTYPE="$4"

  echo "=== Creating template $NAME ($VMID) ==="

  # Remove existing VM if it exists
  if qm status $VMID &>/dev/null; then
    echo ">>> VM $VMID already exists. Removing..."
    qm destroy $VMID --purge || true
  fi

  # Download image
  IMG_FILE="$TMP_DIR/${URL##*/}"
  if [ ! -f "$IMG_FILE" ]; then
    echo ">>> Downloading $URL ..."
    wget -O "$IMG_FILE" "$URL"
  else
    echo ">>> Image already exists: $IMG_FILE"
  fi

  # Create VM
  qm create $VMID --name "$NAME" --ostype $OSTYPE \
    --memory 2048 --cores 2 --cpu host \
    --net0 virtio,bridge=$BRIDGE

  # Import disk
  echo ">>> Importing disk..."
  qm importdisk $VMID "$IMG_FILE" $STORAGE --format qcow2

  # Attach disk
  qm set $VMID --scsihw virtio-scsi-pci --scsi0 ${STORAGE}:vm-${VMID}-disk-0

  # Boot settings
  qm set $VMID --boot c --bootdisk scsi0

  # Cloud-init drive
  qm set $VMID --ide2 ${STORAGE}:cloudinit
  qm set $VMID --serial0 socket --vga serial0

  # Ballooning
  qm set $VMID --balloon 0

  # Convert to template
  qm template $VMID

  echo ">>> Template $NAME ($VMID) created successfully."
}

# Loop through templates
for entry in "${TEMPLATES[@]}"; do
  create_template $entry
done

# Cleanup
echo ">>> Cleaning up downloaded images..."
rm -f $TMP_DIR/*.qcow2 $TMP_DIR/*.img

echo "=== All templates created successfully! ==="
