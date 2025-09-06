# 🔒 Proxmox ACME Cloudflare Legacy DNS Plugin Setup

This script will:

* Create the Cloudflare credential file
* Add the legacy DNS plugin for ACME
* Set your domain and associate the plugin
* Register the ACME account
* Order and install the SSL certificate

---

## ⚡️ Quick Setup

Run this command as **root** on your Proxmox node (after editing variables as needed):

```bash
bash <(wget -qO- https://raw.githubusercontent.com/dipaksarkar/docs/refs/heads/master/proxmox/cloudflare_acme.sh)
```

## 🔑 Usage Notes

* **Run as Root**: Execute directly on your Proxmox node.
* **Customization**: Edit `CLOUDFLARE_API_KEY`, `CLOUDFLARE_EMAIL`, `DOMAIN`, and `PLUGIN_NAME` before running.
* **DNS Propagation**: If DNS is slow, add `--validation-delay 60` to the plugin add command.
* **Verification**: After running, access `https://your-domain.com:8006` to confirm SSL is active.

---

⚠️ **Important:**

* Keep Proxmox console access handy in case of misconfiguration.
* Your Cloudflare API key grants DNS control—keep it secure!