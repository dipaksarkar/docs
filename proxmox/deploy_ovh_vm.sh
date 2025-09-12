#!/bin/bash
# ==========================================
# OVH VM Deployment Automation
# Clone template + assign IPs + start VM
# ==========================================

set -e

# Default values
DEFAULT_STORAGE="local"
DEFAULT_BRIDGE="vmbr0"

deploy_vm() {
  local TEMPLATE_ID="$1"
  local NEW_VMID="$2"
  local VM_NAME="$3"
  local OS_TYPE="$4"
  local IPS="$5"
  local GATEWAY="$6"
  local MAC_ADDRESS="$7"
  local MEMORY="${8:-2048}"
  local CORES="${9:-2}"

  echo "=== Deploying VM: $VM_NAME ($NEW_VMID) ==="

  # Check if template exists
  if ! qm status "$TEMPLATE_ID" &>/dev/null; then
    echo "Error: Template $TEMPLATE_ID does not exist!"
    exit 1
  fi

  # Remove existing VM if it exists
  if qm status "$NEW_VMID" &>/dev/null; then
    echo ">>> VM $NEW_VMID already exists. Removing..."
    qm stop "$NEW_VMID" || true
    sleep 2
    qm destroy "$NEW_VMID" --purge || true
  fi

  # Clone the template
  echo ">>> Cloning template $TEMPLATE_ID to $NEW_VMID..."
  qm clone "$TEMPLATE_ID" "$NEW_VMID" --name "$VM_NAME"

  # Update VM settings
  echo ">>> Configuring VM settings..."
  qm set "$NEW_VMID" --memory "$MEMORY" --cores "$CORES"

  # Set MAC address for OVH failover IP
  if [[ -n "$MAC_ADDRESS" ]]; then
    echo ">>> Setting MAC address: $MAC_ADDRESS"
    qm set "$NEW_VMID" --net0 "virtio,bridge=$DEFAULT_BRIDGE,macaddr=$MAC_ADDRESS"
  fi

  # Generate and apply Cloud-Init snippet
  echo ">>> Generating Cloud-Init network configuration..."
  local SNIPPET_NAME="ovh-${VM_NAME}-$(date +%s).yml"
  
  # Use the snippet generator
  ./generate_ovh_snippets.sh "$OS_TYPE" "$IPS" "$GATEWAY" "$SNIPPET_NAME"

  # Apply the snippet
  echo ">>> Applying Cloud-Init configuration..."
  qm set "$NEW_VMID" --cicustom "user=local:snippets/$SNIPPET_NAME"
  qm cloudinit update "$NEW_VMID"

  # Start the VM
  echo ">>> Starting VM..."
  qm start "$NEW_VMID"

  echo "=== VM $VM_NAME ($NEW_VMID) deployed successfully! ==="
  echo ">>> IPs assigned: $IPS"
  echo ">>> Gateway: $GATEWAY"
  echo ">>> MAC: ${MAC_ADDRESS:-"auto-generated"}"
  echo ">>> Cloud-Init snippet: $SNIPPET_NAME"
  echo ""
  echo ">>> SSH access (once booted):"
  for ip in $(echo "$IPS" | tr ',' ' '); do
    echo "    ssh ${OS_TYPE}@${ip}"
  done
}

usage() {
  echo "Usage: $0 <template_id> <new_vmid> <vm_name> <os_type> <ip1,ip2,...> <gateway> [mac_address] [memory] [cores]"
  echo ""
  echo "Parameters:"
  echo "  template_id    - Source template VMID (e.g., 7000 for debian-11-base)"
  echo "  new_vmid       - New VM ID (e.g., 100)"
  echo "  vm_name        - VM name (e.g., web-server-01)"
  echo "  os_type        - OS type: debian or ubuntu"
  echo "  ips            - Comma-separated failover IPs (e.g., 51.38.87.110,51.38.87.111)"
  echo "  gateway        - OVH gateway IP (e.g., 51.89.234.254)"
  echo "  mac_address    - OVH virtual MAC (optional)"
  echo "  memory         - RAM in MB (default: 2048)"
  echo "  cores          - CPU cores (default: 2)"
  echo ""
  echo "Templates available:"
  echo "  7000 - debian-11-base"
  echo "  7001 - debian-12-base"
  echo "  7002 - ubuntu-22.04-base"
  echo "  7003 - ubuntu-24.04-base"
  echo ""
  echo "Examples:"
  echo "  # Single IP Debian 12 VM"
  echo "  $0 7001 100 web-server debian 51.38.87.110 51.89.234.254 02:00:00:c0:4f:2c"
  echo ""
  echo "  # Multiple IPs Ubuntu 22.04 VM"
  echo "  $0 7002 101 app-server ubuntu 51.38.87.110,51.38.87.111 51.89.234.254 02:00:00:c0:4f:2d"
  echo ""
  echo "  # High-spec VM with 4 cores and 8GB RAM"
  echo "  $0 7001 102 db-server debian 51.38.87.112 51.89.234.254 02:00:00:c0:4f:2e 8192 4"
  exit 1
}

main() {
  local TEMPLATE_ID="$1"
  local NEW_VMID="$2"
  local VM_NAME="$3"
  local OS_TYPE="$4"
  local IPS="$5"
  local GATEWAY="$6"
  local MAC_ADDRESS="$7"
  local MEMORY="$8"
  local CORES="$9"

  # Validate required parameters
  if [[ -z "$TEMPLATE_ID" || -z "$NEW_VMID" || -z "$VM_NAME" || -z "$OS_TYPE" || -z "$IPS" || -z "$GATEWAY" ]]; then
    usage
  fi

  # Validate OS type
  if [[ "$OS_TYPE" != "debian" && "$OS_TYPE" != "ubuntu" ]]; then
    echo "Error: OS type must be 'debian' or 'ubuntu'"
    exit 1
  fi

  # Check if snippet generator exists
  if [[ ! -f "./generate_ovh_snippets.sh" ]]; then
    echo "Error: generate_ovh_snippets.sh not found in current directory"
    exit 1
  fi

  deploy_vm "$TEMPLATE_ID" "$NEW_VMID" "$VM_NAME" "$OS_TYPE" "$IPS" "$GATEWAY" "$MAC_ADDRESS" "$MEMORY" "$CORES"
}

main "$@"
