# Debian Cloud Image Setup in Proxmox - Complete Guide

## Table of Contents
1. [Initial VM Setup](#initial-vm-setup)
2. [Network Configuration](#network-configuration)
3. [Common Issues and Solutions](#common-issues-and-solutions)
4. [Troubleshooting Commands](#troubleshooting-commands)
5. [Best Practices](#best-practices)
6. [Alternative Configurations](#alternative-configurations)

## Initial VM Setup

### 1. Download and Prepare Cloud Image

```bash
# Download Debian cloud image
wget https://cloud.debian.org/images/cloud/bookworm/latest/debian-12-generic-amd64.qcow2

# Create VM in Proxmox
qm create 103 --name debian-cloud --memory 2048 --cores 2 --net0 virtio,bridge=vmbr0
qm importdisk 103 debian-12-generic-amd64.qcow2 local
qm set 103 --scsihw virtio-scsi-pci --scsi0 local:103/vm-103-disk-0.qcow2
qm set 103 --boot c --bootdisk scsi0
qm set 103 --serial0 socket --vga serial0
qm set 103 --agent enabled=1

# Configure cloud-init
qm set 103 --ide2 local:103/cloudinit,media=cdrom
qm set 103 --ciuser debian --cipassword your_password_here
```

### 2. Network Configuration Options

You have two main approaches for network configuration:

#### Option A: Cloud-init Managed (Recommended)
```bash
# Set IP configuration in Proxmox
qm set 103 --ipconfig0 ip=51.38.87.110/32,gw=51.89.234.254
```

#### Option B: Manual Configuration
```bash
# Don't set ipconfig0 in Proxmox for manual configuration
```

## Network Configuration

### Method 1: Cloud-init Approach (Recommended)

When using cloud-init, Proxmox automatically configures the network based on the `ipconfig0` parameter.

**Advantages:**
- Automatic configuration
- Consistent with cloud practices
- Easy to manage from Proxmox interface

**Requirements:**
- Keep systemd-networkd enabled
- Don't manually edit network files
- Let cloud-init handle everything

### Method 2: Manual Network Configuration

If you prefer manual control or cloud-init isn't working properly:

#### Step 1: Disable Cloud-init Networking
```bash
echo 'network: {config: disabled}' | sudo tee /etc/cloud/cloud.cfg.d/99-disable-network-config.cfg
sudo systemctl disable --now systemd-networkd
sudo systemctl mask systemd-networkd
```

#### Step 2: Configure Manual Networking
Create or edit `/etc/network/interfaces`:

```bash
sudo nano /etc/network/interfaces
```

**For Single IP:**
```bash
source /etc/network/interfaces.d/*

auto lo
iface lo inet loopback

auto eth0
iface eth0 inet static
    address 51.38.87.110/32
    post-up ip route add 51.89.234.254/32 dev eth0
    post-up ip route add default via 51.89.234.254 dev eth0
    dns-nameservers 8.8.8.8 8.8.4.4
```

**For Multiple IPs:**
```bash
source /etc/network/interfaces.d/*

auto lo
iface lo inet loopback

auto eth0
iface eth0 inet static
    address 51.38.87.110/32
    post-up ip route add 51.89.234.254/32 dev eth0
    post-up ip route add default via 51.89.234.254 dev eth0
    dns-nameservers 8.8.8.8 8.8.4.4

auto eth0:1
iface eth0:1 inet static
    address 51.38.87.113/32
```

#### Step 3: Configure DNS (Static Method)
```bash
sudo rm /etc/resolv.conf
sudo tee /etc/resolv.conf << EOF
nameserver 8.8.8.8
nameserver 8.8.4.4
nameserver 1.1.1.1
EOF

# Protect from overwrites
sudo chattr +i /etc/resolv.conf
```

#### Step 4: Apply Configuration
```bash
sudo systemctl restart networking
```

## Common Issues and Solutions

### Issue 1: "Network is unreachable" when pinging external IPs

**Symptoms:**
```bash
ping: connect: Network is unreachable
```

**Causes:**
- Missing or incorrect default route
- Gateway not reachable
- Wrong subnet mask

**Solutions:**

1. **Check current routes:**
```bash
ip route show
```

2. **Add missing routes manually:**
```bash
sudo ip route add 51.89.234.254/32 dev eth0
sudo ip route add default via 51.89.234.254 dev eth0
```

3. **For /32 networks, always add gateway as host route first:**
```bash
# Wrong - won't work with /32
gateway 51.89.234.254

# Correct - works with /32
post-up ip route add 51.89.234.254/32 dev eth0
post-up ip route add default via 51.89.234.254 dev eth0
```

### Issue 2: "Temporary failure in name resolution"

**Symptoms:**
```bash
ping: google.com: Temporary failure in name resolution
```

**Causes:**
- DNS not configured
- systemd-resolved conflicts
- Wrong nameservers

**Solutions:**

1. **Check DNS configuration:**
```bash
cat /etc/resolv.conf
```

2. **Static DNS fix (recommended):**
```bash
sudo rm /etc/resolv.conf
echo "nameserver 8.8.8.8" | sudo tee /etc/resolv.conf
echo "nameserver 8.8.4.4" | sudo tee -a /etc/resolv.conf
sudo chattr +i /etc/resolv.conf
```

3. **systemd-resolved fix:**
```bash
sudo mkdir -p /etc/systemd/resolved.conf.d
sudo tee /etc/systemd/resolved.conf.d/dns.conf << EOF
[Resolve]
DNS=8.8.8.8 8.8.4.4
FallbackDNS=1.1.1.1 1.0.0.1
EOF
sudo systemctl restart systemd-resolved
```

### Issue 3: "Failed to start networking.service"

**Symptoms:**
```bash
Job for networking.service failed because the control process exited with error code
```

**Causes:**
- Syntax errors in interfaces file
- Conflicting network managers
- Cloud-init interference

**Solutions:**

1. **Check configuration syntax:**
```bash
sudo ifup --no-act eth0
```

2. **Check for conflicts:**
```bash
systemctl status systemd-networkd
systemctl status networking
```

3. **View detailed errors:**
```bash
journalctl -xeu networking.service
```

4. **Clean restart:**
```bash
sudo systemctl stop networking systemd-networkd
sudo systemctl start networking
```

### Issue 4: Cloud-init and Manual Config Conflicts

**Symptoms:**
- Network works briefly then stops
- Configuration gets overwritten
- Mixed systemd-networkd/ifupdown issues

**Solutions:**

1. **Choose one approach - Cloud-init:**
```bash
# Remove manual configs
sudo rm -f /etc/network/interfaces.d/50-cloud-init
sudo systemctl unmask systemd-networkd
sudo systemctl enable systemd-networkd
sudo systemctl disable networking
sudo cloud-init clean --reboot
```

2. **Choose one approach - Manual:**
```bash
# Remove cloud-init networking in Proxmox
qm set 103 --delete ipconfig0

# Disable cloud-init networking
echo 'network: {config: disabled}' | sudo tee /etc/cloud/cloud.cfg.d/99-disable-network-config.cfg
sudo systemctl disable --now systemd-networkd
sudo systemctl mask systemd-networkd
```

## Troubleshooting Commands

### Network Diagnostics
```bash
# Check interfaces
ip addr show
ip link show

# Check routes
ip route show
ip route get 8.8.8.8

# Check connectivity
ping -c 3 8.8.8.8                    # Test IP connectivity
ping -c 3 google.com                 # Test DNS resolution
traceroute 8.8.8.8                   # Trace route to destination

# Check DNS
cat /etc/resolv.conf
nslookup google.com
dig google.com
```

### Service Status
```bash
# Check network services
systemctl status networking
systemctl status systemd-networkd
systemctl status systemd-resolved

# Check cloud-init status
cloud-init status
cloud-init analyze show
```

### Configuration Files
```bash
# View current configs
cat /etc/network/interfaces
cat /etc/netplan/*.yaml
cat /etc/systemd/network/*.network

# Check cloud-init network config
cat /etc/cloud/cloud.cfg.d/*network*
```

### Logs
```bash
# Network service logs
journalctl -u networking
journalctl -u systemd-networkd
journalctl -u systemd-resolved

# Cloud-init logs
journalctl -u cloud-init
cat /var/log/cloud-init.log
cat /var/log/cloud-init-output.log

# System logs
dmesg | grep -i network
tail -f /var/log/syslog
```

## Best Practices

### 1. Choose One Network Management Method
- **Cloud-init**: Best for standard cloud deployments
- **Manual**: Best for custom configurations or when cloud-init fails

### 2. Network Configuration
```bash
# Always use /32 for single IPs with specific gateway
address 51.38.87.110/32
post-up ip route add 51.89.234.254/32 dev eth0
post-up ip route add default via 51.89.234.254 dev eth0

# Use reliable DNS servers
dns-nameservers 8.8.8.8 8.8.4.4 1.1.1.1 1.0.0.1
```

### 3. DNS Configuration
```bash
# Protect static DNS from overwrites
sudo chattr +i /etc/resolv.conf

# To modify protected DNS file
sudo chattr -i /etc/resolv.conf
# Make changes
sudo chattr +i /etc/resolv.conf
```

### 4. Service Management
```bash
# Disable conflicting services
sudo systemctl mask systemd-networkd    # When using manual config
sudo systemctl disable networking       # When using cloud-init
```

## Alternative Configurations

### Using Netplan (Ubuntu-style)

If you prefer netplan configuration:

```bash
sudo apt install netplan.io
sudo tee /etc/netplan/50-cloud-init.yaml << EOF
network:
  version: 2
  ethernets:
    eth0:
      addresses: [51.38.87.110/32, 51.38.87.113/32]
      routes:
        - to: 51.89.234.254/32
          via: 0.0.0.0
          scope: link
        - to: default
          via: 51.89.234.254
      nameservers:
        addresses: [8.8.8.8, 8.8.4.4]
EOF

sudo netplan apply
```

### Using systemd-networkd Directly

Create `/etc/systemd/network/10-eth0.network`:

```bash
sudo tee /etc/systemd/network/10-eth0.network << EOF
[Match]
Name=eth0

[Network]
Address=51.38.87.110/32
Address=51.38.87.113/32
DNS=8.8.8.8
DNS=8.8.4.4

[Route]
Gateway=51.89.234.254
GatewayOnLink=true
EOF

sudo systemctl enable --now systemd-networkd
```

## Quick Reference Card

### Essential Commands
```bash
# Network status
ip a                                  # Show all interfaces
ip route                             # Show routing table
ping -c 3 8.8.8.8                   # Test connectivity
ping -c 3 google.com                # Test DNS

# Service management
sudo systemctl restart networking    # Restart traditional networking
sudo systemctl restart systemd-networkd  # Restart systemd networking

# DNS troubleshooting
cat /etc/resolv.conf                 # Check DNS config
nslookup google.com                  # Test DNS resolution

# Configuration files
/etc/network/interfaces              # Traditional network config
/etc/systemd/network/               # systemd-networkd config
/etc/netplan/                       # Netplan config
/etc/resolv.conf                    # DNS configuration
```

### Emergency Network Recovery
```bash
# Manual IP assignment
sudo ip addr add 51.38.87.110/32 dev eth0
sudo ip route add 51.89.234.254/32 dev eth0
sudo ip route add default via 51.89.234.254 dev eth0

# Manual DNS
echo "nameserver 8.8.8.8" | sudo tee /etc/resolv.conf
```

---

This guide covers the most common scenarios for Debian cloud images in Proxmox. Always test network changes carefully and keep console access available for recovery.