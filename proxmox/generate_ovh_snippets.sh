#!/bin/bash
# ==========================================
# OVH Cloud-Init Snippet Generator
# Generates network configs for Debian/Ubuntu
# ==========================================

set -e

SNIPPETS_DIR="/var/lib/vz/snippets"

# SSH Public Key (replace with yours)
SSH_KEY="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCbeYfOKRxq2SAc8WwyOrCdkTnD1Cct3CKLwgZQeh49Cw2oFTezIw+NaTAkhaw5RuYAOgSHWiAiZ+BdF+zIehIXWcwBB6UPZ+vh0V2XdMO6liVBA13ry9IsvAH2HMu1ZzxrD07JfzU5+HgcuoJofyL+dsBzgn6dp6Nvg6PUpCn5Mcoz0xYhomhCNQK4TnJEMbochXCj/wZJlJ+46OA8LMaseReN9jKVfobh4CxRqiP5kAnDY4SKCrGJY0BhXPxJulNPLy4gl/XHj9sP4R0JsJKaMNpID840i6oqPRCnMCqgAUvCm+s4t9aatdiYx4BfzYxV8bIzkbjJgpgIXJZ1gzdADj1unF8GiH0eGS69Y1TSeGsezLOld+DFSW+kDPklE8pvoMztyRVO+h8xqB2AHhV52d01/HR6Evgv5peshawltZygsCyOOui/7LsAOmPriLDQXO/p8pM7Wtda1hFF2Ym6qVCI4xa7fJMJ6EM2nM3oYMHhpcu8oL6ntt2WCFEU5FpsqHjFqdByDnkI1WmzBOaQKC5zgFNr0N0RIpCCFTS/o/2Kn/28WNIPAobognqwxMvQbMWlT5ZCYM+QPZxLCWc77xtLlgUxqqBlHALQvLPjrlA+JJY2FELYayPa//cYKWMGcQObs8xuac1jCeZL53fTiktiHJhOOzWYHooJehqw1Q== dipak@Dipaks-iMac.local"

generate_debian_snippet() {
  local IPS="$1"
  local GATEWAY="$2"
  local OUTPUT_FILE="$3"

  # Split IPs into array
  IFS=',' read -ra IP_ARRAY <<< "$IPS"
  
  # Primary IP (first one)
  PRIMARY_IP="${IP_ARRAY[0]}"
  
  # Use a more generic interface pattern that works with both eth0 and ens18
  # Build interfaces config
  INTERFACES_CONFIG="auto lo
iface lo inet loopback

# Primary network interface - auto-detected
auto ens18
iface ens18 inet static
    address $PRIMARY_IP
    netmask 255.255.255.255
    gateway $GATEWAY
    pointopoint $GATEWAY
    dns-nameservers 8.8.8.8 1.1.1.1

# Fallback for eth0 naming
auto eth0
iface eth0 inet static
    address $PRIMARY_IP
    netmask 255.255.255.255
    gateway $GATEWAY
    pointopoint $GATEWAY
    dns-nameservers 8.8.8.8 1.1.1.1"

  # Add additional IPs as aliases for ens18
  local ALIAS_NUM=1
  for i in "${IP_ARRAY[@]:1}"; do
    INTERFACES_CONFIG="$INTERFACES_CONFIG

iface ens18 inet static
    address $i
    netmask 255.255.255.255
    pointopoint $GATEWAY
    label ens18:$ALIAS_NUM

iface eth0 inet static
    address $i
    netmask 255.255.255.255
    pointopoint $GATEWAY
    label eth0:$ALIAS_NUM"
    ((ALIAS_NUM++))
  done

  cat > "$OUTPUT_FILE" << EOF
#cloud-config
users:
  - name: debian
    gecos: Debian User
    sudo: ALL=(ALL) NOPASSWD:ALL
    shell: /bin/bash
    lock_passwd: false
    passwd: \$6\$rounds=4096\$salt\$encrypted_password_hash
    ssh_authorized_keys:
      - $SSH_KEY
write_files:
  - path: /etc/network/interfaces
    content: |
$(echo "$INTERFACES_CONFIG" | sed 's/^/      /')
    permissions: '0644'
  - path: /etc/resolv.conf
    content: |
      nameserver 8.8.8.8
      nameserver 1.1.1.1
    permissions: '0644'
  - path: /etc/cloud/cloud.cfg.d/99-disable-network-config.cfg
    content: |
      network: {config: disabled}
    permissions: '0644'
runcmd:
  - systemctl stop systemd-resolved || true
  - systemctl disable systemd-resolved || true
  - systemctl mask systemd-networkd || true
  - systemctl mask systemd-networkd-wait-online.service || true
  - systemctl restart networking || true
EOF
}

