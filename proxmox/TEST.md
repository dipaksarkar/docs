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



root@s4543:~# cat /etc/network/interfaces
source /etc/network/interfaces.d/*
root@s4543:~# cd /etc/network/interfaces.d
root@s4543:/etc/network/interfaces.d# ls
50-cloud-init
root@s4543:/etc/network/interfaces.d# cat 50-cloud-init
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
    address 93.127.222.102/24
    dns-nameservers 1.1.1.1 1.0.0.1 2620:0:ccc::2 2620:0:ccd::2
    gateway 93.127.222.1
    dns {'nameservers': ['1.1.1.1', '1.0.0.1', '2620:0:ccc::2', '2620:0:ccd::2'], 'search': []}

# control-alias eth0
iface eth0 inet static
    address 93.127.222.110/24

# control-alias eth0
iface eth0 inet6 static
    address 2a09:e683:7:4e::a/64
    gateway 2a09:e683:7::1



# Proxmox Cloud-Init Snippet Troubleshooting (Netplan Working)

openssl passwd -6 'WFJ8AR~UK@w6'

nano /var/lib/vz/snippets/ovh-network.yml
```yaml
#cloud-config
users:
  - name: debian
    gecos: Debian User
    sudo: ALL=(ALL) NOPASSWD:ALL
    shell: /bin/bash
    lock_passwd: false
    passwd: $5$nsuw04pC$K0JTU12hxDj6BPbZ564nIUabQ0Wff9GbtpFOCTTu.0B
    ssh_authorized_keys:
      - ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCbeYfOKRxq2SAc8WwyOrCdkTnD1Cct3CKLwgZQeh49Cw2oFTezIw+NaTAkhaw5RuYAOgSHWiAiZ+BdF+zIehIXWcwBB6UPZ+vh0V2XdMO6liVBA13ry9IsvAH2HMu1ZzxrD07JfzU5+HgcuoJofyL+dsBzgn6dp6Nvg6PUpCn5Mcoz0xYhomhCNQK4TnJEMbochXCj/wZJlJ+46OA8LMaseReN9jKVfobh4CxRqiP5kAnDY4SKCrGJY0BhXPxJulNPLy4gl/XHj9sP4R0JsJKaMNpID840i6oqPRCnMCqgAUvCm+s4t9aatdiYx4BfzYxV8bIzkbjJgpgIXJZ1gzdADj1unF8GiH0eGS69Y1TSeGsezLOld+DFSW+kDPklE8pvoMztyRVO+h8xqB2AHhV52d01/HR6Evgv5peshawltZygsCyOOui/7LsAOmPriLDQXO/p8pM7Wtda1hFF2Ym6qVCI4xa7fJMJ6EM2nM3oYMHhpcu8oL6ntt2WCFEU5FpsqHjFqdByDnkI1WmzBOaQKC5zgFNr0N0RIpCCFTS/o/2Kn/28WNIPAobognqwxMvQbMWlT5ZCYM+QPZxLCWc77xtLlgUxqqBlHALQvLPjrlA+JJY2FELYayPa//cYKWMGcQObs8xuac1jCeZL53fTiktiHJhOOzWYHooJehqw1Q== dipak@Dipaks-iMac.local
write_files:
  - path: /etc/netplan/99-custom-network.yaml
    content: |
      network:
        version: 2
        ethernets:
          eth0:
            addresses:
              - 51.38.87.110/32         # Primary IP
              - 51.38.87.113/32         # Secondary IP (add your second failover IP here)
            routes:
              - to: 0.0.0.0/0
                via: 51.89.234.254
                on-link: true
            nameservers:
              addresses:
                - 8.8.8.8
                - 1.1.1.1
    permissions: '0600'
runcmd:
  - netplan apply
```
qm set 103 --cicustom "user=local:snippets/ovh-network.yml"
qm cloudinit update 103
qm stop 103
sleep 5
qm start 103

# Proxmox Cloud-Init Snippet Troubleshooting (disables netplan/cloud-init)

## Full Cloud-Init snippet for OVH failover IPs using /etc/network/interfaces (primary + secondary, disables netplan/cloud-init/systemd-networkd)

Save as `/var/lib/vz/snippets/ovh-network-interfaces.yml`:

```yaml
#cloud-config
packages:
  - ifupdown
users:
  - name: debian
    gecos: Debian User
    sudo: ALL=(ALL) NOPASSWD:ALL
    shell: /bin/bash
    lock_passwd: false
    passwd: $5$nsuw04pC$K0JTU12hxDj6BPbZ564nIUabQ0Wff9GbtpFOCTTu.0B
    ssh_authorized_keys:
      - ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCbeYfOKRxq2SAc8WwyOrCdkTnD1Cct3CKLwgZQeh49Cw2oFTezIw+NaTAkhaw5RuYAOgSHWiAiZ+BdF+zIehIXWcwBB6UPZ+vh0V2XdMO6liVBA13ry9IsvAH2HMu1ZzxrD07JfzU5+HgcuoJofyL+dsBzgn6dp6Nvg6PUpCn5Mcoz0xYhomhCNQK4TnJEMbochXCj/wZJlJ+46OA8LMaseReN9jKVfobh4CxRqiP5kAnDY4SKCrGJY0BhXPxJulNPLy4gl/XHj9sP4R0JsJKaMNpID840i6oqPRCnMCqgAUvCm+s4t9aatdiYx4BfzYxV8bIzkbjJgpgIXJZ1gzdADj1unF8GiH0eGS69Y1TSeGsezLOld+DFSW+kDPklE8pvoMztyRVO+h8xqB2AHhV52d01/HR6Evgv5peshawltZygsCyOOui/7LsAOmPriLDQXO/p8pM7Wtda1hFF2Ym6qVCI4xa7fJMJ6EM2nM3oYMHhpcu8oL6ntt2WCFEU5FpsqHjFqdByDnkI1WmzBOaQKC5zgFNr0N0RIpCCFTS/o/2Kn/28WNIPAobognqwxMvQbMWlT5ZCYM+QPZxLCWc77xtLlgUxqqBlHALQvLPjrlA+JJY2FELYayPa//cYKWMGcQObs8xuac1jCeZL53fTiktiHJhOOzWYHooJehqw1Q== dipak@Dipaks-iMac.local
write_files:
  - path: /etc/network/interfaces
    content: |
      auto lo
      iface lo inet loopback

      auto eth0
      iface eth0 inet static
          address 51.38.87.110
          netmask 255.255.255.255
          broadcast 51.38.87.254
          gateway 51.89.234.254
          dns-nameservers 8.8.8.8 1.1.1.1

      # control-alias eth0
      iface eth0 inet static
          address 51.38.87.113
          netmask 255.255.255.255
          broadcast 51.38.87.254
    permissions: '0644'
runcmd:
  - ifdown eth0 || true
  - ifup eth0
```


```yaml
#cloud-config
packages:
  - ifupdown
users:
  - name: debian
    gecos: Debian User
    sudo: ALL=(ALL) NOPASSWD:ALL
    shell: /bin/bash
    lock_passwd: false
    passwd: $5$nsuw04pC$K0JTU12hxDj6BPbZ564nIUabQ0Wff9GbtpFOCTTu.0B
    ssh_authorized_keys:
      - ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCbeYfOKRxq2SAc8WwyOrCdkTnD1Cct3CKLwgZQeh49Cw2oFTezIw+NaTAkhaw5RuYAOgSHWiAiZ+BdF+zIehIXWcwBB6UPZ+vh0V2XdMO6liVBA13ry9IsvAH2HMu1ZzxrD07JfzU5+HgcuoJofyL+dsBzgn6dp6Nvg6PUpCn5Mcoz0xYhomhCNQK4TnJEMbochXCj/wZJlJ+46OA8LMaseReN9jKVfobh4CxRqiP5kAnDY4SKCrGJY0BhXPxJulNPLy4gl/XHj9sP4R0JsJKaMNpID840i6oqPRCnMCqgAUvCm+s4t9aatdiYx4BfzYxV8bIzkbjJgpgIXJZ1gzdADj1unF8GiH0eGS69Y1TSeGsezLOld+DFSW+kDPklE8pvoMztyRVO+h8xqB2AHhV52d01/HR6Evgv5peshawltZygsCyOOui/7LsAOmPriLDQXO/p8pM7Wtda1hFF2Ym6qVCI4xa7fJMJ6EM2nM3oYMHhpcu8oL6ntt2WCFEU5FpsqHjFqdByDnkI1WmzBOaQKC5zgFNr0N0RIpCCFTS/o/2Kn/28WNIPAobognqwxMvQbMWlT5ZCYM+QPZxLCWc77xtLlgUxqqBlHALQvLPjrlA+JJY2FELYayPa//cYKWMGcQObs8xuac1jCeZL53fTiktiHJhOOzWYHooJehqw1Q== dipak@Dipaks-iMac.local
write_files:
  - path: /etc/cloud/cloud.cfg.d/99-disable-network-config.cfg
    content: |
      network: {config: disabled}
    permissions: '0644'
  - path: /etc/network/interfaces
    content: |
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
          address 51.38.87.113
          netmask 255.255.255.255
          pointopoint 51.89.234.254
          label eth0:1
    permissions: '0644'
runcmd:
  - systemctl stop systemd-networkd
  - systemctl disable systemd-networkd
  - systemctl mask systemd-networkd
  - systemctl mask systemd-networkd.socket
  - systemctl mask systemd-networkd-wait-online.service
  - ifdown eth0 || true
  - ifup eth0 || true
```

qm set 103 --cicustom "user=local:snippets/ovh-network-interfaces.yml"
qm cloudinit update 103
qm stop 103
sleep 5
qm start 103