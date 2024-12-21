Here’s a comprehensive guide for configuring **phpMyAdmin** rules in **HestiaCP**. This includes steps for setting up access control for specific users, managing permissions, and configuring access via `config.inc.php` for security and access control.

---

### **Configuring phpMyAdmin Access Rules in HestiaCP**

#### 1. **Default phpMyAdmin Configuration**
HestiaCP configures **phpMyAdmin** for managing databases via a web interface. To manage user access and permissions, you need to configure the `config.inc.php` file for phpMyAdmin.

---

#### 2. **Location of the Configuration File**

The `config.inc.php` file is located at:

```
/etc/phpmyadmin/config.inc.php
```

This is the main configuration file for phpMyAdmin, where you will manage security, access control, and other settings.

---

#### 3. **Setting up Authentication (Blowfish Secret)**

Make sure you set up a strong **blowfish secret** to encrypt passwords stored in cookies. This is required for cookie-based authentication:

```php
$cfg["blowfish_secret"] = "rp48pSboXD3SPb0Y5CFr1P3iQpgDE2ld";  // Must be 32 chars long
```

---

#### 4. **Managing Access Control with `AllowDeny`**

To control which users have access to phpMyAdmin, you can set the **`AllowDeny`** rules.

- **AllowDeny Rules Syntax**:
    - **order**: Defines the order in which rules are applied.
    - **rules**: Contains the list of rules specifying which users from which IP addresses are allowed or denied.

##### Example:
```php
$cfg['Servers'][$i]['AllowDeny']['order'] = 'allow,deny';
$cfg['Servers'][$i]['AllowDeny']['rules'] = array(
    'allow root from 192.168.1.100',           // Allow root from specific IP
    'deny all from all'                        // Deny all other IPs
);
```

- **`order`**:
    - **allow,deny**: Allow users based on the 'allow' rules and deny based on 'deny' rules.
    - **deny,allow**: Deny users based on the 'deny' rules and allow based on the 'allow' rules.
    - **explicit**: More secure, only allow users explicitly listed.

- **`rules`**:
    - Format: `allow <user> from <ip>`
    - Example: `allow root from 192.168.1.100` allows `root` user to connect from `192.168.1.100`.
    - Example: `deny all from all` denies all access.

---

#### 5. **Example Configuration for Access Control**

If you want to allow the user `rezerv_admin` to access phpMyAdmin from a specific range of IP addresses and deny everyone else, you could use the following configuration:

```php
$cfg['Servers'][$i]['AllowDeny']['order'] = 'allow,deny';
$cfg['Servers'][$i]['AllowDeny']['rules'] = array(
    'allow rezerv_admin from 192.168.1.100',      // Allow rezerv_admin from a specific IP
    'allow rezerv_admin from 192.168.1.101',      // Allow rezerv_admin from another IP
    'deny all from all'                           // Deny everyone else
);
```

#### 6. **phpMyAdmin Security Settings**

- **Disable Root Login via Web Interface**:
  For enhanced security, disable `root` user login via phpMyAdmin:

  ```php
  $cfg['Servers'][$i]['AllowDeny']['rules'] = array(
      'deny root from all',
      'allow % from localhost'
  );
  ```

- **Limit phpMyAdmin Access by IP**:
  Restrict access to phpMyAdmin to specific IP addresses for extra security.

  Example to allow only `192.168.1.100`:
  ```php
  $cfg['Servers'][$i]['AllowDeny']['rules'] = array(
      'allow % from 192.168.1.100',
      'deny all from all'
  );
  ```