generate_ubuntu_snippet() {
  local IPS="$1"
  local GATEWAY="$2"
  local OUTPUT_FILE="$3"

  # Split IPs into array
  IFS=',' read -ra IP_ARRAY <<< "$IPS"
  
  # Build addresses array for netplan
  ADDRESSES=""
  for ip in "${IP_ARRAY[@]}"; do
    ADDRESSES="$ADDRESSES              - $ip/32\n"
  done

  cat > "$OUTPUT_FILE" << EOF
#cloud-config
users:
  - name: ubuntu
    gecos: Ubuntu User
    sudo: ALL=(ALL) NOPASSWD:ALL
    shell: /bin/bash
    lock_passwd: false
    passwd: \$6\$rounds=4096\$salt\$encrypted_password_hash
    ssh_authorized_keys:
      - $SSH_KEY
write_files:
  - path: /etc/netplan/01-ovh-network.yaml
    content: |
      network:
        version: 2
        ethernets:
          # Configure both possible interface names
          ens18:
            optional: true
            dhcp4: false
            addresses:
$(echo -e "$ADDRESSES")
            nameservers:
              addresses: [8.8.8.8, 1.1.1.1]
            routes:
              - to: 0.0.0.0/0
                via: $GATEWAY
                on-link: true
          eth0:
            optional: true
            dhcp4: false
            addresses:
$(echo -e "$ADDRESSES")
            nameservers:
              addresses: [8.8.8.8, 1.1.1.1]
            routes:
              - to: 0.0.0.0/0
                via: $GATEWAY
                on-link: true
    permissions: '0600'
  - path: /etc/cloud/cloud.cfg.d/99-disable-network-config.cfg
    content: |
      network: {config: disabled}
    permissions: '0644'
runcmd:
  - netplan apply
EOF
}

usage() {
  echo "Usage: $0 [debian|ubuntu] <ip1,ip2,ip3> <gateway> [output_file]"
  echo ""
  echo "Examples:"
  echo "  $0 debian 51.38.87.110,51.38.87.111 51.89.234.254"
  echo "  $0 ubuntu 51.38.87.110 51.89.234.254 custom-config.yml"
  echo ""
  echo "Generated snippets will be saved to $SNIPPETS_DIR/"
  exit 1
}

main() {
  local OS_TYPE="$1"
  local IPS="$2"
  local GATEWAY="$3"
  local OUTPUT_FILE="$4"

  # Validate input
  if [[ -z "$OS_TYPE" || -z "$IPS" || -z "$GATEWAY" ]]; then
    usage
  fi

  # Create snippets directory if it doesn't exist
  mkdir -p "$SNIPPETS_DIR"

  # Set default output filename if not provided
  if [[ -z "$OUTPUT_FILE" ]]; then
    OUTPUT_FILE="ovh-${OS_TYPE}-$(echo $IPS | tr ',' '-').yml"
  fi

  local FULL_PATH="$SNIPPETS_DIR/$OUTPUT_FILE"

  case "$OS_TYPE" in
    debian)
      generate_debian_snippet "$IPS" "$GATEWAY" "$FULL_PATH"
      echo ">>> Debian snippet generated: $FULL_PATH"
      ;;
    ubuntu)
      generate_ubuntu_snippet "$IPS" "$GATEWAY" "$FULL_PATH"
      echo ">>> Ubuntu snippet generated: $FULL_PATH"
      ;;
    *)
      echo "Error: Unsupported OS type '$OS_TYPE'. Use 'debian' or 'ubuntu'."
      exit 1
      ;;
  esac

  echo ">>> To use this snippet:"
  echo "    qm set <VMID> --cicustom \"user=local:snippets/$OUTPUT_FILE\""
  echo "    qm cloudinit update <VMID>"
  echo "    qm start <VMID>"
}

main "$@"
