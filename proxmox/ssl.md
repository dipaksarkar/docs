# Complete Step-by-Step Documentation: Adding SSL to a Proxmox VE Server

This documentation provides an end-to-end guide to securing your Proxmox VE web interface using free, auto-renewing SSL certificates from **Let's Encrypt** combined with **Cloudflare DNS** validation. This method works perfectly for internal/homelab networks without needing to expose your Proxmox server to the open internet.

---

## Prerequisites

- A registered domain name managed via **Cloudflare** (e.g., `yourdomain.com`).
- A fully configured local DNS record or local hosts entry routing your Proxmox subdomain (e.g., `pve.yourdomain.com`) to your Proxmox server's local IP address.
- Root access to the Proxmox VE Web UI.

---

## Step 1: Register an ACME Account in Proxmox

The ACME account allows Proxmox to communicate securely with Let's Encrypt to request certificates.

1. Log into your Proxmox Web GUI via its IP address (e.g., `https://192.168.1.X:8006`).
2. On the leftmost menu, click on **Datacenter**.
3. In the middle options column, select **ACME**.
4. Under the **Accounts** section, click the **Add** button.
5. Fill out the form:

- **Account Name:** Enter a shorthand nickname (e.g., `letsencrypt-prod`).
- **E-Mail:** Enter your valid email address (Let's Encrypt uses this to send expiration notifications if renewals fail).
- **Directory:** Leave as the default **Let's Encrypt V2 (Directory)**.

6. Check the box to accept the Terms of Service.
7. Click **Register**.

---

## Step 2: Retrieve API Credentials from Cloudflare

Proxmox needs permission to temporarily add a text record to your Cloudflare account to prove you own the domain.

### Part A: Find your Account & Zone ID

1. Log into your [Cloudflare Dashboard](https://dash.cloudflare.com/).
2. Select your domain from the list.
3. On the **Overview** page, scroll down to the bottom of the right-hand sidebar.
4. Locate the **API** section and copy both the **Zone ID** and **Account ID** to a temporary notepad file.

### Part B: Create a Restricted API Token (Recommended)

1. At the top-right of the Cloudflare dashboard, click your **User Profile icon** and select **My Profile**.
2. Click **API Tokens** in the left menu.
3. Click the **Create Token** button.
4. Next to the **Edit zone DNS** template, click **Use template**.
5. Under **Zone Resources**, configure it exactly as follows:

- _Include_ | _Specific zone_ | Select your domain name.

6. Scroll to the bottom and click **Continue to Summary**.
7. Click **Create Token**.
8. **Copy the API Token immediately.** _(Note: Cloudflare will only display this token once for security)._

---

## Step 3: Configure the Cloudflare Plugin in Proxmox

Now, pass those Cloudflare credentials to your Proxmox cluster configuration.

1. Go back to your Proxmox Web GUI -> **Datacenter** -> **ACME**.
2. Look at the **Challenge Plugins** section (bottom half of the page) and click **Add**.
3. Fill out the configuration window:

- **Plugin ID:** Create a lowercase shorthand name (e.g., `cloudflare-dns`).
- **Validation Delay:** Leave at `30` (this ensures Let's Encrypt waits 30 seconds for Cloudflare's servers to sync before validating).
- **DNS API:** Select **Cloudflare Managed DNS** from the dropdown menu.

4. In the **API Data** text field block, populate the lines exactly as follows:

```text
CF_Account_ID=YOUR_CLOUDFLARE_ACCOUNT_ID_HERE
CF_Token=YOUR_CLOUDFLARE_API_TOKEN_HERE
CF_Zone_ID=YOUR_CLOUDFLARE_ZONE_ID_HERE

```

_(Ensure `CF_Email` and `CF_Key` lines are completely deleted or left entirely blank)._ 5. Click **Add**.

---

## Step 4: Map your Domain to the Proxmox Node

This step attaches your intended URL/subdomain directly to your local physical machine.

1. On the far-left menu tree, look below "Datacenter" and click directly on your physical **Proxmox Node** (typically named `pve` or your custom machine name).
2. Expand the **System** sub-menu and click on **Certificates**.
3. Scroll down to the bottom **ACME** section and click **Add**.
4. Fill out the fields:

- **Challenge Type:** Select **DNS**.
- **Plugin:** Select the `cloudflare-dns` plugin you created in Step 3.
- **Domain:** Enter the exact FQDN you intend to use to access this machine (e.g., `pve.yourdomain.com`).

5. Click **Create**.

---

## Step 5: Order and Apply the SSL Certificate

1. On that same **Certificates** page, scroll back up to the top.
2. Click the **Order Certificates Now** button.
3. A separate task log terminal window will automatically pop up showing the live process:

- Proxmox will request a challenge token from Let's Encrypt.
- Proxmox will use your API token to automatically add a `_acme-challenge` TXT record to your Cloudflare DNS.
- Let's Encrypt will verify the TXT record, authorize ownership, and issue the certificate.
- Proxmox will automatically clear the temporary TXT record out of your Cloudflare account.

4. Look for the final log line showing **`TASK OK`**.
5. The window will close, and the Proxmox web interface service (`pveproxy`) will restart itself automatically.

---

## Step 6: Verification

1. Close your browser tab or clear your browser cache.
2. Open a new window and navigate to your Proxmox server using its domain name and port 8006:

```text
https://pve.yourdomain.com:8006

```

3. Check the address bar. The connection will now show a valid, secure padlock icon with zero security warnings.

---

## Maintenance & Automation Notes

- **Auto-Renewal:** You do not need to repeat this process. Proxmox runs an internal cron job that checks your certificate status daily. It will automatically renew the certificate via the Cloudflare API 30 days before it expires.
- **Accessing via IP:** If you continue to navigate to the Proxmox server via its raw local IP address (e.g., `https://192.168.1.X:8006`), your browser will still show an untrusted warning. This is expected behavior; SSL certificates bind strictly to domain names, not private IP addresses. Always use the domain name going forward.
