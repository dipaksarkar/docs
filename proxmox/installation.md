# Hetzner Bare-Metal Proxmox Installation & Network Recovery Guide

This documentation details the process of installing Proxmox VE via a QEMU ISO attachment loop, mounting the ZFS file system via Hetzner Rescue Mode for emergency maintenance, repairing critical network interface naming mismatches, and configuring a stateless hardware firewall.

---

## Section 1: The Initial Installation Layer (QEMU ISO Booting)

To deploy Proxmox VE using a custom ISO on a bare-metal Hetzner server without a physical KVM console, QEMU is utilized inside the Rescue environment to initiate installation directly onto the physical NVMe drives.

1. **Establish a Local VNC Tunnel over SSH from your Mac:**

```bash
ssh -L 5900:127.0.0.1:5900 root@192.0.2.203

```

2. **Launch the Installer Interface via QEMU:**

```bash
qemu-system-x86_64 -enable-kvm -smp 4 -m 8192 \
-boot d -cdrom ./pve.iso \
-drive file=/dev/nvme0n1,format=raw,if=virtio,file.locking=off \
-drive file=/dev/nvme1n1,format=raw,if=virtio,file.locking=off \
-vnc 0.0.0.0:0

```

3. **Connect via TigerVNC:**

- Install the viewer client on macOS: `brew install --cask tigervnc-viewer`
- Open TigerVNC and point it to: `127.0.0.1:5900` to complete the visual Proxmox installation wizard onto your ZFS drives.

---

## Section 2: Real Hardware Interface Identification

Hetzner Rescue environments forcefully maps the primary network controller to a legacy alias (`eth0`). Modern bare-metal kernels (Debian/Proxmox) assign **Predictable Network Interface Names** based on PCIe topography.

If the internal files inside Proxmox target `eth0`, the network stack fails to initialize upon regular boot. To find the true hardware interface name from Rescue Mode, query the device subsystem path:

```bash
udevadm info -q property /sys/class/net/eth0 | grep "ID_NET_NAME_PATH="

```

_Calculated Motherboard Value:_ **`enp41s0`**

---

## Section 3: Mount Recovery Operations (The Fix)

When the network fails and isolation occurs, boot the server back into **Hetzner Rescue Mode** to access and edit the internal configuration files directly on the ZFS storage pool.

```bash
# Force-import the ZFS array without tracking local targets
zpool import -f -N -R /mnt rpool

# Mount the absolute Proxmox root operating system dataset
zfs mount rpool/ROOT/pve-1

```

---

## Section 4: Production Network Mapping (`/etc/network/interfaces`)

With the drive array successfully mounted to `/mnt`, open the configuration file (`nano /mnt/etc/network/interfaces`) and replace any generic `eth0` variables with the exact hardware controller string discovered in Section 2.

### Complete Network Configuration File Structure:

```nginx
auto lo
iface lo inet loopback

# Actual underlying hardware interface discovered via device path strings
iface enp41s0 inet manual

# Core Proxmox virtual switch network bridge
auto vmbr0
iface vmbr0 inet static
        address 192.0.2.203/32
        gateway 192.0.2.193
        bridge-ports enp41s0
        bridge-stp off
        bridge-fd 0
        pointopoint 192.0.2.193

source /etc/network/interfaces.d/*

```

### Essential Post-Mount System Adjustments

1. **Correct DNS Resolvers (`/mnt/etc/resolv.conf`):**
   Ensure internal DNS isn't caching sandbox loopback values (`10.0.2.3`). Wipe it and enforce Hetzner’s reliable bare-metal nameservers:

```text
nameserver 185.12.64.1
nameserver 185.12.64.2

```

2. **Enable Host Packet Forwarding:**

```bash
echo "net.ipv4.ip_forward=1" >> /mnt/etc/sysctl.d/99-networking.conf

```

3. **Swap to Proxmox Free Community Repositories:**

```bash
sed -i 's/^deb/#deb/' /mnt/etc/apt/sources.list.d/pve-enterprise.list
echo "deb http://download.proxmox.com/debian/pve bookworm pve-no-subscription" >> /mnt/etc/apt/sources.list

```

---

## Section 5: Unmounting and Returning to Bare Metal

To prevent filesystem synchronization drops or dirty pool states, cleanly export the array layout before triggering a hardware cycle:

```bash
zpool export rpool
reboot

```

---

## Section 6: Stateless Hetzner Hardware Firewall Setup

Hetzner’s hardware firewall drops core data packets if strict protocol rules are missing. Wildcard markers (`*`) interrupt the required TCP state flow patterns for deep payload operations like the Proxmox Web GUI.

The configuration matrix must explicitly look like this to maintain live connections:

| Rule Order | Name              | Protocol  | Source IP   | Destination IP | Source Port | Destination Port | TCP Flags | Action   |
| ---------- | ----------------- | --------- | ----------- | -------------- | ----------- | ---------------- | --------- | -------- |
| **#1**     | `icmp`            | `icmp`    | `0.0.0.0/0` | `0.0.0.0/0`    | `0-65535`   | `0-65535`        | _Blank_   | `accept` |
| **#2**     | `ssh`             | `tcp`     | `0.0.0.0/0` | `0.0.0.0/0`    | `0-65535`   | `22`             | _Blank_   | `accept` |
| **#3**     | `http`            | `tcp`     | `0.0.0.0/0` | `0.0.0.0/0`    | `0-65535`   | `80,443`         | _Blank_   | `accept` |
| **#4**     | `tcp established` | `tcp`     | `0.0.0.0/0` | `0.0.0.0/0`    | `0-65535`   | `32768-65535`    | `ack`     | `accept` |
| **#5**     | `proxmox`         | **`tcp`** | `0.0.0.0/0` | `0.0.0.0/0`    | `0-65535`   | `8006`           | _Blank_   | `accept` |

---

## Section 7: Hypervisor Storage Operations Reference

Because this cluster backend relies directly on a **ZFS Storage Pool Array** rather than traditional directory trees or standard LVM thick provisioning, the underlying management environment gains the following enterprise behaviors:

- **Native LXC Snapshots:** Linux Containers (LXCs) built on ZFS automatically inherit native copy-on-write capabilities. They do not require an LVM-Thin volume allocation to toggle point-in-time states.
- **Instantaneous Snapshots:** Creating rolling snapshots takes less than a second ($< 1\text{s}$) regardless of storage scale and consumes 0 bytes of storage overhead until production data drifts.
- **Live Zero-Downtime Backups:** Backing up guests via Proxmox using **Snapshot Mode** instructs ZFS to freeze the active file layer block tree in an instant, backing up data to safe backup directories without suspending, stopping, or creating container operational downtime.
