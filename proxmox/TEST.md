# OVH Failover IP Configuration for Proxmox VMs

```bash
sudo netplan apply
```

```log
** (generate:435): WARNING **: 07:48:32.711: `gateway4` has been deprecated, use default routes instead.
See the 'Default routes' section of the documentation for more details.
```

Check your network interfaces:

```bash
ip a
```

Sample output:
```
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
  link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
  inet 127.0.0.1/8 scope host lo
     valid_lft forever preferred_lft forever
  inet6 ::1/128 scope host noprefixroute 
     valid_lft forever preferred_lft forever
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
  link/ether 02:00:00:31:b8:72 brd ff:ff:ff:ff:ff:ff
  altname enp0s18
  altname ens18
  inet 51.38.66.157/32 scope global eth0
     valid_lft forever preferred_lft forever
  inet6 fe80::ff:fe31:b872/64 scope link 
     valid_lft forever preferred_lft forever
```

---

## Set DNS

Set DNS servers for your VM:

```bash
qm set 110 --nameserver "8.8.8.8 1.1.1.1"
```

---

## Netplan Override (Recommended)

Create a persistent netplan configuration that survives reboots:

1. Create a custom netplan file:

  ```bash
  sudo nano /etc/netplan/99-custom-network.yaml
  sudo chmod 644 /etc/netplan/99-custom-network.yaml
  ```

2. Add the following content (replace `ens18` with your actual interface name from `ip a`):

  ```yaml
  network:
    version: 2
    ethernets:
    ens18:
      addresses:
      - 51.38.66.157/32
      routes:
      - to: default
        via: 51.38.66.1
        on-link: true
      nameservers:
      addresses:
        - 8.8.8.8
        - 1.1.1.1
  ```

3. Apply the configuration and test connectivity:

  ```bash
  sudo netplan apply
  ping -c 3 8.8.8.8
  ```

---

## Managing Netplan Files

List and edit netplan files as needed:

```bash
sudo ls /etc/netplan/
sudo cat /etc/netplan/50-cloud-init.yaml
sudo mv /etc/netplan/50-cloud-init.yaml /etc/netplan/50-cloud-init.yaml.bak
sudo nano /etc/netplan/50-cloud-init.yaml
sudo chmod 644 /etc/netplan/50-cloud-init.yaml
```

```yaml /etc/netplan/50-cloud-init.yaml
# This file is generated from information provided by the datasource.  Changes
# to it will not persist across an instance reboot.  To disable cloud-init's
# network configuration capabilities, write a file
# /etc/cloud/cloud.cfg.d/99-disable-network-config.cfg with the following:
# network: {config: disabled}
network:
    version: 2
    ethernets:
        ens18:
            addresses:
            - 51.38.66.157/32
            gateway4: 51.89.234.254
            nameservers:
                addresses:
                - 8.8.8.8
                - 1.1.1.1
```

---

## Manual Route Addition (Temporary Fix)

If you need immediate connectivity, add the default route manually:

```bash
# Show interfaces to confirm the device name
ip a
ip link show

# Add the default gateway (replace <ens18> with your interface)
sudo ip route add default via 51.38.66.1 dev <ens18> onlink
```

Verify the route and test connectivity:

```bash
ip route show
ping -c 3 8.8.8.8
```

# Proxmox Cloud-Init Snippet Troubleshooting (Not Working)

## Step 1: Verify Snippet Storage Configuration

First, check if your Proxmox snippets storage is configured correctly:

**SSH to Proxmox host and run:**
```bash
# Check if snippets directory exists and is readable
ls -la /var/lib/vz/snippets/

# Check Proxmox storage configuration
pvesm status
```

## Step 2: Create the Correct Snippet

**Create the snippet file on Proxmox host:**
```bash
# Create a minimal network-only snippet
cat > /var/lib/vz/snippets/ovh-network.yml << 'EOF'
#cloud-config

# Only write the corrected network configuration
write_files:
  - path: /etc/netplan/99-custom-network.yaml
    content: |
      network:
        version: 2
        ethernets:
          ens18:
            addresses:
              - 51.38.66.157/32
            routes:
              - to: 0.0.0.0/0
                via: 51.38.66.1
                on-link: true
            nameservers:
              addresses:
                - 8.8.8.8
                - 1.1.1.1
    permissions: '0644'

runcmd:
  - netplan apply
  - ip route add default via 51.38.66.1 dev ens18 onlink || true
EOF

chmod 644 /var/lib/vz/snippets/ovh-network.yml
```

## Step 3: Verify Snippet is Accessible

**Check if Proxmox can see the snippet:**
```bash
# List available snippets
qm cloudinit dump 110

# Verify the snippet file content
cat /var/lib/vz/snippets/ovh-network.yml
```

## Step 5: Apply Snippet to VM

**Alternative CLI method:**
```bash
# Clear existing network configuration
qm set 110 --delete ipconfig0

# Set the custom snippet
qm set 110 --cicustom "user=local:snippets/ovh-network.yml"

# Update Cloud-Init
qm cloudinit update 110

# Stop and start VM
qm stop 110
sleep 5
qm start 110
```
