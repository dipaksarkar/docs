# Proxmox VE: Create a Cloud-Init VM Template (Ubuntu, ifupdown, Multiple IPs)

This guide shows how to create a reusable Proxmox VM template using a cloud image and Cloud-Init, with best practices for static networking (ifupdown, not Netplan), stable NIC naming, console output, and assigning multiple IPs.

---

## Step 1: Download Cloud Image & Create VM

```bash
wget https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img
qm create 103 --name ubuntu-cloud --memory 2048 --net0 virtio,bridge=vmbr0
qm importdisk 103 jammy-server-cloudimg-amd64.img local-lvm
qm set 103 --scsihw virtio-scsi-pci --scsi0 local-lvm:vm-103-disk-0
qm set 103 --boot order=scsi0
qm set 103 --ide2 local-lvm:cloudinit
qm set 103 --serial0 socket --vga serial0
```

---

## Step 2: Remove Netplan & Enable ifupdown (Inside VM)

After first boot, connect to the VM console:

```bash
sudo apt update
sudo apt install ifupdown -y
sudo apt purge nplan netplan.io -y
sudo rm -rf /etc/netplan

# Disable and mask systemd-networkd and wait-online
sudo systemctl disable systemd-networkd-wait-online.service
sudo systemctl mask systemd-networkd-wait-online.service
sudo systemctl disable systemd-networkd.service
sudo systemctl mask systemd-networkd.service
```

---

## Step 3: Configure DNS (Optional)

```bash
sudo rm /etc/resolv.conf
sudo tee /etc/resolv.conf << EOF
nameserver 8.8.8.8
nameserver 8.8.4.4
nameserver 1.1.1.1
EOF
```

---

## Step 4: GRUB Adjustments (Stable NIC + Console)

Edit `/etc/default/grub`:

```ini
GRUB_CMDLINE_LINUX_DEFAULT=""
GRUB_CMDLINE_LINUX="net.ifnames=0 biosdevname=0 console=tty0 console=ttyS0,115200 earlyprintk=ttyS0,115200 consoleblank=0"
GRUB_TERMINAL="console serial"
GRUB_SERIAL_COMMAND="serial --speed=115200"
```

Apply changes:

```bash
sudo update-grub
```

This ensures:

* Interface is always `eth0` (no `ens18`/`enp0s18` renaming).
* Proxmox console shows boot logs clearly.
* Useful for debugging in Hetzner/OVH.

---

## Step 5: Add Temporary IP Route (If Needed)

```bash
# Show interfaces to confirm device name
ip a
ip link show

# Add default route (replace eth0 if needed)
sudo ip route add default via <GATEWAY_IP> dev <INTERFACE_NAME> onlink
# Example:
sudo ip route add default via 51.89.234.254 dev eth0 onlink
```

---

## Step 6: Reboot & Verify Networking

```bash
sudo reboot
ip route show
ping -c 3 8.8.8.8
ping -c 3 google.com
```

---

## Step 7: Clean Up & Convert to Template

Once networking is confirmed:

```bash
# Remove SSH host keys so each VM generates new ones
sudo rm -f /etc/ssh/ssh_host_*

# Reset Cloud-Init
sudo cloud-init clean --logs --seed

# Clear shell history
history -c

# Power off
sudo shutdown -h now
```

In Proxmox GUI:
Right-click VM → **Convert to Template**

---

## Assign Multiple IPs to Same NIC (Cloud-Init Custom Network)

To assign multiple IPs to a single NIC, use a custom Cloud-Init network config snippet:

1. Create a file `/var/lib/vz/snippets/<VMID>-network.yaml`:

   ```yaml
   version: 2
   ethernets:
     eth0:
       dhcp4: no
       addresses:
         - 51.38.87.110/32
         - 51.38.87.113/32
       gateway4: 51.89.234.254
       nameservers:
         addresses: [8.8.8.8, 1.1.1.1]
   ```

2. Attach the custom network config:

   ```bash
   qm set <VMID> --cicustom "network=local:<VMID>/network.yaml"
   qm cloudinit update <VMID>
   qm stop <VMID>
   qm start <VMID>
   ```

3. To remove and revert to default:

   ```bash
   qm set <VMID> --delete cicustom
   ```

---

## Best Practices

* Always automate IP assignment via **Cloud-Init** or Proxmox snippets.
* Never hardcode configs inside the VM.
* Keep `network.yaml` snippets in version control.
* For Hetzner/OVH:

  * Use `/32` addresses with the provider’s gateway.
  * Ensure MAC addresses match the assigned server/VM config.

---

**References:**

* [Proxmox Cloud-Init Documentation](https://pve.proxmox.com/wiki/Cloud-Init_Support)
* [Proxmox cicustom Reference](https://pve.proxmox.com/pve-docs/qm.1.html)
