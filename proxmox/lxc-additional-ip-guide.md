# Proxmox LXC Additional IP Configuration Guide

## Overview

This guide explains how to add additional IP addresses to LXC containers in Proxmox VE using hookscripts. This method ensures that additional IPs are automatically configured every time the container starts.

## Prerequisites

- Proxmox VE 9.x
- Root access to Proxmox host
- Basic understanding of Linux networking
- LXC container already created and configured

## Method 1: Single Container Hookscript

### Step 1: Create the Hookscript

Create a hookscript file for your specific container:

```bash
nano /var/lib/vz/snippets/container-[CONTAINER_ID]-post-start.sh
```

Replace `[CONTAINER_ID]` with your actual container ID (e.g., `container-102-post-start.sh`).

### Step 2: Add Script Content

```bash
#!/bin/bash

# Arguments from Proxmox
VMID="$1"
PHASE="$2"

echo "GUEST HOOK: $VMID $PHASE"

# Only run during post-start
if [ "$PHASE" != "post-start" ]; then
    exit 0
fi

# Network config
INTERFACE="eth0"

# List of additional IPs (add as many as you want)
ADDITIONAL_IPS=(
  "51.38.87.113/32"
)

echo "$VMID is in post-start phase, configuring additional IPs on $INTERFACE"

# Wait for container to be fully initialized
sleep 5

for IP in "${ADDITIONAL_IPS[@]}"; do
    BASE_IP="${IP%/*}"
    if ! pct exec "$VMID" -- ip addr show "$INTERFACE" | grep -qw "$BASE_IP"; then
        if pct exec "$VMID" -- ip addr add "$IP" dev "$INTERFACE"; then
            echo "✅ Successfully added $IP to $INTERFACE in container $VMID"
        else
            echo "❌ Failed to add $IP to $INTERFACE in container $VMID"
        fi
    else
        echo "ℹ️ $IP already exists on $INTERFACE in container $VMID"
    fi
done

exit 0
```

### Step 3: Make Script Executable

```bash
chmod +x /var/lib/vz/snippets/container-[CONTAINER_ID]-post-start.sh
```

### Step 4: Configure Container to Use Hookscript

**Option A: Using CLI**
```bash
pct set [CONTAINER_ID] --hookscript local:snippets/container-[CONTAINER_ID]-post-start.sh
```

**Option B: Manual Configuration**
```bash
nano /etc/pve/lxc/[CONTAINER_ID].conf
```

Add this line:
```
hookscript: local:snippets/container-[CONTAINER_ID]-post-start.sh
```

### Step 5: Test the Configuration

```bash
# Stop the container
pct stop [CONTAINER_ID]

# Start the container
pct start [CONTAINER_ID]

# Verify the IP was added
pct exec [CONTAINER_ID] -- ip addr show eth0
```

## Method 2: Universal Multi-Container Hookscript

For managing multiple containers with different additional IPs:

### Step 1: Create Universal Hookscript

```bash
nano /var/lib/vz/snippets/universal-ip-hook.sh
```

### Step 2: Add Universal Script Content

```bash
#!/bin/bash

VMID="$1"
PHASE="$2"

echo "GUEST HOOK: $VMID $PHASE"

# Only run during post-start phase
if [ "$PHASE" != "post-start" ]; then
    exit 0
fi

# Container-specific IP configuration
case $VMID in
    "100")
        ADDITIONAL_IP="192.168.1.100/24"
        ;;
    "101")
        ADDITIONAL_IP="192.168.1.101/24"
        ;;
    "102")
        ADDITIONAL_IP="51.38.87.113/32"
        ;;
    "103")
        ADDITIONAL_IP="51.38.87.114/32"
        ;;
    *)
        echo "No additional IP configured for container $VMID"
        exit 0
        ;;
esac

INTERFACE="eth0"

echo "$VMID started successfully, adding additional IP: $ADDITIONAL_IP"

# Wait for container networking to be ready
sleep 5

# Add the IP if it doesn't exist
if ! pct exec $VMID -- ip addr show $INTERFACE | grep -q "${ADDITIONAL_IP%/*}"; then
    if pct exec $VMID -- ip addr add $ADDITIONAL_IP dev $INTERFACE; then
        echo "Successfully added IP $ADDITIONAL_IP to container $VMID"
    else
        echo "Failed to add IP $ADDITIONAL_IP to container $VMID"
        exit 1
    fi
else
    echo "IP $ADDITIONAL_IP already exists on container $VMID"
fi

exit 0
```

