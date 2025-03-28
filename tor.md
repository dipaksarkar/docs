Here’s a **complete guide** on installing, configuring, and using **Tor proxy** on macOS, including changing the IP address dynamically.

---

## **1. Install Tor on macOS**
Tor can be installed via **Homebrew**:

```sh
brew install tor
```

---

## **2. Configure Tor**
You need to modify Tor’s configuration file to enable the control port.

### **Edit the Tor Configuration File**
Create or edit the Tor config file:
```sh
nano ~/.torrc
```

### **Add the following lines:**
```
SocksPort 9050
ControlPort 9051
CookieAuthentication 0
HashedControlPassword 16:YOUR_HASHED_PASSWORD
```
🚀 **What these do:**
- `SocksPort 9050` → Allows apps to connect via SOCKS5 proxy.
- `ControlPort 9051` → Enables sending commands to Tor (like changing IP).
- `CookieAuthentication 0` → Disables cookie-based authentication.
- `HashedControlPassword 16:YOUR_HASHED_PASSWORD` → Enables password authentication.

---

## **3. Generate a Hashed Password**
Tor requires authentication for control commands.

Run the following to generate a password hash:
```sh
tor --hash-password "your_secure_password"
```
It will return something like:
```
16:AABBCC112233...
```
Copy this and replace `YOUR_HASHED_PASSWORD` in `~/.torrc`.

---

## **4. Restart Tor**
Now, restart Tor to apply the new configuration:
```sh
brew services restart tor
```
or, if you want to run it manually:
```sh
tor
```

---

## **5. Verify Your IP**
To test if Tor is working, run:
```sh
curl --socks5-hostname 127.0.0.1:9050 https://check.torproject.org/api/ip
```
This should return a **Tor exit node IP**.

---

## **6. Change IP Address (Manually)**
Each time you restart Tor, you get a new IP.

1. Stop Tor:
   ```sh
   brew services stop tor
   ```
2. Start Tor again:
   ```sh
   brew services start tor
   ```
3. Check if your IP changed:
   ```sh
   curl --socks5-hostname 127.0.0.1:9050 https://check.torproject.org/api/ip
   ```

---

## **7. Change IP Address (Without Restarting Tor)**
You can send a `SIGNAL NEWNYM` command to Tor’s **ControlPort** to get a new IP without restarting Tor.

### **Create a Script to Change IP**
1. Create a new file:
   ```sh
   nano change_ip.sh
   ```
2. Add the following script:
   ```sh
   #!/usr/bin/expect

   spawn telnet 127.0.0.1 9051
   expect "Escape character"
   send "AUTHENTICATE \"your_secure_password\"\r"
   expect "250 OK"
   send "SIGNAL NEWNYM\r"
   expect "250 OK"
   send "quit\r"
   ```

3. Save and exit (`CTRL + X`, then `Y`, then `Enter`).

4. Make the script executable:
   ```sh
   chmod +x change_ip.sh
   ```

5. Run the script to change IP:
   ```sh
   ./change_ip.sh
   ```

6. Verify your new IP:
   ```sh
   curl --socks5-hostname 127.0.0.1:9050 https://check.torproject.org/api/ip
   ```

---

## **8. Automate IP Change Every X Seconds**
If you want to automatically rotate your IP every 30 seconds, modify your script:

```sh
#!/bin/bash
while true; do
  expect -c 'spawn telnet 127.0.0.1 9051; expect "Escape character"; send "AUTHENTICATE \"your_secure_password\"\r"; expect "250 OK"; send "SIGNAL NEWNYM\r"; expect "250 OK"; send "quit\r";'
  sleep 30  # Change IP every 30 seconds
done
```

Run it:
```sh
chmod +x change_ip.sh
./change_ip.sh
```

---

## **9. Use Tor Proxy in a Browser**
To use Tor in your browser (e.g., **Firefox**):
- Go to **Preferences > Network Settings**.
- Select **Manual Proxy Configuration**.
- Set:
  - **SOCKS Host:** `127.0.0.1`
  - **Port:** `9050`
- Check **Proxy DNS when using SOCKS v5**.

For **Google Chrome**, start it with:
```sh
open -a "Google Chrome" --args --proxy-server="socks5://127.0.0.1:9050"
```

---

## **10. Use Tor Proxy in Applications**
You can use Tor proxy in **cURL**:
```sh
curl --socks5-hostname 127.0.0.1:9050 http://check.torproject.org
```

Or in **Python** (using `requests`):
```python
import requests

proxies = {
    'http': 'socks5h://127.0.0.1:9050',
    'https': 'socks5h://127.0.0.1:9050',
}

response = requests.get('http://check.torproject.org', proxies=proxies)
print(response.text)
```

---

## **11. Stop Tor**
To stop Tor manually:
```sh
brew services stop tor
```

---

## **Final Notes**
- **New IPs take time to refresh**: Tor limits IP rotation to prevent abuse.
- **Use `--socks5-hostname` in curl**: Ensures domain resolution happens over Tor.
- **Tor exit nodes are public**: Some services may block them.

🚀 **Now you have a fully working Tor proxy on macOS with dynamic IP rotation!** Let me know if you need more help. 🔥