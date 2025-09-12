#!/bin/bash
# qmip: Proxmox VM IP Manager Script

NAMESERVERS="8.8.8.8,1.1.1.1"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }
log_debug() { echo -e "${BLUE}[DEBUG]${NC} $1"; }

function usage() {
    echo "Usage: $0 <command> [args]"
    echo "Commands:"
    echo "  list <VMID>                        List all IPs assigned to VM"
    echo "  dump <VMID>                        Show full network config (snippet or cloud-init dump)"
    echo "  add <VMID> <IP_ADDRESS> <GATEWAY>  Add an IP address to VM"
    echo "  remove <VMID> [IP_ADDRESS]         Remove an IP address from VM (interactive if no IP given)"
    echo "  clean <VMID>                       Remove all custom network config and revert to default"
    echo "  validate <VMID>                    Validate network configuration"
    echo "  help                               Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 list 103"
    echo "  $0 add 103 192.168.1.100/24 192.168.1.1"
    echo "  $0 remove 103 192.168.1.100/24"
    echo "  $0 remove 103                      # Interactive mode"
}

# Validation functions
validate_vmid() {
    local VMID="$1"
    if ! [[ "$VMID" =~ ^[0-9]+$ ]]; then
        log_error "Invalid VMID: $VMID (must be numeric)"
        return 1
    fi
    if ! qm config "$VMID" >/dev/null 2>&1; then
        log_error "VM $VMID does not exist or is not accessible"
        return 1
    fi
    return 0
}

validate_ip() {
    local IP="$1"
    # Basic IP/CIDR validation
    if ! [[ "$IP" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+/[0-9]+$ ]]; then
        log_error "Invalid IP format: $IP (expected format: x.x.x.x/xx)"
        return 1
    fi
    return 0
}

