#!/bin/bash
# ==========================================
# Proxmox OVH-Ready Cloud Template Builder
# Author: Senior Proxmox Engineer
# Version: 2.0 - OVH Optimized
# ==========================================

set -e

# === CONFIG ===
STORAGE="local"       # change to local-lvm if you prefer
BRIDGE="vmbr0"
TMP_DIR="/tmp"
SNIPPETS_DIR="/var/lib/vz/snippets"

# SSH public key for templates (replace with yours)
SSH_KEY="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCbeYfOKRxq2SAc8WwyOrCdkTnD1Cct3CKLwgZQeh49Cw2oFTezIw+NaTAkhaw5RuYAOgSHWiAiZ+BdF+zIehIXWcwBB6UPZ+vh0V2XdMO6liVBA13ry9IsvAH2HMu1ZzxrD07JfzU5+HgcuoJofyL+dsBzgn6dp6Nvg6PUpCn5Mcoz0xYhomhCNQK4TnJEMbochXCj/wZJlJ+46OA8LMaseReN9jKVfobh4CxRqiP5kAnDY4SKCrGJY0BhXPxJulNPLy4gl/XHj9sP4R0JsJKaMNpID840i6oqPRCnMCqgAUvCm+s4t9aatdiYx4BfzYxV8bIzkbjJgpgIXJZ1gzdADj1unF8GiH0eGS69Y1TSeGsezLOld+DFSW+kDPklE8pvoMztyRVO+h8xqB2AHhV52d01/HR6Evgv5peshawltZygsCyOOui/7LsAOmPriLDQXO/p8pM7Wtda1hFF2Ym6qVCI4xa7fJMJ6EM2nM3oYMHhpcu8oL6ntt2WCFEU5FpsqHjFqdByDnkI1WmzBOaQKC5zgFNr0N0RIpCCFTS/o/2Kn/28WNIPAobognqwxMvQbMWlT5ZCYM+QPZxLCWc77xtLlgUxqqBlHALQvLPjrlA+JJY2FELYayPa//cYKWMGcQObs8xuac1jCeZL53fTiktiHJhOOzWYHooJehqw1Q== dipak@Dipaks-iMac.local"

# Template definitions: VMID, NAME, URL, FILE, OSTYPE
IMAGES=(
  "7000 debian-12-base https://cloud.debian.org/images/cloud/bookworm/latest/debian-12-genericcloud-amd64.qcow2 /tmp/debian-12.qcow2 l26"
  "7001 debian-11-base https://cloud.debian.org/images/cloud/bullseye/latest/debian-11-genericcloud-amd64.qcow2 /tmp/debian-11.qcow2 l26"
  "7002 ubuntu-22.04-base https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img /tmp/ubuntu-22.04.img l26"
  "7003 ubuntu-24.04-base https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img /tmp/ubuntu-24.04.img l26"
  "7004 rocky-9-base https://download.rockylinux.org/pub/rocky/9/images/x86_64/Rocky-9-GenericCloud.latest.x86_64.qcow2 /tmp/rocky-9.qcow2 l26"
  "7005 almalinux-9-base https://repo.almalinux.org/almalinux/9/cloud/x86_64/images/AlmaLinux-9-GenericCloud-latest.x86_64.qcow2 /tmp/almalinux-9.qcow2 l26"
  "7006 centos-9-base https://cloud.centos.org/centos/9-stream/x86_64/images/CentOS-Stream-GenericCloud-9-latest.x86_64.qcow2 /tmp/centos-9.qcow2 l26"
)

# === FUNCTIONS ===
create_ovh_ready_snippet() {
  local OS_NAME="$1"
  local SNIPPET_FILE="$SNIPPETS_DIR/ovh-template-${OS_NAME}.yml"
  
  echo ">>> Creating OVH-ready snippet for $OS_NAME..."
  mkdir -p "$SNIPPETS_DIR"

  if [[ "$OS_NAME" =~ debian ]]; then
    cat > "$SNIPPET_FILE" << 'EOF'
#cloud-config
# OVH-Ready Debian Template
# Network will be configured via custom snippets during VM deployment
packages:
  - ifupdown
  - cloud-init
write_files:
  - path: /etc/cloud/cloud.cfg.d/99-disable-network-config.cfg
    content: |
      network: {config: disabled}
    permissions: '0644'
  - path: /etc/network/interfaces
    content: |
      # Placeholder - will be replaced during VM deployment
      auto lo
      iface lo inet loopback
    permissions: '0644'
runcmd:
  - systemctl mask systemd-networkd || true
  - systemctl mask systemd-networkd-wait-online.service || true
  - systemctl stop systemd-resolved || true
  - systemctl disable systemd-resolved || true
EOF
  elif [[ "$OS_NAME" =~ ubuntu ]]; then
    cat > "$SNIPPET_FILE" << 'EOF'
#cloud-config
# OVH-Ready Ubuntu Template  
# Network will be configured via custom snippets during VM deployment
write_files:
  - path: /etc/cloud/cloud.cfg.d/99-disable-network-config.cfg
    content: |
      network: {config: disabled}
    permissions: '0644'
  - path: /etc/netplan/01-placeholder.yaml
    content: |
      # Placeholder - will be replaced during VM deployment
      network:
        version: 2
        ethernets:
          eth0:
            dhcp4: true
    permissions: '0600'
runcmd:
  - netplan apply
EOF
  else
    # RHEL-based systems
    cat > "$SNIPPET_FILE" << 'EOF'
#cloud-config
# OVH-Ready RHEL Template
write_files:
  - path: /etc/cloud/cloud.cfg.d/99-disable-network-config.cfg
    content: |
      network: {config: disabled}
    permissions: '0644'
EOF
  fi
  
  echo ">>> Snippet created: $SNIPPET_FILE"
}

