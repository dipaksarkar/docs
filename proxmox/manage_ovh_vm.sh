#!/bin/bash
# ==========================================
# OVH VM Management Script
# Manage IPs and configurations
# ==========================================

set -e

add_ip_to_vm() {
  local VMID="$1"
  local NEW_IP="$2"
  local GATEWAY="$3"
  local MAC_ADDRESS="$4"

  echo "=== Adding IP $NEW_IP to VM $VMID ==="

  # Get VM info
  local VM_NAME=$(qm config "$VMID" | grep "^name:" | cut -d' ' -f2)
  local OS_TYPE
  
  # Detect OS type from VM name or ask user
  if [[ "$VM_NAME" =~ debian ]]; then
    OS_TYPE="debian"
  elif [[ "$VM_NAME" =~ ubuntu ]]; then
    OS_TYPE="ubuntu"
  else
    echo ">>> Cannot auto-detect OS type from VM name '$VM_NAME'"
    read -p "Enter OS type (debian/ubuntu): " OS_TYPE
  fi

  # Get current Cloud-Init snippet if exists
  local CURRENT_SNIPPET=$(qm config "$VMID" | grep "cicustom:" | cut -d'=' -f2 | cut -d',' -f1 | sed 's/local:snippets\///')
  
  if [[ -n "$CURRENT_SNIPPET" ]]; then
    echo ">>> Found existing snippet: $CURRENT_SNIPPET"
    # Parse existing IPs from snippet
    local EXISTING_IPS=$(grep -A 20 "addresses:" "/var/lib/vz/snippets/$CURRENT_SNIPPET" | grep -E "^\s*-\s*[0-9.]+" | sed 's/.*- //' | sed 's|/32||' | tr '\n' ',' | sed 's/,$//')
    
    if [[ -z "$EXISTING_IPS" ]]; then
      # Try Debian format
      EXISTING_IPS=$(grep -E "^\s*address\s+[0-9.]+" "/var/lib/vz/snippets/$CURRENT_SNIPPET" | awk '{print $2}' | tr '\n' ',' | sed 's/,$//')
    fi
    
    local ALL_IPS="$EXISTING_IPS,$NEW_IP"
    echo ">>> Current IPs: $EXISTING_IPS"
    echo ">>> All IPs will be: $ALL_IPS"
  else
    echo ">>> No existing snippet found, creating new one"
    local ALL_IPS="$NEW_IP"
  fi

  # Generate new snippet
  local NEW_SNIPPET="ovh-${VM_NAME}-updated-$(date +%s).yml"
  ./generate_ovh_snippets.sh "$OS_TYPE" "$ALL_IPS" "$GATEWAY" "$NEW_SNIPPET"

  # Update MAC if provided
  if [[ -n "$MAC_ADDRESS" ]]; then
    echo ">>> Updating MAC address: $MAC_ADDRESS"
    qm set "$VMID" --net0 "virtio,bridge=vmbr0,macaddr=$MAC_ADDRESS"
  fi

  # Apply new configuration
  echo ">>> Applying new configuration..."
  qm set "$VMID" --cicustom "user=local:snippets/$NEW_SNIPPET"
  qm cloudinit update "$VMID"

  echo ">>> IP $NEW_IP added successfully!"
  echo ">>> Reboot VM to apply changes: qm reboot $VMID"
}

