# OVH Proxmox Automation Scripts

Complete automation suite for managing OVH failover IPs with Proxmox VE 8/9. No manual in-VM configuration required!

## 🚀 Quick Start

1. **Create base templates** (do once per OS):
   ```bash
   chmod +x cloud_templates.sh
   ./cloud_templates.sh
   ```

2. **Deploy a VM with failover IPs**:
   ```bash
   chmod +x deploy_ovh_vm.sh generate_ovh_snippets.sh
   ./deploy_ovh_vm.sh 7001 100 web-server debian 51.38.87.110 51.89.234.254 02:00:00:c0:4f:2c
   ```

3. **Deploy a VM with failover IPs**:
   ```bash
   chmod +x deploy_ovh_vm.sh generate_ovh_snippets.sh
   ./deploy_ovh_vm.sh 7001 103 app-server debian 51.38.87.110,51.38.87.113 51.89.234.254 02:00:00:c0:4f:2d
   ```

4. **Manage IPs on existing VMs**:
   ```bash
   chmod +x manage_ovh_vm.sh
   ./manage_ovh_vm.sh add-ip 100 51.38.87.111 51.89.234.254
   ```

## 📁 Scripts Overview

| Script | Purpose |
|--------|---------|
| `cloud_templates.sh` | Creates base templates for Debian 11/12, Ubuntu 22.04/24.x |
| `generate_ovh_snippets.sh` | Generates Cloud-Init snippets for network config |
| `deploy_ovh_vm.sh` | Clones template + assigns IPs + starts VM |
| `manage_ovh_vm.sh` | Add/remove IPs from existing VMs |

## 🛠 Prerequisites

### 1. OVH Setup
- Order your failover IPs from OVH
- Generate virtual MAC addresses for each IP in OVH panel
- Note your server's gateway IP (usually x.x.x.254)

### 2. Proxmox Setup
```bash
# Ensure snippets directory exists
mkdir -p /var/lib/vz/snippets

# Update SSH key in scripts (replace with yours)
sed -i 's/ssh-rsa AAAAB3NzaC1yc2E.*/YOUR_SSH_KEY_HERE/' generate_ovh_snippets.sh
```

## 📋 Detailed Usage

### 1. Create Base Templates

```bash
./cloud_templates.sh
```

**Creates:**
- `7000` - debian-11-base
- `7001` - debian-12-base  
- `7002` - ubuntu-22.04-base
- `7003` - ubuntu-24.04-base
- `7004` - rocky-9-base
- `7005` - almalinux-9-base
- `7006` - centos-9-base

### 2. Deploy VMs

#### Single IP VM
```bash
./deploy_ovh_vm.sh 7001 100 web-server debian 51.38.87.110 51.89.234.254 02:00:00:c0:4f:2c
```

#### Multiple IPs VM
```bash
./deploy_ovh_vm.sh 7001 101 app-server debian 51.38.87.110,51.38.87.111,51.38.87.112 51.89.234.254 02:00:00:c0:4f:2d
```

#### High-spec VM (8GB RAM, 4 cores)
```bash
./deploy_ovh_vm.sh 7001 102 db-server debian 51.38.87.113 51.89.234.254 02:00:00:c0:4f:2e 8192 4
```

### 3. Manage Existing VMs

#### Add IP to VM
```bash
./manage_ovh_vm.sh add-ip 100 51.38.87.111 51.89.234.254 02:00:00:c0:4f:2d
```

#### Remove IP from VM
```bash
./manage_ovh_vm.sh remove-ip 100 51.38.87.111 51.89.234.254
```

#### List VM IPs
```bash
./manage_ovh_vm.sh list-ips 100
```

### 4. Generate Cloud-Init Snippets Only

#### Debian snippet with multiple IPs
```bash
./generate_ovh_snippets.sh debian 51.38.87.110,51.38.87.111 51.89.234.254
```

#### Ubuntu snippet with single IP
```bash
./generate_ovh_snippets.sh ubuntu 51.38.87.110 51.89.234.254 custom-name.yml
```

## 🔧 Common Operations

### Start VM after deployment
```bash
qm start 100
```

### Check VM status
```bash
qm status 100
```

### View VM console
```bash
qm terminal 100
```

### SSH to VM (once booted)
```bash
ssh debian@51.38.87.110  # Debian VMs
ssh ubuntu@51.38.87.110  # Ubuntu VMs
```

### Reboot VM to apply network changes
```bash
qm reboot 100
```

## 📝 Network Configuration Examples

### Generated Debian Config (`/etc/network/interfaces`)
```bash
auto lo
iface lo inet loopback

auto eth0
iface eth0 inet static
    address 51.38.87.110
    netmask 255.255.255.255
    gateway 51.89.234.254
    pointopoint 51.89.234.254
    dns-nameservers 8.8.8.8 1.1.1.1

iface eth0 inet static
    address 51.38.87.111
    netmask 255.255.255.255
    pointopoint 51.89.234.254
    label eth0:1
```

### Generated Ubuntu Config (`/etc/netplan/01-ovh-network.yaml`)
```yaml
network:
  version: 2
  ethernets:
    eth0:
      dhcp4: false
      addresses:
        - 51.38.87.110/32
        - 51.38.87.111/32
      nameservers:
        addresses: [8.8.8.8, 1.1.1.1]
      routes:
        - to: 0.0.0.0/0
          via: 51.89.234.254
          on-link: true
```

## 🎯 Best Practices

1. **Always use OVH virtual MAC** for each failover IP
2. **Never manually edit network config inside VMs** - use these scripts
3. **Keep one primary IP per VM** for management
4. **Reboot VMs after IP changes** to ensure config is applied
5. **Backup your Cloud-Init snippets** for reproducibility

## 🔍 Troubleshooting

### VM won't start after deployment
```bash
# Check VM config
qm config 100

# Check Cloud-Init logs
qm terminal 100
# Then inside VM: journalctl -u cloud-init
```

### Network not working
```bash
# Check generated snippet
cat /var/lib/vz/snippets/ovh-*.yml

# Verify MAC address matches OVH panel
qm config 100 | grep net0
```

### Cloud-Init fails
```bash
# Regenerate Cloud-Init ISO
qm cloudinit update 100

# Check Cloud-Init status inside VM
cloud-init status --long
```

## 📚 Additional Resources

- [OVH Network Bridging Guide](https://help.ovhcloud.com/csm/en-dedicated-servers-network-bridging)
- [Proxmox Cloud-Init Documentation](https://pve.proxmox.com/pve-docs/chapter-qm.html#qm_cloud_init)
- [OVH Virtual MAC Documentation](https://help.ovhcloud.com/csm/en-dedicated-servers-network-virtual-mac)

## 🚨 Important Notes

- **Failover IPs require /32 netmask** and special gateway configuration
- **Each failover IP needs its own virtual MAC** from OVH panel
- **VMs must be on the same bridge** as the host's public interface (usually `vmbr0`)
- **Network changes require VM reboot** to take effect
- **Always test SSH access** after deploying new VMs

---

**Author:** Senior Proxmox & OVH Infrastructure Expert  
**Version:** 2024.1 - Proxmox VE 8/9 Compatible