validate_gateway() {
    local GW="$1"
    if ! [[ "$GW" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        log_error "Invalid gateway format: $GW (expected format: x.x.x.x)"
        return 1
    fi
    return 0
}

function get_snippet_file() {
    echo "$1/network.yaml"
}

function list_ips() {
    local VMID="$1"
    validate_vmid "$VMID" || return 1
    
    local SNIPPET_FILE=$(get_snippet_file "$VMID")
    if [ -f "$SNIPPET_FILE" ]; then
        log_info "IPs configured via custom snippet:"
        grep -E '^\s*-\s+[0-9]+(\.[0-9]+){3}/[0-9]+' "$SNIPPET_FILE" | sed 's/^\s*-\s*/  • /' || echo "  No IPs found."
        # Also show gateway
        local GATEWAY=$(grep -E 'gateway4:|via:' "$SNIPPET_FILE" | head -1 | awk '{print $2}')
        if [ -n "$GATEWAY" ]; then
            echo "  Gateway: $GATEWAY"
        fi
    else
        local IPCONFIG=$(qm config "$VMID" | grep ipconfig0 | awk -F'ipconfig0: ' '{print $2}')
        if [[ "$IPCONFIG" =~ ip=([^,]+),gw=([^,]+) ]]; then
            log_info "IPs configured via ipconfig0:"
            echo "  • ${BASH_REMATCH[1]}"
            echo "  Gateway: ${BASH_REMATCH[2]}"
        else
            log_warn "No IPs configured for VM $VMID"
        fi
    fi
}

function dump_config() {
    local VMID="$1"
    validate_vmid "$VMID" || return 1
    
    local SNIPPET_FILE=$(get_snippet_file "$VMID")
    if [ -f "$SNIPPET_FILE" ]; then
        log_info "Custom Network Config: $SNIPPET_FILE"
        cat "$SNIPPET_FILE"
    else
        log_info "Cloud-Init Network Configuration for VM $VMID"
        if ! qm cloudinit dump "$VMID" network 2>/dev/null; then
            log_warn "No network configuration found"
            # Show basic VM config
            local IPCONFIG=$(qm config "$VMID" | grep ipconfig0)
            if [ -n "$IPCONFIG" ]; then
                echo "VM Config: $IPCONFIG"
            fi
        fi
    fi
}

function validate_config() {
    local VMID="$1"
    validate_vmid "$VMID" || return 1
    
    local SNIPPET_FILE=$(get_snippet_file "$VMID")
    if [ -f "$SNIPPET_FILE" ]; then
        log_info "Validating custom network config..."
        if ! python3 -c "import yaml; yaml.safe_load(open('$SNIPPET_FILE'))" 2>/dev/null; then
            log_error "Invalid YAML syntax in $SNIPPET_FILE"
            return 1
        fi
        local IP_COUNT=$(grep -cE '^\s*-\s+[0-9]+(\.[0-9]+){3}/[0-9]+' "$SNIPPET_FILE")
        log_info "Found $IP_COUNT IP addresses in configuration"
        if [ "$IP_COUNT" -eq 0 ]; then
            log_warn "No IP addresses found in configuration"
        fi
    else
        log_info "Using default cloud-init configuration"
        local IPCONFIG=$(qm config "$VMID" | grep ipconfig0)
        if [ -n "$IPCONFIG" ]; then
            log_info "VM has ipconfig0: $IPCONFIG"
        else
            log_warn "VM has no network configuration"
        fi
    fi
}

function clean_config() {
    local VMID="$1"
    validate_vmid "$VMID" || return 1
    
    local SNIPPET_FILE=$(get_snippet_file "$VMID")
    if [ -f "$SNIPPET_FILE" ]; then
        log_warn "Removing custom network config and reverting to default..."
        read -p "Are you sure? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            qm set "$VMID" --delete cicustom
            rm -f "$SNIPPET_FILE"
            qm cloudinit update "$VMID"
            log_info "Custom network config removed. VM will use default cloud-init configuration."
        else
            log_info "Operation cancelled."
        fi
    else
        log_warn "No custom network config found for VM $VMID"
    fi
}

function add_ip() {
    local VMID="$1"
    local IP="$2"
    local GW="$3"
    
    validate_vmid "$VMID" || return 1
    validate_ip "$IP" || return 1
    validate_gateway "$GW" || return 1
    
    local SNIPPET_FILE=$(get_snippet_file "$VMID")
    
    if [ ! -f "$SNIPPET_FILE" ]; then
        local IPCONFIG=$(qm config "$VMID" | grep ipconfig0 | awk -F'ipconfig0: ' '{print $2}')
        if [ -z "$IPCONFIG" ]; then
            log_info "Setting primary IP using ipconfig0..."
            if qm set "$VMID" --ipconfig0 "ip=$IP,gw=$GW"; then
                log_info "Successfully set primary IP: $IP"
            else
                log_error "Failed to set primary IP"
                return 1
            fi
            return
        else
            if [[ "$IPCONFIG" =~ ip=([^,]+),gw=([^,]+) ]]; then
                local EXISTING_IP="${BASH_REMATCH[1]}"
                local EXISTING_GW="${BASH_REMATCH[2]}"
                log_info "Creating custom network config with $EXISTING_IP and $IP..."
                
                # Create snippet directory if it doesn't exist
                mkdir -p "/var/lib/vz/$VMID"
                
                cat > "$SNIPPET_FILE" <<EOF
version: 2
ethernets:
  eth0:
    dhcp4: no
    addresses:
      - $EXISTING_IP
      - $IP
    gateway4: $EXISTING_GW
    nameservers:
      addresses: [${NAMESERVERS//,/, }]
EOF
                if qm set "$VMID" --cicustom "network=local:snippets/network-$VMID.yaml" && qm cloudinit update "$VMID"; then
                    log_info "Successfully created custom network config with both IPs"
                else
                    log_error "Failed to apply custom network config"
                    rm -f "$SNIPPET_FILE"
                    return 1
                fi
                return
            fi
        fi
    else
        # Check if IP already exists (exact match)
        if grep -Fxq "      - $IP" "$SNIPPET_FILE"; then
            log_warn "IP $IP already present in configuration"
            return 0
        fi
        
        log_info "Adding $IP to existing custom network config..."
        # Create backup
        cp "$SNIPPET_FILE" "${SNIPPET_FILE}.backup"
        
        # Find the line with "addresses:" and add the IP after it
        if awk -v ip="      - $IP" '
        /^[[:space:]]*addresses:[[:space:]]*$/ { 
            print; 
            print ip; 
            next 
        } 
        { print }
        ' "$SNIPPET_FILE" > "${SNIPPET_FILE}.tmp" && mv "${SNIPPET_FILE}.tmp" "$SNIPPET_FILE"; then
            if qm cloudinit update "$VMID"; then
                log_info "Successfully added $IP to configuration"
                rm -f "${SNIPPET_FILE}.backup"
            else
                log_error "Failed to update cloud-init, restoring backup"
                mv "${SNIPPET_FILE}.backup" "$SNIPPET_FILE"
                return 1
            fi
        else
            log_error "Failed to update configuration file"
            mv "${SNIPPET_FILE}.backup" "$SNIPPET_FILE"
            return 1
        fi
    fi
}

function remove_ip() {
    local VMID="$1"
    local IP="$2"
    
    validate_vmid "$VMID" || return 1
    
    local SNIPPET_FILE=$(get_snippet_file "$VMID")
    if [ ! -f "$SNIPPET_FILE" ]; then
        log_error "No custom network config found for VM $VMID"
        return 1
    fi
    
    # If no IP specified, show interactive menu
    if [ -z "$IP" ]; then
        log_info "Available IPs to remove:"
        local IPS=($(grep -E '^\s*-\s+[0-9]+(\.[0-9]+){3}/[0-9]+' "$SNIPPET_FILE" | sed 's/^\s*-\s*//'))
        if [ ${#IPS[@]} -eq 0 ]; then
            log_warn "No IPs found in configuration"
            return 1
        fi
        
        for i in "${!IPS[@]}"; do
            echo "  $((i+1)). ${IPS[i]}"
        done
        echo "  0. Cancel"
        
        read -p "Select IP to remove (1-${#IPS[@]}): " -n 1 -r
        echo
        
        if [[ $REPLY =~ ^[0-9]+$ ]] && [ "$REPLY" -gt 0 ] && [ "$REPLY" -le "${#IPS[@]}" ]; then
            IP="${IPS[$((REPLY-1))]}"
            log_info "Selected: $IP"
        else
            log_info "Operation cancelled"
            return 0
        fi
    fi
    
    validate_ip "$IP" || return 1
    
    # Create backup
    cp "$SNIPPET_FILE" "${SNIPPET_FILE}.backup"
    
    # Remove the IP line using fixed string matching
    if grep -v "^[[:space:]]*-[[:space:]]*${IP}[[:space:]]*$" "$SNIPPET_FILE" > "${SNIPPET_FILE}.tmp" && mv "${SNIPPET_FILE}.tmp" "$SNIPPET_FILE"; then
        # Count remaining IPs
        local COUNT=$(grep -cE '^\s*-\s+[0-9]+(\.[0-9]+){3}/[0-9]+' "$SNIPPET_FILE")
        if [ "$COUNT" -lt 2 ]; then
            log_warn "Less than 2 IPs remaining, removing custom config and reverting to default"
            if qm set "$VMID" --delete cicustom && rm -f "$SNIPPET_FILE"; then
                log_info "Successfully removed custom network config"
                rm -f "${SNIPPET_FILE}.backup"
            else
                log_error "Failed to remove custom config, restoring backup"
                mv "${SNIPPET_FILE}.backup" "$SNIPPET_FILE"
                return 1
            fi
        else
            if qm cloudinit update "$VMID"; then
                log_info "Successfully removed $IP from configuration ($COUNT IPs remaining)"
                rm -f "${SNIPPET_FILE}.backup"
            else
                log_error "Failed to update cloud-init, restoring backup"
                mv "${SNIPPET_FILE}.backup" "$SNIPPET_FILE"
                return 1
            fi
        fi
    else
        log_error "Failed to remove IP from configuration"
        mv "${SNIPPET_FILE}.backup" "$SNIPPET_FILE"
        return 1
    fi
}

case "$1" in
    list)
        [ -z "$2" ] && { log_error "VMID required"; usage; exit 1; }
        list_ips "$2"
        ;;
    dump)
        [ -z "$2" ] && { log_error "VMID required"; usage; exit 1; }
        dump_config "$2"
        ;;
    add)
        [ -z "$2" ] || [ -z "$3" ] || [ -z "$4" ] && { log_error "Missing arguments"; usage; exit 1; }
        add_ip "$2" "$3" "$4"
        ;;
    remove)
        [ -z "$2" ] && { log_error "VMID required"; usage; exit 1; }
        remove_ip "$2" "$3"  # IP is optional for interactive mode
        ;;
    clean)
        [ -z "$2" ] && { log_error "VMID required"; usage; exit 1; }
        clean_config "$2"
        ;;
    validate)
        [ -z "$2" ] && { log_error "VMID required"; usage; exit 1; }
        validate_config "$2"
        ;;
    help|--help|-h)
        usage
        ;;
    *)
        log_error "Unknown command: $1"
        usage
        exit 1
        ;;
esac