remove_ip_from_vm() {
  local VMID="$1"
  local REMOVE_IP="$2"
  local GATEWAY="$3"

  echo "=== Removing IP $REMOVE_IP from VM $VMID ==="

  local VM_NAME=$(qm config "$VMID" | grep "^name:" | cut -d' ' -f2)
  local CURRENT_SNIPPET=$(qm config "$VMID" | grep "cicustom:" | cut -d'=' -f2 | cut -d',' -f1 | sed 's/local:snippets\///')

  if [[ -z "$CURRENT_SNIPPET" ]]; then
    echo "Error: No Cloud-Init snippet found for VM $VMID"
    exit 1
  fi

  # Detect OS type
  local OS_TYPE
  if [[ "$VM_NAME" =~ debian ]]; then
    OS_TYPE="debian"
  elif [[ "$VM_NAME" =~ ubuntu ]]; then
    OS_TYPE="ubuntu"
  else
    read -p "Enter OS type (debian/ubuntu): " OS_TYPE
  fi

  # Get existing IPs and remove the specified one
  local EXISTING_IPS
  if [[ "$OS_TYPE" == "ubuntu" ]]; then
    EXISTING_IPS=$(grep -A 20 "addresses:" "/var/lib/vz/snippets/$CURRENT_SNIPPET" | grep -E "^\s*-\s*[0-9.]+" | sed 's/.*- //' | sed 's|/32||' | tr '\n' ',' | sed 's/,$//')
  else
    EXISTING_IPS=$(grep -E "^\s*address\s+[0-9.]+" "/var/lib/vz/snippets/$CURRENT_SNIPPET" | awk '{print $2}' | tr '\n' ',' | sed 's/,$//')
  fi

  # Remove the IP from the list
  local NEW_IPS=$(echo "$EXISTING_IPS" | sed "s/$REMOVE_IP,//g" | sed "s/,$REMOVE_IP//g" | sed "s/^$REMOVE_IP$//g")

  if [[ -z "$NEW_IPS" ]]; then
    echo "Error: Cannot remove all IPs from VM. At least one IP is required."
    exit 1
  fi

  echo ">>> Remaining IPs: $NEW_IPS"

  # Generate new snippet
  local NEW_SNIPPET="ovh-${VM_NAME}-updated-$(date +%s).yml"
  ./generate_ovh_snippets.sh "$OS_TYPE" "$NEW_IPS" "$GATEWAY" "$NEW_SNIPPET"

  # Apply new configuration
  qm set "$VMID" --cicustom "user=local:snippets/$NEW_SNIPPET"
  qm cloudinit update "$VMID"

  echo ">>> IP $REMOVE_IP removed successfully!"
  echo ">>> Reboot VM to apply changes: qm reboot $VMID"
}

list_vm_ips() {
  local VMID="$1"

  echo "=== VM $VMID IP Configuration ==="

  local VM_NAME=$(qm config "$VMID" | grep "^name:" | cut -d' ' -f2)
  local CURRENT_SNIPPET=$(qm config "$VMID" | grep "cicustom:" | cut -d'=' -f2 | cut -d',' -f1 | sed 's/local:snippets\///')

  echo "VM Name: $VM_NAME"
  echo "Snippet: ${CURRENT_SNIPPET:-"None"}"

  if [[ -n "$CURRENT_SNIPPET" && -f "/var/lib/vz/snippets/$CURRENT_SNIPPET" ]]; then
    echo "Configured IPs:"
    
    # Try Ubuntu format first
    local IPS=$(grep -A 20 "addresses:" "/var/lib/vz/snippets/$CURRENT_SNIPPET" 2>/dev/null | grep -E "^\s*-\s*[0-9.]+" | sed 's/.*- //' | sed 's|/32||')
    
    if [[ -z "$IPS" ]]; then
      # Try Debian format
      IPS=$(grep -E "^\s*address\s+[0-9.]+" "/var/lib/vz/snippets/$CURRENT_SNIPPET" | awk '{print $2}')
    fi

    if [[ -n "$IPS" ]]; then
      echo "$IPS" | while read -r ip; do
        echo "  - $ip"
      done
    else
      echo "  No IPs found in snippet"
    fi

    # Show gateway
    local GATEWAY=$(grep -E "(gateway|via):" "/var/lib/vz/snippets/$CURRENT_SNIPPET" | head -1 | awk '{print $2}')
    echo "Gateway: ${GATEWAY:-"Not found"}"
  else
    echo "No network configuration found"
  fi
}

usage() {
  echo "Usage: $0 <command> [options]"
  echo ""
  echo "Commands:"
  echo "  add-ip <vmid> <new_ip> <gateway> [mac_address]"
  echo "    Add a new IP to an existing VM"
  echo ""
  echo "  remove-ip <vmid> <remove_ip> <gateway>"
  echo "    Remove an IP from an existing VM"
  echo ""
  echo "  list-ips <vmid>"
  echo "    Show current IP configuration for a VM"
  echo ""
  echo "Examples:"
  echo "  $0 add-ip 100 51.38.87.111 51.89.234.254 02:00:00:c0:4f:2d"
  echo "  $0 remove-ip 100 51.38.87.111 51.89.234.254"
  echo "  $0 list-ips 100"
  exit 1
}

main() {
  local COMMAND="$1"

  case "$COMMAND" in
    add-ip)
      add_ip_to_vm "$2" "$3" "$4" "$5"
      ;;
    remove-ip)
      remove_ip_from_vm "$2" "$3" "$4"
      ;;
    list-ips)
      list_vm_ips "$2"
      ;;
    *)
      usage
      ;;
  esac
}

main "$@"
