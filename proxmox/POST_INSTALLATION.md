# 🚀 Proxmox Post-Installation Script for OVH Dedicated Servers

This script will:

* Update system & Proxmox packages
* Install useful monitoring & security tools
* Tune ZFS for performance
* Secure SSH access (new port, key-based login, no root login)
* Configure firewall (UFW) and Fail2Ban
* Create a secure user `goazh`

---

## 📦 Quick Install

Run this single command as **root** after a fresh OVH Proxmox install:

```bash
bash <(wget -qO- https://raw.githubusercontent.com/dipaksarkar/docs/refs/heads/master/proxmox/post_installation.sh)
```

---

## 🔑 Accessing Your Server

* SSH (default port 2222, or your chosen port):

  ```bash
  ssh -p 2222 goazh@your-server-ip
  ```
* Switch to root:

  ```bash
  sudo -i
  ```
* Proxmox Web UI:
  `https://your-server-ip:8006`

---

⚠️ **Important:**

* Keep OVH IPMI/KVM console handy for emergency access (if firewall/SSH misconfiguration locks you out).