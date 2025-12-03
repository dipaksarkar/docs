[DOCS](https://idroot.us/install-ioncube-loader-ubuntu-22-04/)

/usr/bin/php8.1 -i | grep extension_dir

sudo cp ioncube_loader_lin_8.3.so ioncube_loader_lin_8.3_ts.so /usr/lib/php/20230831
echo -e "; configuration for php ioncube module\n; priority=00\nzend_extension=/usr/lib/php/20230831/ioncube_loader_lin_8.3.so" | sudo tee /etc/php/8.3/fpm/conf.d/00-ioncube.ini
cat /etc/php/8.3/fpm/conf.d/00-ioncube.ini

echo -e "; configuration for php ioncube module\n; priority=00\nzend_extension=/usr/lib/php/20230831/ioncube_loader_lin_8.3.so" | sudo tee /etc/php/8.3/cli/conf.d/00-ioncube.ini
cat /etc/php/8.3/cli/conf.d/00-ioncube.ini

/etc/php/8.1/fpm/php.ini


cat /etc/php/8.1/fpm/conf.d/00-ioncube.ini
; configuration for php ioncube module
; priority=00
zend_extension=/usr/lib/php/20200930/ioncube_loader_lin_8.1.so
sudo nano /etc/php/8.1/fpm/php.ini

grep -inr ioncube /etc/php/7.0

rm /etc/php/8.3/cli/conf.d/00-ioncube.ini
rm /etc/php/8.3/fpm/conf.d/00-ioncube.ini


# Install ionCube Loader on Ubuntu 22.04

```bash
wget https://raw.githubusercontent.com/dipaksarkar/docs/refs/heads/master/hestiacp/install_ioncube.sh
chmod +x install_ioncube.sh
./install_ioncube.sh
```

Here's an automated script to install IonCube on macOS with Homebrew PHP:

**Installation Instructions:**

1. **Run the script:**
   ```bash
   bash <(wget -qO- https://raw.githubusercontent.com/dipaksarkar/docs/refs/heads/master/encoder/install-ioncube-mac.sh)
   ```

2. **Restart PHP-FPM:**
   ```bash
   brew services restart php@8.2
   # Or for your specific PHP version:
   brew services restart php@$(php -r "echo PHP_MAJOR_VERSION.'.'.PHP_MINOR_VERSION;")
   ```

3. **Verify installation:**
   ```bash
   php -v | grep -i ioncube
   ```

**Alternative: Manual Installation**

If you prefer manual steps:

```bash
# Download IonCube for Apple Silicon (ARM64)
curl -L "https://downloads.ioncube.com/loader_downloads/ioncube_loaders_dar_arm64.tar.gz" -o ioncube.tar.gz

# Extract
tar -xzf ioncube.tar.gz

# Copy loader (adjust PHP version if needed)
sudo cp ioncube/ioncube_loader_dar_8.2.so /opt/homebrew/lib/php/pecl/20230831/

# Create config
echo "zend_extension = /opt/homebrew/lib/php/pecl/20230831/ioncube_loader_dar_8.2.so" | sudo tee /opt/homebrew/etc/php/8.2/conf.d/00-ioncube.ini

# Restart PHP-FPM
brew services restart php@8.2
```

**Troubleshooting:**

- If `php -v` doesn't show IonCube, check: `php --ini` to verify the INI file is loaded
- Ensure the loader file matches your PHP version exactly (8.2, 8.3, etc.)
- For Laravel Valet users, restart Valet: `valet restart`
