## Granting Sudo Access via visudo

To allow a specific user to run the command `sudo systemctl start nobounch-queues` without a password, follow these steps using `visudo`:

### 1. Open the sudoers file using visudo:
```bash
sudo visudo
```

### 2. Add a rule for the user
Scroll to the end of the file and add this line:

```
username ALL=(ALL) NOPASSWD: /bin/systemctl start nobounch-queues
```

> Replace `username` with the actual username.

### 3. Save and exit
- Press `Ctrl + X`
- Press `Y` to confirm saving
- Press `Enter` to exit

### 4. Test the command
Switch to the user and try running:
```bash
sudo systemctl start nobounch-queues
```

Since you've added `NOPASSWD`, it should run without asking for a password.

#### Alternative: Using a User Group
If you want multiple users to have access, create a group (e.g., `queueadmins`), add users to it, and modify sudoers:

```bash
sudo groupadd queueadmins
sudo usermod -aG queueadmins username
```

Then, in `visudo`, add:
```
%queueadmins ALL=(ALL) NOPASSWD: /bin/systemctl start nobounch-queues
```

Now, all users in the `queueadmins` group can run the command. 🚀

## Granting Sudo Access Using a Separate Configuration File

Instead of modifying the main `/etc/sudoers` file, you can create a separate configuration file under `/etc/sudoers.d/`. Here's how:

### 1. Create a new sudoers config file
```bash
sudo visudo -f /etc/sudoers.d/nobounch-queues
```

### 2. Add the following line
```
nobounch ALL=(ALL) NOPASSWD: /bin/systemctl start nobounch-queues
nobounch ALL=(ALL) NOPASSWD: /bin/systemctl restart nobounch-queues
nobounch ALL=(ALL) NOPASSWD: /bin/systemctl status nobounch-queues
```
> Replace `username` with the actual user's name.

### 3. Save and exit
- Press `Ctrl + X`
- Press `Y` to confirm saving
- Press `Enter` to exit

### 4. Set the correct permissions
Ensure the file has the correct permissions:
```bash
sudo chmod 0440 /etc/sudoers.d/nobounch-queues
```

### 5. Test the command
Switch to the user and try:
```bash
sudo systemctl start nobounch-queues
```

This method keeps the main `sudoers` file clean while still granting the necessary permissions. 🚀


To register the aliases globally (for all users, not just your user), follow these steps:

---

### **1️⃣ Add the Aliases to a Global Profile File**
Edit the global profile file:
```sh
sudo nano /etc/profile.d/nobounch-aliases.sh
```
Add the following lines:
```sh
alias nobounch-restart='/usr/bin/supervisorctl restart nobounch-worker:*'
alias nobounch-status='/usr/bin/supervisorctl status nobounch-worker:*'
```
Save and exit (**CTRL + X**, then **Y**, then **ENTER**).

---

### **2️⃣ Make the File Executable**
Run:
```sh
sudo chmod +x /etc/profile.d/nobounch-aliases.sh
```

---

### **3️⃣ Apply the Changes**
To apply immediately, run:
```sh
source /etc/profile.d/nobounch-aliases.sh
```

For new sessions, it will load automatically.

---

### **4️⃣ Verify**
Open a new terminal and test:
```sh
nobounch-restart
nobounch-status
```

✅ Now the aliases are available system-wide for all users! 🚀