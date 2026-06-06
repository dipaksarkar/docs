# Proxmox Single-IP Multi-LXC Hosting Setup

## Overview

This document describes the production setup used on an OVH dedicated server with Proxmox where:

- Only one public IPv4 address is available.
- Multiple LXC containers run on private IP addresses.
- Containers have internet access via NAT.
- Customers receive SSH access using unique external ports.
- Rules persist across reboots.

---

# Network Architecture

```text
Internet
    |
    |
51.xx.xxx.235
    |
    |
+------------------+
|  Proxmox Host    |
|      s4640       |
+------------------+
      |
      |
  vmbr1
10.10.10.1/24
      |
      |
+-------------+-----------------+
|             |                 |
CT101       CT103            CT105
10.10.10.101 10.10.10.103   10.10.10.105

CT102       CT104
10.10.10.102 10.10.10.104
```

---

# Public SSH Port Mapping

| Container | Internal IP  | External Port |
| --------- | ------------ | ------------- |
| CT101     | 10.10.10.101 | 2201          |
| CT102     | 10.10.10.102 | 2202          |
| CT103     | 10.10.10.103 | 2203          |
| CT104     | 10.10.10.104 | 2204          |
| CT105     | 10.10.10.105 | 2205          |

Customer example:

```bash
ssh root@51.xx.xxx.235 -p 2204
```

---

# Step 1 - Create Private Bridge

File:

```bash
/etc/network/interfaces
```

Add:

```text
auto vmbr1
iface vmbr1 inet static
    address 10.10.10.1/24
    bridge-ports none
    bridge-stp off
    bridge-fd 0
```

Apply:

```bash
ifreload -a
```

Verify:

```bash
ip addr show vmbr1
```

Expected:

```text
inet 10.10.10.1/24
```

---

# Step 2 - Configure Containers

Example CT104:

```text
Bridge: vmbr1
IPv4/CIDR: 10.10.10.104/24
Gateway: 10.10.10.1
```

Container assignments:

```text
CT101 -> 10.10.10.101
CT102 -> 10.10.10.102
CT103 -> 10.10.10.103
CT104 -> 10.10.10.104
CT105 -> 10.10.10.105
```

---

# Step 3 - Configure Host DNS

Proxmox:

```text
Node
└── DNS
```

DNS Servers:

```text
1.1.1.1
8.8.8.8
```

Containers use:

```text
Use Host Settings
```

Result:

```text
nameserver 1.1.1.1
nameserver 8.8.8.8
```

---

# Step 4 - Enable IP Forwarding

File:

```bash
/etc/sysctl.conf
```

Add:

```text
net.ipv4.ip_forward=1
```

Additional protection:

```bash
echo "net.ipv4.ip_forward=1" > /etc/sysctl.d/99-proxmox-nat.conf
```

Apply:

```bash
sysctl --system
```

Verify:

```bash
sysctl net.ipv4.ip_forward
```

Expected:

```text
net.ipv4.ip_forward = 1
```

---

# Step 5 - Enable NAT

Create masquerade rule:

```bash
iptables -t nat -A POSTROUTING \
    -s 10.10.10.0/24 \
    -o vmbr0 \
    -j MASQUERADE
```

Verify:

```bash
iptables -t nat -L -n -v
```

Expected:

```text
MASQUERADE 10.10.10.0/24
```

---

# Step 6 - Allow Forwarding

Required because UFW originally blocked forwarding.

Rules:

```bash
iptables -A FORWARD \
    -d 10.10.10.0/24 \
    -m conntrack --ctstate RELATED,ESTABLISHED \
    -j ACCEPT

iptables -A FORWARD \
    -s 10.10.10.0/24 \
    -j ACCEPT
```

Verify:

```bash
iptables -L FORWARD -n -v
```

Expected:

```text
ACCEPT all -- 10.10.10.0/24
ACCEPT all -- RELATED,ESTABLISHED
```

---

# Step 7 - SSH Port Forwarding

## CT101

```bash
iptables -t nat -A PREROUTING \
    -p tcp --dport 2201 \
    -j DNAT --to-destination 10.10.10.101:22
```

## CT102

```bash
iptables -t nat -A PREROUTING \
    -p tcp --dport 2202 \
    -j DNAT --to-destination 10.10.10.102:22
```

## CT103

```bash
iptables -t nat -A PREROUTING \
    -p tcp --dport 2203 \
    -j DNAT --to-destination 10.10.10.103:22
```

## CT104

```bash
iptables -t nat -A PREROUTING \
    -p tcp --dport 2204 \
    -j DNAT --to-destination 10.10.10.104:22
```

## CT105

```bash
iptables -t nat -A PREROUTING \
    -p tcp --dport 2205 \
    -j DNAT --to-destination 10.10.10.105:22
```

---

# Step 8 - Install Persistent Firewall Rules

Install:

```bash
apt install iptables-persistent -y
```

Save:

```bash
netfilter-persistent save
```

Verify:

```bash
cat /etc/iptables/rules.v4
```

Rules should include:

```text
MASQUERADE
PREROUTING
DNAT
10.10.10.0/24
```

---

# Verification Checklist

## Verify vmbr1

```bash
ip addr show vmbr1
```

Expected:

```text
10.10.10.1/24
```

---

## Verify Internet Access

Inside container:

```bash
ping 8.8.8.8
```

Expected:

```text
Replies received
```

---

## Verify DNS

Inside container:

```bash
getent hosts google.com
```

Expected:

```text
IPv4/IPv6 addresses returned
```

---

## Verify Package Downloads

Inside container:

```bash
apt update
```

Expected:

```text
Package lists download successfully
```

---

## Verify SSH Forwarding

From external machine:

```bash
ssh root@51.xx.xxx.235 -p 2204
```

Expected:

```text
Login to CT104
```

---

# Troubleshooting

## No Internet Access

Check:

```bash
sysctl net.ipv4.ip_forward
```

Must be:

```text
1
```

Check:

```bash
iptables -t nat -L -n -v
```

Verify:

```text
MASQUERADE
```

exists.

---

## DNS Not Working

Check:

```bash
cat /etc/resolv.conf
```

Expected:

```text
nameserver 1.1.1.1
nameserver 8.8.8.8
```

---

## SSH Port Not Working

Check:

```bash
iptables -t nat -L PREROUTING -n -v
```

Verify DNAT rule exists.

Check:

```bash
ssh root@10.10.10.104
```

from the Proxmox host.

---

# Production Notes

- One public IP supports many containers.
- Keep all containers on vmbr1.
- Expose only required ports.
- Prefer SSH keys over passwords.
- Save firewall changes using:

```bash
netfilter-persistent save
```

- For future containers:

```text
CT106 -> 10.10.10.106 -> Port 2206
CT107 -> 10.10.10.107 -> Port 2207
CT108 -> 10.10.10.108 -> Port 2208
```

Simple formula:

```text
SSH Port = 2100 + Container ID - 100
```

Examples:

```text
CT101 -> 2201
CT125 -> 2225
CT150 -> 2250
CT199 -> 2299
```