### Step 3: Configure Multiple Containers

```bash
chmod +x /var/lib/vz/snippets/universal-ip-hook.sh

# Apply to multiple containers
pct set 100 --hookscript local:snippets/universal-ip-hook.sh
pct set 101 --hookscript local:snippets/universal-ip-hook.sh
pct set 102 --hookscript local:snippets/universal-ip-hook.sh
```

## Method 3: Configuration File-Based Approach

For easier management of IP assignments:

### Step 1: Create IP Configuration File

```bash
nano /etc/pve/container-ips.conf
```

Add container ID and IP mappings:
```
100:192.168.1.100/24
101:192.168.1.101/24,10.0.0.100/24
102:51.38.87.113/32
103:51.38.87.114/32
```

### Step 2: Create Dynamic Hookscript

```bash
nano /var/lib/vz/snippets/dynamic-ip-hook.sh
```

```bash
#!/bin/bash

VMID="$1"
PHASE="$2"
CONFIG_FILE="/etc/pve/container-ips.conf"
LOG_FILE="/var/log/proxmox-ip-hooks.log"

echo "GUEST HOOK: $VMID $PHASE"

if [ "$PHASE" != "post-start" ]; then
    exit 0
fi

# Wait for container to be ready
sleep 10

# Read IPs for this container from config file
IPS=$(grep "^$VMID:" "$CONFIG_FILE" | cut -d: -f2)

if [ -z "$IPS" ]; then
    echo "No additional IPs configured for container $VMID"
    exit 0
fi

# Add each IP (comma-separated)
IFS=',' read -ra IP_ARRAY <<< "$IPS"
for ip in "${IP_ARRAY[@]}"; do
    # Check if IP already exists
    if ! pct exec $VMID -- ip addr show eth0 | grep -q "${ip%/*}"; then
        if pct exec $VMID -- ip addr add $ip dev eth0; then
            echo "$(date): Added IP $ip to container $VMID" | tee -a $LOG_FILE
        else
            echo "$(date): Failed to add IP $ip to container $VMID" | tee -a $LOG_FILE
        fi
    else
        echo "$(date): IP $ip already exists on container $VMID" | tee -a $LOG_FILE
    fi
done

exit 0
```

## Troubleshooting

### Common Issues

1. **"RTNETLINK answers: File exists"**
   - IP is already assigned to the interface
   - Script includes IP checking to prevent this error

2. **Hook not executing**
   - Check script permissions: `chmod +x /var/lib/vz/snippets/your-script.sh`
   - Verify hookscript path in container config
   - Check Proxmox logs: `journalctl -u pve-container@[CONTAINER_ID]`

3. **Container not starting**
   - Check hookscript syntax: `bash -n /var/lib/vz/snippets/your-script.sh`
   - Review script for exit codes != 0

### Debugging Commands

```bash
# Check container configuration
pct config [CONTAINER_ID]

# View current IPs in container
pct exec [CONTAINER_ID] -- ip addr show

# Check Proxmox logs
journalctl -u pve-container@[CONTAINER_ID] -f

# Test hookscript manually
/var/lib/vz/snippets/your-script.sh [CONTAINER_ID] post-start

# View hook execution logs
tail -f /var/log/proxmox-ip-hooks.log
```

### Verification

After container start, verify the configuration:

```bash
# Check if additional IP is assigned
pct exec [CONTAINER_ID] -- ip addr show eth0

# Test connectivity from container
pct exec [CONTAINER_ID] -- ping -c 3 [GATEWAY_IP]

# Check routing table
pct exec [CONTAINER_ID] -- ip route show
```

## Important Notes

- **Hookscripts run as root** on the Proxmox host
- **Always test** hookscripts before production use
- **Use appropriate CIDR notation** (/32 for single IP, /24 for subnet)
- **Consider firewall rules** when adding new IPs
- **Backup container configs** before making changes
- **Sleep delay is crucial** to ensure container networking is ready

## Security Considerations

- Store hookscripts in `/var/lib/vz/snippets/` only
- Use proper file permissions (755 for scripts)
- Avoid hardcoding sensitive information
- Implement logging for audit trails
- Test scripts in development environment first

## Support

For additional help:
- Check Proxmox VE documentation
- Review `/usr/share/pve-docs/examples/guest-example-hookscript.pl`
- Consult Proxmox community forums