create_template() {
  VMID=$1
  NAME=$2
  URL=$3
  FILE=$4
  OSTYPE=$5

  echo "=== Creating OVH-ready template $NAME ($VMID) ==="

  # Remove old VM if exists
  if qm status $VMID &>/dev/null; then
      echo ">>> VM $VMID already exists. Removing..."
      qm stop $VMID --skiplock --force &>/dev/null || true
      qm destroy $VMID --purge --skiplock || true
  fi

  # Download image if missing
  if [ ! -f "$FILE" ]; then
      echo ">>> Downloading image for $NAME ..."
      wget -O "$FILE" "$URL" || {
        echo "Error: Failed to download $URL"
        return 1
      }
  else
      echo ">>> Using cached image: $FILE"
  fi

  # Verify image file
  if [ ! -s "$FILE" ]; then
    echo "Error: Downloaded file is empty or corrupted"
    rm -f "$FILE"
    return 1
  fi

  # Create VM shell with OVH-optimized settings
  echo ">>> Creating VM $VMID..."
  qm create $VMID --name $NAME --ostype $OSTYPE \
    --memory 2048 --cores 2 --cpu host \
    --net0 virtio,bridge=$BRIDGE \
    --scsihw virtio-scsi-pci \
    --agent enabled=1

  # Import disk
  echo ">>> Importing disk for $NAME ..."
  qm importdisk $VMID "$FILE" $STORAGE --format qcow2

  # Handle storage type for disk attachment
  if [ "$STORAGE" == "local-lvm" ]; then
      qm set $VMID --scsi0 $STORAGE:vm-$VMID-disk-0
  else
      qm set $VMID --scsi0 $STORAGE:$VMID/vm-$VMID-disk-0.qcow2
  fi

  # Cloud-init drive
  qm set $VMID --ide2 $STORAGE:cloudinit

  # Boot settings optimized for OVH
  qm set $VMID --boot c --bootdisk scsi0 
  qm set $VMID --serial0 socket --vga serial0
  
  # Memory optimization
  qm set $VMID --balloon 0

  # Basic cloud-init config for template
  qm set $VMID --ciuser root
  qm set $VMID --cipassword $(openssl passwd -6 "changeme123") 2>/dev/null || echo ">>> Using default password"
  
  # Create OVH-ready snippet for this template
  create_ovh_ready_snippet "$NAME"

  # Convert to template
  qm template $VMID
  
  echo "=== ✅ Template $NAME ($VMID) ready for OVH deployment ==="
  echo ">>> Default login: root / changeme123"
  echo ">>> SSH key location: Update SSH_KEY variable in deployment scripts"
}

# === MAIN LOOP ===
echo "🚀 Starting OVH-Ready Template Creation..."
echo "📁 Snippets will be stored in: $SNIPPETS_DIR"
echo "💾 Storage: $STORAGE | Bridge: $BRIDGE"
echo ""

FAILED_TEMPLATES=()
SUCCESSFUL_TEMPLATES=()

for IMAGE in "${IMAGES[@]}"; do
  if create_template $IMAGE; then
    TEMPLATE_NAME=$(echo $IMAGE | cut -d' ' -f2)
    SUCCESSFUL_TEMPLATES+=("$TEMPLATE_NAME")
  else
    TEMPLATE_NAME=$(echo $IMAGE | cut -d' ' -f2)
    FAILED_TEMPLATES+=("$TEMPLATE_NAME")
    echo "❌ Failed to create template: $TEMPLATE_NAME"
  fi
  echo ""
done

# Cleanup downloaded images
echo "🧹 Cleaning up downloaded images..."
rm -f $TMP_DIR/*.qcow2 $TMP_DIR/*.img

# Summary
echo "======================================"
echo "📊 TEMPLATE CREATION SUMMARY"
echo "======================================"
echo "✅ Successful templates: ${#SUCCESSFUL_TEMPLATES[@]}"
for template in "${SUCCESSFUL_TEMPLATES[@]}"; do
  echo "   - $template"
done

if [ ${#FAILED_TEMPLATES[@]} -gt 0 ]; then
  echo ""
  echo "❌ Failed templates: ${#FAILED_TEMPLATES[@]}"
  for template in "${FAILED_TEMPLATES[@]}"; do
    echo "   - $template"
  done
fi

echo ""
echo "🎯 Next Steps:"
echo "1. Update SSH_KEY in deployment scripts with your public key"
echo "2. Use deploy_ovh_vm.sh to create VMs with OVH failover IPs"
echo "3. Templates are ready for OVH network configuration"
echo ""
echo "💡 Example VM deployment:"
echo "   ./deploy_ovh_vm.sh 7000 100 web-server debian 51.38.87.110 51.89.234.254"