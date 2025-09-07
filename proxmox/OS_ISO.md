# OS ISO Download Links

Below are direct download links for popular Linux distributions. Use these ISOs to install operating systems on your Proxmox environment.

## Ubuntu

- [Ubuntu 24.04.3 LTS (Noble) Live Server (amd64)](https://mirror.sitsa.com.ar/ubuntu-releases/noble/ubuntu-24.04.3-live-server-amd64.iso)
- [Ubuntu 22.04.5 LTS (Jammy) Live Server (amd64)](https://releases.ubuntu.com/jammy/ubuntu-22.04.5-live-server-amd64.iso)

## Debian

- [Debian 13.0.0 (Bookworm) Netinst (amd64)](https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/debian-13.0.0-amd64-netinst.iso)
- [Debian 12.12.0 (Bookworm) Netinst (amd64, archived)](https://cdimage.debian.org/mirror/cdimage/archive/12.12.0/amd64/iso-cd/debian-12.12.0-amd64-netinst.iso)

## AlmaLinux

- [AlmaLinux 8.10 Minimal (x86_64)](https://repo.almalinux.org/almalinux/8.10/isos/x86_64/AlmaLinux-8.10-x86_64-minimal.iso)

---

**Tip:** Download the required ISO and upload it to your Proxmox server's ISO storage for easy VM installation.



## 📦 Quick Install

Run this single command as **root** after a fresh OVH Proxmox install:

```bash
bash <(wget -qO- https://raw.githubusercontent.com/dipaksarkar/docs/refs/heads/master/proxmox/cloud_templates.sh)
```