Here is the updated, fully masked version of your documentation. All public IPv4 and IPv6 addresses have been replaced with secure, generic placeholders (`X.X.X.X` and `2a01:4f9:XXXX:XXXX::/64`) while keeping the underlying network architecture completely intact.

---

# Complete Documentation: Hetzner Proxmox VE IPv6 Routed Setup (Masked)

This document outlines the complete network architecture and configuration required to route an external Hetzner `/64` IPv6 block to individual Proxmox LXC containers using a single physical interface.

## 1. Network Architecture Overview

- **Host Physical Interface:** `enp41s0`
- **Host Virtual Bridge:** `vmbr0`
- **Host Public IPv4:** `192.0.2.203/32` (Example Point-to-Point)
- **Host Assigned IPv6:** `2a01:4f9:XXXX:XXXX::2/64` (Acts as the LXC Gateway)
- **Upstream Hetzner Gateway:** `fe80::1` (Link-Local)
- **Container IPv6 Range:** `2a01:4f9:XXXX:XXXX::100` to `2a01:4f9:XXXX:XXXX::ffff`

---

## 2. Kernel Parameters (IPv6 Forwarding)

To allow Proxmox to route packets between the physical network interface (`enp41s0`) and the virtual network cards inside your containers, IPv6 forwarding must be permanently enabled in the Linux kernel.

**File Location:** `/etc/sysctl.d/99-ipv6-forwarding.conf`

```ini
net.ipv4.ip_forward=1
net.ipv6.conf.all.forwarding=1
net.ipv6.conf.default.forwarding=1
net.ipv6.conf.all.proxy_ndp=1
net.ipv6.conf.default.proxy_ndp=1

```

_To apply these settings manually without a reboot:_

```bash
sysctl -p /etc/sysctl.d/99-ipv6-forwarding.conf

```

---

## 3. Network Interfaces Configuration

The primary configuration is split cleanly into two parts: your core IPv4 setup and your separate IPv6 setup file.

### Part A: Core IPv4 Base Config

**File Location:** `/etc/network/interfaces`

```nginx
auto lo
iface lo inet loopback

# Physical network card configuration (Managed by the bridge)
iface enp41s0 inet manual

# The Proxmox Bridge handling your primary Hetzner IPv4
auto vmbr0
iface vmbr0 inet static
        address 192.0.2.203/32
        gateway 192.0.2.193
        bridge-ports enp41s0
        bridge-stp off
        bridge-fd 0
        pointopoint 192.0.2.193

# Automatically includes your separate configs
source /etc/network/interfaces.d/*

```

### Part B: IPv6 Specific Config

**File Location:** `/etc/network/interfaces.d/ipv6.cfg`

```nginx
iface vmbr0 inet6 static
        address 2a01:4f9:XXXX:XXXX::2/64
        gateway fe80::1
        endpoint enp41s0

```

_To apply configuration updates safely:_

```bash
systemctl restart networking

```

---

## 4. Provisioning LXC Containers (How to add containers)

Every time you build a new LXC container that needs direct, public IPv6 internet access, configure its network interface inside the Proxmox Web GUI using the parameters below.

### Web GUI Method

1. Select your **LXC Container** from the left-hand panel.
2. Go to **Network** and double-click your network device (usually `net0`).
3. Fill out the **IPv6** section exactly like this:

- **IPv6 Configuration:** `Static`
- **IPv6/CIDR:** `2a01:4f9:XXXX:XXXX::100/64` _(Increment this last number for every new container, e.g., `::101`, `::102`, etc.)_
- **Gateway (IPv6):** `2a01:4f9:XXXX:XXXX::2` _(This points back to your Proxmox host)._

### Alternative: Proxmox CLI Method

If you are automating container creation via scripts or terminal, use the `pct` command instead:

```bash
pct set <CT_ID> -net0 name=eth0,bridge=vmbr0,ip6=2a01:4f9:XXXX:XXXX::100/64,gw6=2a01:4f9:XXXX:XXXX::2

```

---

## 5. Container Verification and Troubleshooting

Once a container is started, verify its outer network reachability by executing these tests from the container's terminal:

1. **Verify routing to the Proxmox host:**

```bash
ping6 -c 3 2a01:4f9:XXXX:XXXX::2

```

2. **Verify public IPv6 routing:**

```bash
ping6 -c 3 google.com

```

> ⚠️ **Important DNS Note:** If public pings fail but the local host ping works, the container likely lacks an IPv6 DNS server. In the Proxmox Web GUI, navigate to **[Your Container]** $\rightarrow$ **DNS** $\rightarrow$ **Edit**, and add a global IPv6 DNS server like Cloudflare (`2606:4700:4700::1111`) or Google (`2001:4860:4860::8888`).
