#!/bin/bash
# ==========================================
# Proxmox Multi-OS Cloud Template Builder
# Author: Dipak’s Senior Proxmox Engineer
# ==========================================

set -euo pipefail

# -----------------------------
# VMID counter start
# -----------------------------
VMID_BASE=9000

# -----------------------------
# Storage auto-detection
# -----------------------------
if pvesm status | grep -q "^local-lvm"; then
  STORAGE="local-lvm"
else
  STORAGE="local"
fi

echo "==> Using storage: $STORAGE"

# -----------------------------
# OS Images Library
# -----------------------------
IMAGES=(
  "debian-11|https://cloud.debian.org/images/cloud/bullseye/latest/debian-11-generic-amd64.qcow2"
  "debian-12|https://cloud.debian.org/images/cloud/bookworm/latest/debian-12-generic-amd64.qcow2"
  "ubuntu-2204|https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img"
  "ubuntu-2404|https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img"
  "rocky-9|https://download.rockylinux.org/pub/rocky/9/images/x86_64/Rocky-9-GenericCloud.latest.x86_64.qcow2"
  "almalinux-9|https://repo.almalinux.org/almalinux/9/cloud/x86_64/images/AlmaLinux-9-GenericCloud-latest.x86_64.qcow2"
)

# -----------------------------
# Build function
# -----------------------------
build_template() {
  local VMID=$1
  local ALIAS=$2
  local IMAGE_URL=$3
  local TMP_IMAGE="/tmp/${ALIAS}.qcow2"

  echo "=========================================="
  echo ">>> Building template $ALIAS ($VMID)"
  echo "=========================================="

  # Download image
  if [ ! -f "$TMP_IMAGE" ]; then
    echo "==> Downloading $ALIAS..."
    wget -O "$TMP_IMAGE" "$IMAGE_URL"
  else
    echo "==> Using cached image: $TMP_IMAGE"
  fi

  # Cleanup old VM if exists
  if qm status $VMID &>/dev/null; then
    echo "==> Removing old VM $VMID"
    qm destroy $VMID --purge
  fi

  # Create VM
  qm create $VMID --name "$ALIAS" --memory 2048 --cores 2 \
    --net0 virtio,bridge=vmbr0 \
    --ostype l26 \
    --agent enabled=1 \
    --bios ovmf --machine q35 \
    --scsihw virtio-scsi-pci

  # Import disk
  qm importdisk $VMID "$TMP_IMAGE" $STORAGE

  if [ "$STORAGE" == "local-lvm" ]; then
    qm set $VMID --scsi0 $STORAGE:vm-${VMID}-disk-0
  else
    qm set $VMID --scsi0 $STORAGE:${VMID}/vm-${VMID}-disk-0.qcow2
  fi

  # Boot settings
  qm set $VMID --boot c --bootdisk scsi0

  # Cloud-Init
  qm set $VMID --ide2 $STORAGE:cloudinit
  qm set $VMID --serial0 socket --vga serial0

  # Finalize template
  qm template $VMID
  echo "✅ Template $ALIAS ($VMID) ready!"
}

# -----------------------------
# Main loop
# -----------------------------
COUNT=0
for entry in "${IMAGES[@]}"; do
  ALIAS="${entry%%|*}"
  IMAGE_URL="${entry##*|}"
  VMID=$((VMID_BASE + COUNT))
  build_template $VMID $ALIAS $IMAGE_URL
  COUNT=$((COUNT + 1))
done

echo "🎉 All templates built successfully!"
