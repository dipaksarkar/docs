# Proxmox Cloud-Init Automation Setup Guide

## Overview
This guide shows how to replicate professional VPS provider automation in Proxmox using cloud-init snippets, making VM deployment as automated as commercial cloud providers.

## Table of Contents
1. [Understanding Cloud-Init Datasources](#understanding-cloud-init-datasources)
2. [Setting Up Snippets Storage](#setting-up-snippets-storage)
3. [Creating Cloud-Init Templates](#creating-cloud-init-templates)
4. [Network Configuration Automation](#network-configuration-automation)
5. [Complete Automation Examples](#complete-automation-examples)
6. [Advanced Configurations](#advanced-configurations)

## Understanding Cloud-Init Datasources

Your VPS provider uses a **NoCloud** datasource that automatically configures:
- Network interfaces with multiple IPs
- DNS settings
- IPv6 configuration
- Multiple aliases per interface

We'll replicate this in Proxmox using cloud-init snippets.

## Setting Up Snippets Storage

### 1. Create Snippets Directory
```bash
# On Proxmox host
mkdir -p /var/lib/vz/snippets
chmod 755 /var/lib/vz/snippets
```

### 2. Configure Storage for Snippets
Edit `/etc/pve/storage.cfg` and add or modify local storage:

```bash
dir: local
        path /var/lib/vz
        content vztmpl,iso,snippets
        shared 0
```

Or via Web UI: **Datacenter → Storage → local → Edit → Content → Add "Snippets"**

## Creating Cloud-Init Templates

### Basic Network Template

Create `/var/lib/vz/snippets/network-basic.yml`:

```yaml
#cloud-config
# Basic network configuration template
network:
  version: 2
  ethernets:
    eth0:
      addresses:
        - ${IP_ADDRESS}/${NETMASK}
      gateway4: ${GATEWAY}
      nameservers:
        addresses:
          - 1.1.1.1
          - 1.0.0.1
          - 8.8.8.8
          - 8.8.4.4
        search: []

users:
  - name: ${USERNAME}
    sudo: ['ALL=(ALL) NOPASSWD:ALL']
    shell: /bin/bash
    lock_passwd: false
    passwd: ${PASSWORD_HASH}
    ssh_authorized_keys: ${SSH_KEYS}

package_update: true
package_upgrade: false

packages:
  - curl
  - wget
  - vim
  - htop
  - net-tools
  - dnsutils

runcmd:
  - systemctl enable --now systemd-resolved
  - systemctl restart systemd-networkd
```

### Multi-IP Network Template

Create `/var/lib/vz/snippets/network-multi-ip.yml`:

```yaml
#cloud-config
# Multi-IP network configuration matching VPS provider style
network:
  version: 2
  ethernets:
    eth0:
      addresses:
        - ${PRIMARY_IP}/${NETMASK}
        - ${SECONDARY_IP}/${NETMASK}
      gateway4: ${GATEWAY}
      nameservers:
        addresses:
          - 1.1.1.1
          - 1.0.0.1
          - 2620:0:ccc::2
          - 2620:0:ccd::2
        search: []

users:
  - name: ${USERNAME}
    sudo: ['ALL=(ALL) NOPASSWD:ALL']
    shell: /bin/bash
    lock_passwd: false
    passwd: ${PASSWORD_HASH}

write_files:
  - path: /etc/cloud/cloud.cfg.d/99-custom-network.cfg
    content: |
      # Custom network configuration
      datasource_list: [ NoCloud, None ]
      datasource:
        NoCloud:
          fs_label: null
    permissions: '0644'

package_update: true
packages:
  - curl
  - wget
  - vim
  - htop
  - net-tools
  - dnsutils
  - iputils-ping

runcmd:
  - systemctl restart systemd-networkd
  - systemctl restart systemd-resolved
  - echo "Network configured successfully" > /var/log/cloud-init-network.log
```

### Advanced Template with IPv6

Create `/var/lib/vz/snippets/network-ipv6.yml`:

```yaml
#cloud-config
# IPv6 + IPv4 multi-IP configuration
network:
  version: 2
  ethernets:
    eth0:
      addresses:
        - ${PRIMARY_IP}/${NETMASK}
        - ${SECONDARY_IP}/${NETMASK}
        - ${IPV6_ADDRESS}/${IPV6_PREFIX}
      gateway4: ${GATEWAY}
      gateway6: ${IPV6_GATEWAY}
      nameservers:
        addresses:
          - 1.1.1.1
          - 1.0.0.1
          - 2620:0:ccc::2
          - 2620:0:ccd::2
        search: []

users:
  - name: ${USERNAME}
    sudo: ['ALL=(ALL) NOPASSWD:ALL']
    shell: /bin/bash
    lock_passwd: false
    passwd: ${PASSWORD_HASH}

write_files:
  - path: /etc/sysctl.d/60-custom-network.conf
    content: |
      # Enable IPv6
      net.ipv6.conf.all.disable_ipv6 = 0
      net.ipv6.conf.default.disable_ipv6 = 0
      net.ipv6.conf.lo.disable_ipv6 = 0
    permissions: '0644'

runcmd:
  - sysctl -p /etc/sysctl.d/60-custom-network.conf
  - systemctl restart systemd-networkd
  - systemctl restart systemd-resolved

package_update: true
packages:
  - curl
  - wget
  - vim
  - htop
```

## Network Configuration Automation

### Automated VM Creation Script

Create `/usr/local/bin/create-vm.sh`:

```bash
#!/bin/bash

# Automated VM creation script
set -e

# Configuration
TEMPLATE_ID=9000
VM_ID=${1:-103}
VM_NAME=${2:-"debian-auto"}
MEMORY=${3:-2048}
CORES=${4:-2}
STORAGE=${5:-"local"}

# Network configuration
PRIMARY_IP=${6:-"51.38.87.110"}
SECONDARY_IP=${7:-"51.38.87.113"}
GATEWAY=${8:-"51.89.234.254"}
NETMASK=${9:-"32"}

USERNAME="debian"
PASSWORD_HASH='$6$rounds=4096$saltsalt$hash'  # Generate with: mkpasswd -m sha-512

echo "Creating VM ${VM_ID} with name ${VM_NAME}..."

# Clone from template
qm clone $TEMPLATE_ID $VM_ID --name $VM_NAME --full

# Configure VM
qm set $VM_ID --memory $MEMORY --cores $CORES
qm set $VM_ID --agent enabled=1
qm set $VM_ID --serial0 socket --vga serial0

# Create custom cloud-init config
cat > /tmp/vm-${VM_ID}-user-data.yml << EOF
#cloud-config
network:
  version: 2
  ethernets:
    eth0:
      addresses:
        - ${PRIMARY_IP}/${NETMASK}
        - ${SECONDARY_IP}/${NETMASK}
      routes:
        - to: ${GATEWAY}/32
          via: 0.0.0.0
          scope: link
        - to: default
          via: ${GATEWAY}
      nameservers:
        addresses:
          - 1.1.1.1
          - 1.0.0.1
          - 8.8.8.8
          - 8.8.4.4

users:
  - name: ${USERNAME}
    sudo: ['ALL=(ALL) NOPASSWD:ALL']
    shell: /bin/bash
    lock_passwd: false
    passwd: ${PASSWORD_HASH}

package_update: true
packages:
  - curl
  - wget
  - vim
  - htop
  - net-tools

runcmd:
  - systemctl restart systemd-networkd
  - echo "VM ${VM_NAME} configured successfully" > /var/log/vm-setup.log
EOF

# Move to snippets
mv /tmp/vm-${VM_ID}-user-data.yml /var/lib/vz/snippets/

# Configure cloud-init with custom snippet
qm set $VM_ID --cicustom "user=local:snippets/vm-${VM_ID}-user-data.yml"
qm set $VM_ID --ciuser $USERNAME

# Resize disk if needed
qm resize $VM_ID scsi0 +10G

echo "VM ${VM_ID} created successfully!"
echo "Starting VM..."
qm start $VM_ID

echo "VM should be accessible at ${PRIMARY_IP} and ${SECONDARY_IP}"
```

Make it executable:
```bash
chmod +x /usr/local/bin/create-vm.sh
```

### Usage Examples

```bash
# Basic VM
./create-vm.sh 103 "web-server" 4096 4 "local" "51.38.87.110" "51.38.87.113" "51.89.234.254" "32"

# Multiple VMs with different IPs
./create-vm.sh 104 "db-server" 8192 4 "local" "51.38.87.120" "51.38.87.121" "51.89.234.254" "32"
./create-vm.sh 105 "app-server" 4096 2 "local" "51.38.87.130" "51.38.87.131" "51.89.234.254" "32"
```

## Complete Automation Examples

### 1. Terraform Integration

Create `main.tf` for Infrastructure as Code:

```hcl
terraform {
  required_providers {
    proxmox = {
      source = "telmate/proxmox"
      version = "2.9.14"
    }
  }
}

provider "proxmox" {
  pm_api_url = "https://your-proxmox:8006/api2/json"
  pm_user = "terraform@pve"
  pm_password = "your-password"
  pm_tls_insecure = true
}

resource "proxmox_vm_qemu" "debian-vm" {
  count = var.vm_count
  name = "debian-${count.index + 1}"
  target_node = "your-node"
  
  clone = "debian-template"
  
  cores = 2
  memory = 2048
  
  network {
    bridge = "vmbr0"
    model = "virtio"
  }
  
  disk {
    size = "20G"
    type = "scsi"
    storage = "local"
  }
  
  cicustom = "user=local:snippets/network-multi-ip.yml"
  ciuser = "debian"
  
  ipconfig0 = "ip=${var.ip_addresses[count.index]}/32,gw=${var.gateway}"
}

variable "vm_count" {
  default = 3
}

variable "ip_addresses" {
  default = ["51.38.87.110", "51.38.87.111", "51.38.87.112"]
}

variable "gateway" {
  default = "51.89.234.254"
}
```

### 2. Ansible Playbook

Create `deploy-vms.yml`:

```yaml
---
- name: Deploy Debian VMs with Cloud-Init
  hosts: localhost
  vars:
    vm_configs:
      - { id: 103, name: "web-01", ip: "51.38.87.110", secondary_ip: "51.38.87.113" }
      - { id: 104, name: "web-02", ip: "51.38.87.111", secondary_ip: "51.38.87.114" }
      - { id: 105, name: "db-01", ip: "51.38.87.112", secondary_ip: "51.38.87.115" }
    
  tasks:
    - name: Create cloud-init config for each VM
      template:
        src: cloud-init-user-data.j2
        dest: "/var/lib/vz/snippets/vm-{{ item.id }}-user-data.yml"
      loop: "{{ vm_configs }}"
    
    - name: Create VMs
      shell: |
        qm clone 9000 {{ item.id }} --name {{ item.name }} --full
        qm set {{ item.id }} --memory 2048 --cores 2
        qm set {{ item.id }} --cicustom "user=local:snippets/vm-{{ item.id }}-user-data.yml"
        qm start {{ item.id }}
      loop: "{{ vm_configs }}"
```

### 3. API-Based Automation

Create `api-deploy.py`:

```python
#!/usr/bin/env python3
import requests
import json
import time

class ProxmoxAPI:
    def __init__(self, host, user, password):
        self.host = host
        self.session = requests.Session()
        self.session.verify = False
        
        # Authenticate
        auth_data = {
            'username': user,
            'password': password
        }
        
        response = self.session.post(
            f"https://{host}:8006/api2/json/access/ticket",
            data=auth_data
        )
        
        ticket_data = response.json()['data']
        self.session.headers.update({
            'CSRFPreventionToken': ticket_data['CSRFPreventionToken']
        })
        self.session.cookies.set('PVEAuthCookie', ticket_data['ticket'])
    
    def create_vm(self, node, vm_config):
        """Create VM with cloud-init configuration"""
        
        # Create cloud-init snippet
        snippet_content = f"""#cloud-config
network:
  version: 2
  ethernets:
    eth0:
      addresses:
        - {vm_config['primary_ip']}/32
        - {vm_config['secondary_ip']}/32
      routes:
        - to: {vm_config['gateway']}/32
          via: 0.0.0.0
          scope: link
        - to: default
          via: {vm_config['gateway']}
      nameservers:
        addresses: [1.1.1.1, 1.0.0.1]

users:
  - name: debian
    sudo: ['ALL=(ALL) NOPASSWD:ALL']
    shell: /bin/bash
    lock_passwd: false
    passwd: $6$rounds=4096$salt$hash

packages: [curl, wget, vim, htop]
"""
        
        # Upload snippet
        snippet_data = {
            'content': snippet_content,
            'node': node
        }
        
        snippet_response = self.session.post(
            f"https://{self.host}:8006/api2/json/nodes/{node}/storage/local/upload",
            data={
                'content': 'snippets',
                'filename': f"vm-{vm_config['vmid']}-user-data.yml"
            },
            files={'filename': ('user-data.yml', snippet_content)}
        )
        
        # Clone VM
        clone_data = {
            'newid': vm_config['vmid'],
            'name': vm_config['name'],
            'full': 1
        }
        
        clone_response = self.session.post(
            f"https://{self.host}:8006/api2/json/nodes/{node}/qemu/{vm_config['template_id']}/clone",
            data=clone_data
        )
        
        # Configure VM
        config_data = {
            'memory': vm_config['memory'],
            'cores': vm_config['cores'],
            'cicustom': f"user=local:snippets/vm-{vm_config['vmid']}-user-data.yml",
            'ciuser': 'debian'
        }
        
        config_response = self.session.put(
            f"https://{self.host}:8006/api2/json/nodes/{node}/qemu/{vm_config['vmid']}/config",
            data=config_data
        )
        
        # Start VM
        start_response = self.session.post(
            f"https://{self.host}:8006/api2/json/nodes/{node}/qemu/{vm_config['vmid']}/status/start"
        )
        
        return {
            'vmid': vm_config['vmid'],
            'name': vm_config['name'],
            'status': 'created'
        }

# Usage
if __name__ == "__main__":
    proxmox = ProxmoxAPI('your-proxmox-host', 'root@pam', 'your-password')
    
    vm_configs = [
        {
            'vmid': 103,
            'name': 'web-01',
            'template_id': 9000,
            'memory': 2048,
            'cores': 2,
            'primary_ip': '51.38.87.110',
            'secondary_ip': '51.38.87.113',
            'gateway': '51.89.234.254'
        }
    ]
    
    for config in vm_configs:
        result = proxmox.create_vm('your-node', config)
        print(f"Created VM: {result}")
        time.sleep(5)  # Wait between creations
```

## Advanced Configurations

### Custom Datasource Configuration

Create `/var/lib/vz/snippets/custom-datasource.yml`:

```yaml
#cloud-config
# Custom datasource configuration to match VPS providers

datasource_list: [ NoCloud, ConfigDrive, None ]

datasource:
  NoCloud:
    # Seed from attached media
    seedfrom: /dev/sr0
    fs_label: CIDATA
    
system_info:
  default_user:
    name: debian
    sudo: ["ALL=(ALL) NOPASSWD:ALL"]
    shell: /bin/bash

# Network configuration
network:
  config:
    - type: physical
      name: eth0
      subnets:
        - type: static
          address: ${PRIMARY_IP}/${NETMASK}
          control: auto
        - type: static
          address: ${SECONDARY_IP}/${NETMASK}
          control: alias
      routes:
        - destination: ${GATEWAY}/32
          gateway: 0.0.0.0
          scope: link
        - destination: 0.0.0.0/0
          gateway: ${GATEWAY}

# DNS configuration
manage_resolv_conf: true
resolv_conf:
  nameservers:
    - 1.1.1.1
    - 1.0.0.1
    - 2620:0:ccc::2
    - 2620:0:ccd::2
  searchdomains: []

# Package management
package_update: true
package_upgrade: false
package_reboot_if_required: false

packages:
  - curl
  - wget
  - vim
  - htop
  - net-tools
  - dnsutils
  - iputils-ping

# Final commands
runcmd:
  - |
    # Generate network interfaces file like VPS provider
    cat > /etc/network/interfaces.d/50-cloud-init << 'EOF'
    # This file is generated from information provided by the datasource.  Changes
    # to it will not persist across an instance reboot.  To disable cloud-init's
    # network configuration capabilities, write a file
    # /etc/cloud/cloud.cfg.d/99-disable-network-config.cfg with the following:
    # network: {config: disabled}
    auto lo
    iface lo inet loopback
        dns-nameservers 1.1.1.1 1.0.0.1 2620:0:ccc::2 2620:0:ccd::2

    auto eth0
    iface eth0 inet static
        address ${PRIMARY_IP}/${NETMASK}
        dns-nameservers 1.1.1.1 1.0.0.1 2620:0:ccc::2 2620:0:ccd::2
        gateway ${GATEWAY}

    # control-alias eth0
    iface eth0 inet static
        address ${SECONDARY_IP}/${NETMASK}
    EOF
  - systemctl restart networking
  - echo "Auto-generated network configuration complete" > /var/log/cloud-init-network.log

write_files:
  - path: /etc/cloud/cloud.cfg.d/01-network-source.cfg
    content: |
      # Network data source configuration
      network:
        config: |
          # Auto-generated by cloud-init
          version: 2
    permissions: '0644'
```

## Template Creation Best Practices

### 1. Create Base Template

```bash
#!/bin/bash
# create-template.sh

# Download Debian cloud image
wget https://cloud.debian.org/images/cloud/bookworm/latest/debian-12-generic-amd64.qcow2

# Create template VM
qm create 9000 --name "debian-12-template" --memory 2048 --cores 2 --net0 virtio,bridge=vmbr0
qm importdisk 9000 debian-12-generic-amd64.qcow2 local
qm set 9000 --scsihw virtio-scsi-pci --scsi0 local:9000/vm-9000-disk-0.qcow2
qm set 9000 --boot c --bootdisk scsi0
qm set 9000 --serial0 socket --vga serial0
qm set 9000 --agent enabled=1

# Add cloud-init drive
qm set 9000 --ide2 local:9000/cloudinit,media=cdrom

# Convert to template
qm template 9000

echo "Template created successfully!"
```

### 2. Template Customization

```yaml
# /var/lib/vz/snippets/template-custom.yml
#cloud-config

# Install additional packages in template
packages:
  - qemu-guest-agent
  - cloud-init
  - curl
  - wget
  - vim
  - htop
  - net-tools
  - dnsutils
  - iputils-ping
  - systemd-timesyncd

# Configure services
runcmd:
  - systemctl enable qemu-guest-agent
  - systemctl enable systemd-timesyncd
  - systemctl enable systemd-resolved
  - systemctl enable systemd-networkd
  
# Clean up template
  - apt-get clean
  - rm -rf /var/lib/apt/lists/*
  - rm -rf /tmp/*
  - history -c
```

This comprehensive setup gives you the same level of automation as professional VPS providers, allowing you to deploy VMs with complex network configurations using just a few commands or API calls.