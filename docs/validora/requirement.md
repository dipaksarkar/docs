# Requirements & Important Notes

Only purchase this application if you have experience in server management or the administration of your virtual private server or have someone who can maintain it. We will not provide lifetime server maintenance service with this application. You are only purchasing the application and support related to the internal issue with the application, and not for support issues from your virtual private server. You will be required to perform server optimizations based on the documentation of the application.

A complete step-by-step from full server to email verifier script configuration and installation video walkthrough is available here.

If you are still unable to install the following video / guided documentation or require assistance with installation, then you can try our paid installation support here.  
Installation service is free for SaaS license customers.

---

## Recommended Environment

- **Recommended OS:** Centos 8, Ubuntu 22.04 LTS, Debian 11
- **Web Server:** Apache/Nginx
- **PHP Version:** 7.4 FPM/FastCGI (Recommends PHP-FPM)
- **MySQL / MariaDB Version:** 5.6+ / 10+
- **PHP Extensions:** GMP, Curl, PHP Mail(), PHP Session
- **Supported Browser:** Javascript & Cookies Enabled (IE9, IE10, IE11, Edge, Firefox, Chrome, Safari)
- **Domain:** A best TLD for good online presence and trust score. Suggested .com extension domain.
- **VPS:** Any Cheap Linux KVM VPS with at least 4GB RAM and 4 core (4GHz CPU).  
  (Do not support shared/reseller hosting, you may find some optional recommendations here).  
  For SaaS you might have to add more CPU / RAM based on multiuser usage.
- **Server PTR/rDNS:** Point to host IP and port 25 open
- **Root Access:** To modify apache and PHP timeout
- **Access to Cron Job**
- **Script installation must be done in HTTPS!**
- **Do not use any third-party CDN/PROXY/Server Sided FIREWALL**
- **If using Apache Mod Security:** Fully whitelist the script path
- **Clean server:** No other scripts or domains running besides this email scan script

---

## Mail Server Configuration

Your server must be configured properly as a mail server to avoid being blocked or blacklisted by email tracker systems like Spamhaus. This includes things like SSL, SPF records, Domain Key records, DMARC records and valid MX records. All this data setup should be relevant to the HOST IP. More brief details on what records are to be added have been given below. To check your mail server health use this tool: [https://mail-tester.com](https://mail-tester.com). To learn briefly about how to prevent blacklist kindly read here.

### Example DNS Records

```
cp.yourdomain.com.  IN  A  HOST_IP     # Panel login and rDNS/PTR record setup from the host side
yourdomain.com.  IN  A  HOST_IP       # Main domain A record
ftp.yourdomain.com.  IN   CNAME   yourdomain.com.   # Optional for FTP client connection
www.yourdomain.com.  IN   CNAME   yourdomain.com.   # Optional for Canonical name
yourdomain.com.  IN  MX  10  cp.yourdomain.com.     # MX for mail server
default._domainkey.yourdomain.com.   IN    TXT   YOUR_DOMAIN_KEY  # DKIM/Domain Key
_dmarc.yourdomain.com.   IN   TXT   "v=DMARC1; p=none"   # DMARC for policy based control
yourdomain.com.   IN    TXT     "v=spf1 +a +mx ip4:HOST_IP ~all"   # SPF record
```

If you own a regular license and are unable to set up any records in your domain panel and need a hand to configure the whole script installation and DNS, then we can configure this whole process for a one time minimal fee. But there are no fees for SaaS license users. Contact support for details.

---

## Port 25 Check

When installing the script it will do auto check at system detection if your HOST port 25 is open for making outbound connections. If it shows Block, then don’t bother to install it unless you have an outbound result as Open. Also, you can precheck if your server can make an outgoing connection over port 25 for the script to work. Download this file, unzip and access it from your web URL. If you see all SMTP ports 25 open like this bottom image then you are good to go!

---

## Installation Path

After uploading extracted files to the `public_html` folder or domain public web folder via FTP, you have to visit `install.php` file path via the browser to start up the installation process.

**File Path For Install.php:**  
`yourdomain.com/install.php`

- Script needs full domain path, do not install on a subfolder.
- Subdomains (`sub.yourdomain.com/install.php`) are supported but not subfolders (`yourdomain.com/subfolder/install.php`).
- You can replace or use a different home page after installation is completed. However, the script requires a root domain path for a successful installation.
- Do not forget to replace `yourdomain.com` with your own domain address.

If this is a first-time clean installation and not an update then you will be automatically redirected to `install.php` once you try to visit your domain (e.g., `yourdomain.com`). But if you do not get redirected to `install.php` then you can simply visit it by the following address:  
`yourdomain.com/install.php`
